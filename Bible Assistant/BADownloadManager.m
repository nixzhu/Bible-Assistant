//
//  BADownloadManager.m
//  Bible Assistant
//
//  Created by NIX on 14-4-12.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BADownloadManager.h"

#import "BibleAudio+BAAdditions.h"
#import "BAAudioSaver.h"

#define kHTTPMaximumConnectionsPerHost 100

@interface BADownloadManager() <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSMutableArray *downloadQueue;
@property (nonatomic, strong) NSURLSession *downloadSession;
@property (nonatomic, assign) NSInteger isDownloadingCount;
@property (nonatomic, assign) BOOL isShowingDownloadErrorAlert;

@end

@implementation BADownloadManager

+ (BADownloadManager*)sharedInstance
{
	static id instance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[[self class] alloc] init];
	});
	
	return instance;
}

- (NSMutableArray *)downloadQueue
{
    if (!_downloadQueue) {
        _downloadQueue = [NSMutableArray array];
    }
    
    return _downloadQueue;
}

- (NSURLSession *)downloadSession
{
    if (!_downloadSession) {
#if 1
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _downloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
#else
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.HTTPMaximumConnectionsPerHost = kHTTPMaximumConnectionsPerHost;
        sessionConfig.timeoutIntervalForResource = 3600; // 超时治标
        sessionConfig.timeoutIntervalForRequest = 3600; // 超时治标
        _downloadSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
#endif
    }
    
    return _downloadSession;
}


+ (void)downloadItemWithWithVolume:(NSInteger)volume andChapter:(NSInteger)chapter
{
    [[self sharedInstance] downloadAudioWithVolume:volume andChapter:chapter];
}

- (void)saveContext {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            //NSLog(@"XYou successfully saved your context.");
        } else if (error) {
            NSLog(@"XError saving context: %@", error.description);
        }
    }];
}

- (void)downloadAudioWithVolume:(NSInteger)volume andChapter:(NSInteger)chapter// saveInto:(BibleAudio *)bibleAudio
{
    //先检查一下是否已经在队列里了
    for (NSDictionary *item in self.downloadQueue) {
        if ([item[@"volume"] integerValue] == volume && [item[@"chapter"] integerValue] == chapter) {
            return;
        }
    }
    
    NSString *urlString = [BibleAudio femaleAudioURLStringWithVolume:volume Chapter:chapter];
    NSString *urlString_male = [BibleAudio maleAudioURLStringWithVolume:volume Chapter:chapter];
    
    BibleAudio *bibleAudio = [BibleAudio bibleAudioWithVolume:volume Chapter:chapter];
    
    if (!bibleAudio) {
        bibleAudio = [BibleAudio MR_createEntity];
        bibleAudio.volume = @(volume);
        bibleAudio.chapter = @(chapter);
        bibleAudio.url = urlString;
        bibleAudio.url_male = urlString_male;
        [self saveContext];
    } else {
        // 如果已有男声/女声，那也不用下载了
        if ([BibleAudio isUserChooseAudioMale]) {
            if (bibleAudio && bibleAudio.audio_male && bibleAudio.audio_male.length > 0) {
                return;
            }
        } else {
            if (bibleAudio && bibleAudio.audio && bibleAudio.audio.length > 0) {
                return;
            }
        }
    }
    

    [self.downloadQueue addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"volume":@(volume), @"chapter":@(chapter), @"isDownloading":@(NO)}]];
    
    [self downloadFirstInQueue:self.downloadQueue];
}

- (void)downloadFirstInQueue:(NSMutableArray *)queue
{
    self.isShowingDownloadErrorAlert = NO;
    
    if (self.isDownloadingCount < 3) {
        for (NSMutableDictionary *dic in queue) {
            if (![dic[@"isDownloading"] boolValue]) {

                NSString *urlString = [BibleAudio femaleAudioURLStringWithVolume:[dic[@"volume"] integerValue] Chapter:[dic[@"chapter"] integerValue]];
                NSString *urlString_male = [BibleAudio maleAudioURLStringWithVolume:[dic[@"volume"] integerValue] Chapter:[dic[@"chapter"] integerValue]];
                
                NSURL *downloadURL = [BibleAudio isUserChooseAudioMale]? [NSURL URLWithString:urlString_male] : [NSURL URLWithString:urlString];
                NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
                
                NSURLSessionDownloadTask *downloadTask = [self.downloadSession downloadTaskWithRequest:request];
                
                [downloadTask resume];
                dic[@"isDownloading"] = @(YES);
                self.isDownloadingCount ++;

                break;
            }
        }
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    BibleAudio *bibleAudio = [BibleAudio MR_findFirstByAttribute:[BibleAudio urlAttribute] withValue:downloadTask.originalRequest.URL.absoluteString];
    
    if (bibleAudio) {
        NSData *audioData = [NSData dataWithContentsOfURL:location];
        [BAAudioSaver saveAudio:audioData ToDiskAndToBibleAudio:bibleAudio];
    } else {
        //NSLog(@"XbibleAudio: NO!!!");
    }
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        //NSLog(@"Xsave sudio success? %d", success);
    }];
    
    [self resumeNextAndCleanDownloadTask:downloadTask];
}

- (void)resumeNextAndCleanDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    //清理后尝试再下载下一个
    NSMutableDictionary *theDic = nil;
    for (NSMutableDictionary *dic in self.downloadQueue) {
        if (dic[@"downloadTask"] == downloadTask) {
            theDic = dic;
            break;
        }
    }
    [self.downloadQueue removeObject:theDic];
    self.isDownloadingCount --;
    //NSLog(@"finish and call downloadFirstInQueue");
    [self downloadFirstInQueue:self.downloadQueue];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    BibleAudio *bibleAudio = [BibleAudio MR_findFirstByAttribute:[BibleAudio urlAttribute] withValue:downloadTask.originalRequest.URL.absoluteString];
    if (bibleAudio) {

        NSNumber *progress = @(1.0 * totalBytesWritten/totalBytesExpectedToWrite);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Volume%@AudioDownloadProgressNotification", bibleAudio.volume]
                                                            object:nil
                                                          userInfo:@{@"volume":bibleAudio.volume, @"chapter":bibleAudio.chapter, @"progress":progress}];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    //
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        if (!self.isShowingDownloadErrorAlert) {
            // 可能会弹出多次，用全局变量控制出错，一旦错误，就不再显示，点击接受后再改为正常状态
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发生异常"
                                                                message:@"网络请求超时，请稍后再试！"
                                                               delegate:nil
                                                      cancelButtonTitle:@"安心接受"
                                                      otherButtonTitles: nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alertView show];
            });
            
            self.isShowingDownloadErrorAlert = YES;
        }
        
        self.isDownloadingCount --;
        [self.downloadQueue removeAllObjects];
    }
}

@end
