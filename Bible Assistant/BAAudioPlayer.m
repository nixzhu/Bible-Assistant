//
//  BAAudioPlayer.m
//  Bible Assistant
//
//  Created by NIX on 14-4-21.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BAAudioPlayer.h"
#import "BibleAudio+BAAdditions.h"
#import "BAAppDelegate.h"

@import AVFoundation;

#define TagNoWiFi 1001

@interface BAAudioPlayer () <AVAudioPlayerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVPlayer *songPlayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) NSString *audioUrlString;

@property (nonatomic, strong) AVAudioPlayer *localSongPlayer;
@property (nonatomic, strong) NSTimer *localPlaybackTimer;
@property (nonatomic, strong) NSTimer *onlinePlaybackTimer;

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) NSNumber *volumeNum;
@property (nonatomic, strong) NSNumber *chapterNum;

@property (nonatomic, strong) NSArray *volumes;

//@property (nonatomic, strong) BibleAudio *bibleAudio;

@end

@implementation BAAudioPlayer

+ (BAAudioPlayer*)sharedInstance
{
	static id instance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[[self class] alloc] init];
	});
	
	return instance;
}

- (void)setIsPlaying:(BOOL)isPlaying
{
    _isPlaying = isPlaying;
    if (_isPlaying) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Volume%dChapter%dStateButtonTitle", [self.volumeNum integerValue], [self.chapterNum integerValue]] object:nil userInfo:@{@"buttonTitle":@"暂停"}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Volume%dChapter%dStateButtonTitle", [self.volumeNum integerValue], [self.chapterNum integerValue]] object:nil userInfo:@{@"buttonTitle":@"播放"}];
    }
}

+ (BOOL)isPlaying
{
    return [[BAAudioPlayer sharedInstance] isPlaying];
}

+ (BOOL)isPlayingVolume:(NSInteger)volume Chapter:(NSInteger)chapter
{
    if ([[[BAAudioPlayer sharedInstance] volumeNum] integerValue] == volume && [[[BAAudioPlayer sharedInstance] chapterNum] integerValue] == chapter) {
        return [BAAudioPlayer isPlaying];
    }
    return NO;
}

+ (void)playOrPause
{
    [[BAAudioPlayer sharedInstance] playAudioWithVolume:[[[BAAudioPlayer sharedInstance] volumeNum] integerValue] Chapter:[[[BAAudioPlayer sharedInstance] chapterNum] integerValue]];
}

+ (void)playAudioWithVolume:(NSInteger)volume Chapter:(NSInteger)chapter
{
    [[BAAudioPlayer sharedInstance] playAudioWithVolume:volume Chapter:chapter];
    //NSLog(@"+playAudioWithVolume");
}

- (void)playAudioWithVolume:(NSInteger)volume Chapter:(NSInteger)chapter
{
    BOOL isNew = NO;
    
    NSNumber *oldVolume = [[BAAudioPlayer sharedInstance] volumeNum];
    NSNumber *oldChapter = [[BAAudioPlayer sharedInstance] chapterNum];
    
    if (oldVolume && oldChapter && [oldVolume integerValue] == volume && [oldChapter integerValue] == chapter) { // 说明是同一个旧的
        //NSLog(@"OLD");
    } else { // 新的，或是第一个
        //NSLog(@"NEW");
        isNew = YES;
        [self.localPlaybackTimer invalidate];
        [self.onlinePlaybackTimer invalidate];
        //[[BAAudioPlayer sharedInstance] stopOldSongPlay];
    }
    
    [[BAAudioPlayer sharedInstance] setVolumeNum:@(volume)];
    [[BAAudioPlayer sharedInstance] setChapterNum:@(chapter)];
    
    
    NSString *urlString = [BibleAudio femaleAudioURLStringWithVolume:volume Chapter:chapter];
    NSString *urlString_male = [BibleAudio maleAudioURLStringWithVolume:volume Chapter:chapter];

    BibleAudio *bibleAudio = [BibleAudio bibleAudioWithVolume:volume Chapter:chapter];
    
    if ([BibleAudio isUserChooseAudioMale]) { //用户选择男声偏好
        if (bibleAudio && bibleAudio.audio_male && bibleAudio.audio_male.length > 0) {
            if (isNew) {
                [self stopOldSongPlay]; //先停掉上一次的播放
                [self playBibleAudio:bibleAudio];
                self.isPlaying = YES;
            } else {
                if (self.localSongPlayer && self.localSongPlayer.playing) {
                    [self.localSongPlayer pause];
                    self.isPlaying = NO;
                    
                } else if (self.localSongPlayer) {
                    [self.localSongPlayer play];
                    self.isPlaying = YES;
                }
            }
        } else {
            if (isNew) {
                [self stopOldSongPlay]; //先停掉上一次的播放
                [self playBibleAudioWithURL:urlString_male];
            } else {
                if (self.songPlayer && self.songPlayer.rate > 0.0) {
                    [self.songPlayer pause];
                    self.isPlaying = NO;
                    
                } else if (self.songPlayer) {
                    [self.songPlayer play];
                    self.isPlaying = YES;
                }
            }
        }
    } else { //默认女声偏好
        if (bibleAudio && bibleAudio.audio && bibleAudio.audio.length > 0) {
            if (isNew) {
                [self stopOldSongPlay]; //先停掉上一次的播放
                [self playBibleAudio:bibleAudio];
                self.isPlaying = YES;
            } else {
                if (self.localSongPlayer && self.localSongPlayer.playing) {
                    [self.localSongPlayer pause];
                    self.isPlaying = NO;
                    
                } else if (self.localSongPlayer) {
                    [self.localSongPlayer play];
                    self.isPlaying = YES;
                    
                }
            }
        } else {
            if (isNew) {
                [self stopOldSongPlay]; //先停掉上一次的播放
                [self playBibleAudioWithURL:urlString];
            } else {
                if (self.songPlayer && self.songPlayer.rate > 0.0) {
                    [self.songPlayer pause];
                    self.isPlaying = NO;
                    
                } else if (self.songPlayer) {
                    [self.songPlayer play];
                    self.isPlaying = YES;
                    
                }
            }
        }
    }
}


//播放本地音频
- (void)playBibleAudio:(BibleAudio *)bibleAudio
{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent: [BibleAudio isUserChooseAudioMale]? bibleAudio.audio_male : bibleAudio.audio];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath]) {
        [[[UIAlertView alloc] initWithTitle:@"发生错误"
                                    message:@"抱歉，本地音频不存在，将尝试网络播放！"
                                   delegate:nil
                          cancelButtonTitle:@"安心接受"
                          otherButtonTitles: nil] show];

        //将存储里的路径删除
        if ([BibleAudio isUserChooseAudioMale]) {
            bibleAudio.audio_male = nil;
        } else {
            bibleAudio.audio = nil;
        }
        [self saveContext];
        
        //再尝试在线播放
        [self stopOldSongPlay]; //先停掉上一次的播放
        [self playBibleAudioWithURL:[BibleAudio isUserChooseAudioMale]? bibleAudio.url_male : bibleAudio.url];
        
        return;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSError *error;
    self.localSongPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    if (!error) {
        [self.localSongPlayer prepareToPlay];
        //[self.localSongPlayer setVolume: 1.0];
        self.localSongPlayer.delegate = self;
        [self.localSongPlayer play];
        
        ((BAAppDelegate *)[[UIApplication sharedApplication] delegate]).localPlayer = self.localSongPlayer; // 更新全局本地播放器
        
        self.localPlaybackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                   target:self
                                                                 selector:@selector(updateLocalProgress:)
                                                                 userInfo:nil
                                                                  repeats:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"发生错误"
                                    message:@"抱歉，本地音频播放失败！"
                                   delegate:nil
                          cancelButtonTitle:@"安心接受"
                          otherButtonTitles: nil] show];
        self.isPlaying = NO;
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {
        if (self.playerItem.status == AVPlayerStatusFailed) {
            //NSLog(@"AVPlayer Failed");
            [[[UIAlertView alloc] initWithTitle:@"发生错误"
                                        message:@"在线音频播放失败！"
                                       delegate:nil
                              cancelButtonTitle:@"安心接受"
                              otherButtonTitles: nil] show];
            self.isPlaying = NO;
            
        } else if (self.playerItem.status == AVPlayerStatusReadyToPlay) {
            //NSLog(@"AVPlayerStatusReadyToPlay");
            [self.songPlayer play];
            
            ((BAAppDelegate *)[[UIApplication sharedApplication] delegate]).onlinePlayer = self.songPlayer; // 更新全局在线播放器
            
            //[self.audioButton setTitle:@"暂停"];
            
        } else if (self.playerItem.status == AVPlayerItemStatusUnknown) {
            //NSLog(@"AVPlayer Unknown");
            [[[UIAlertView alloc] initWithTitle:@"发生错误"
                                        message:@"播放器状态不明！"
                                       delegate:nil
                              cancelButtonTitle:@"安心接受"
                              otherButtonTitles: nil] show];
            self.isPlaying = NO;
        }
    }
}

//播放在线音频
- (void)_playBibleAudioWithURL:(NSString *)urlString
{
    if (urlString) {
        //NSString *urlString = @"http://media.cathassist.org/bible/mp3/001/001.mp3"; //your url
        //AVPlayer *player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:urlString]];
        
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlString]];
        [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];// (can use it) */
        self.songPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        //self.songPlayer = player;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self.songPlayer currentItem]];
        
        //[self.songPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
        self.onlinePlaybackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
        //[self.songPlayer play];
    }
}

//检查网络，尝试播放在线音频
- (void)playBibleAudioWithURL:(NSString *)urlString
{
    Reachability *reach = [Reachability reachabilityWithHostname:@"media.cathassist.org"];
    //NSLog(@"reach %d", reach.currentReachabilityStatus);
    
    if (reach.currentReachabilityStatus == NotReachable) {
        self.isPlaying = NO;
        
        [[[UIAlertView alloc] initWithTitle:@"没有网络"
                                    message:@"抱歉，无法播放在线音频！"
                                   delegate:nil
                          cancelButtonTitle:@"了解"
                          otherButtonTitles: nil] show];
        
        return;
    } else if (reach.currentReachabilityStatus == ReachableViaWWAN) {
        self.audioUrlString = urlString; //只能先记住了
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有WiFi网络"
                                                            message:@"仍然使用蜂窝网络播放吗？"
                                                           delegate:self
                                                  cancelButtonTitle:@"放弃"
                                                  otherButtonTitles:@"仍然播放", nil];
        alertView.tag = TagNoWiFi;
        [alertView show];
        
        return;
    } else if (reach.currentReachabilityStatus == ReachableViaWiFi) {
        [self _playBibleAudioWithURL:urlString];
        self.isPlaying = YES;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TagNoWiFi) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"仍然播放"]) {
            [self _playBibleAudioWithURL:self.audioUrlString];
        } else {
            self.isPlaying = NO;
        }
    }
}

- (void)stopOldSongPlay
{
    AVAudioPlayer *localPlayer = self.localSongPlayer;
    if (localPlayer.playing) {
        [localPlayer stop];
    }
    
    AVPlayer *onlinePlayer = self.songPlayer;
    if (onlinePlayer.rate > 0.0) {
        [onlinePlayer pause];
    }
}

- (void)saveContext {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            //NSLog(@"You successfully saved your context.");
        } else if (error) {
            NSLog(@"Error saving context: %@", error.description);
        }
    }];
}

//本地播放进度更新
- (void)updateLocalProgress:(NSTimer*)timer {
    
    float total = self.localSongPlayer.duration;
    float progress = self.localSongPlayer.currentTime / total;
    
    //[self.navigationController setSGProgressPercentage:progress*100.0];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Volume%dChapter%dAudioPlayProgress", [self.volumeNum integerValue], [self.chapterNum integerValue]] object:nil userInfo:@{@"progress":@(progress)}];

    //NSLog(@"+lp %@,%@, %f",self.volumeNum, self.chapterNum ,progress);
}

//在线播放进度更新
- (void)updateProgress:(NSTimer *)timer
{
    double duration = CMTimeGetSeconds([[[[self songPlayer] currentItem] asset] duration]);
    int64_t current = self.songPlayer.currentTime.value / self.songPlayer.currentTime.timescale;
    float progress = current/floorl(duration);
    
    if (progress < 1.0) {
        //[self.navigationController setSGProgressPercentage:progress*100.0];
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Volume%dChapter%dAudioPlayProgress", [self.volumeNum integerValue], [self.chapterNum integerValue]] object:nil userInfo:@{@"progress":@(progress)}];
    }
    //NSLog(@"+op %@,%@, %f",self.volumeNum, self.chapterNum ,progress);
}

//在线播放结束
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    //先停止进度更新计时器
    [self.onlinePlaybackTimer invalidate];
    
    //进度条达到100%（手动确保到100%好让它自己消失）
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Volume%dChapter%dAudioPlayProgress", [self.volumeNum integerValue], [self.chapterNum integerValue]] object:nil userInfo:@{@"progress":@(1.0)}];

    self.isPlaying = NO;
    
    [self.songPlayer.currentItem seekToTime:CMTimeMakeWithSeconds(0.0, self.songPlayer.currentItem.currentTime.timescale)];
    
    //尝试播放下一章
    [self tryPlayNextChapter];
}

//本地播放结束
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.localPlaybackTimer invalidate];
    //[self.navigationController setSGProgressPercentage:1.0*100.0];
    //[self.audioButton setTitle:@"播放"];
    self.isPlaying = NO;
    [self tryPlayNextChapter];
    //NSLog(@"+audioPlayerDidFinishPlaying");
}

+ (void)tryPlayNextChapter
{
    [[BAAudioPlayer sharedInstance] tryPlayNextChapter];
}

- (void)tryPlayNextChapter
{
    //试图自动播放下一章，当然先检查用户的偏好设置
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *autoPlayNextChapter = [userDefaults objectForKey:@"autoPlayNextChapter"];
    //NSLog(@"try autoPlayNextChapter %@", autoPlayNextChapter);
    
    if (autoPlayNextChapter && [autoPlayNextChapter boolValue]) {
        NSInteger chapterCount = 0;
        NSDictionary *volume = self.volumes[[self.volumeNum integerValue]];
        chapterCount = [volume[@"chapterNum"] integerValue];
        
        NSInteger newChapterNum = [self.chapterNum integerValue] + 1;
        
        if (newChapterNum < chapterCount) {  //判断合法性
            NSNumber *volumeNum = self.volumeNum;
            NSNumber *chapterNum = @(newChapterNum);

            [[NSNotificationCenter defaultCenter] postNotificationName:@"playNextChapter" object:nil userInfo:@{@"volumeNum":volumeNum, @"chapterNum":chapterNum}];
        } else {
            //TODO 提示用户本卷没有更多章节可以播放了？
        }
    }
}


- (NSArray *)volumes
{
    if (!_volumes) {
        _volumes = @[@{@"index":@0, @"name":@"创世纪", @"chapterNum":@50},
                     @{@"index":@1, @"name":@"出谷纪", @"chapterNum":@40},
                     @{@"index":@2, @"name":@"肋未纪", @"chapterNum":@27},
                     @{@"index":@3, @"name":@"户籍纪", @"chapterNum":@36},
                     @{@"index":@4, @"name":@"申命纪", @"chapterNum":@34},
                     @{@"index":@5, @"name":@"若苏厄书", @"chapterNum":@24},
                     @{@"index":@6, @"name":@"民长纪", @"chapterNum":@21},
                     @{@"index":@7, @"name":@"卢德传", @"chapterNum":@4},
                     @{@"index":@8, @"name":@"撒慕尔纪上", @"chapterNum":@31},
                     @{@"index":@9, @"name":@"撒慕尔纪下", @"chapterNum":@24},
                     @{@"index":@10, @"name":@"列王纪上", @"chapterNum":@22},
                     @{@"index":@11, @"name":@"列王纪下", @"chapterNum":@25},
                     @{@"index":@12, @"name":@"编年纪上", @"chapterNum":@29},
                     @{@"index":@13, @"name":@"编年纪下", @"chapterNum":@36},
                     @{@"index":@14, @"name":@"厄斯德拉上", @"chapterNum":@10},
                     @{@"index":@15, @"name":@"厄斯德拉下", @"chapterNum":@13},
                     
                     @{@"index":@16, @"name":@"多俾亚传", @"chapterNum":@14},
                     @{@"index":@17, @"name":@"友弟德传", @"chapterNum":@16},
                     @{@"index":@18, @"name":@"艾斯德尔传", @"chapterNum":@10},
                     @{@"index":@19, @"name":@"玛加伯上", @"chapterNum":@16},
                     @{@"index":@20, @"name":@"玛加伯下", @"chapterNum":@15},
                     @{@"index":@21, @"name":@"约伯传", @"chapterNum":@42},
                     @{@"index":@22, @"name":@"圣咏集", @"chapterNum":@150},
                     @{@"index":@23, @"name":@"箴言篇", @"chapterNum":@31},
                     @{@"index":@24, @"name":@"训道篇", @"chapterNum":@12},
                     @{@"index":@25, @"name":@"雅歌", @"chapterNum":@8},
                     @{@"index":@26, @"name":@"智慧篇", @"chapterNum":@19},
                     @{@"index":@27, @"name":@"德训篇", @"chapterNum":@51},
                     @{@"index":@28, @"name":@"依撒意亚", @"chapterNum":@66},
                     @{@"index":@29, @"name":@"耶肋米亚", @"chapterNum":@52},
                     @{@"index":@30, @"name":@"耶肋米亚哀歌", @"chapterNum":@5},
                     @{@"index":@31, @"name":@"巴路克", @"chapterNum":@6},
                     @{@"index":@32, @"name":@"厄则克耳", @"chapterNum":@48},
                     @{@"index":@33, @"name":@"达尼尔", @"chapterNum":@14},
                     @{@"index":@34, @"name":@"欧瑟亚", @"chapterNum":@14},
                     @{@"index":@35, @"name":@"岳厄尔", @"chapterNum":@4},
                     @{@"index":@36, @"name":@"亚毛斯", @"chapterNum":@9},
                     @{@"index":@37, @"name":@"亚北底亚", @"chapterNum":@1},
                     @{@"index":@38, @"name":@"约纳", @"chapterNum":@4},
                     @{@"index":@39, @"name":@"米该亚", @"chapterNum":@7},
                     @{@"index":@40, @"name":@"纳鸿", @"chapterNum":@3},
                     @{@"index":@41, @"name":@"哈巴谷", @"chapterNum":@3},
                     @{@"index":@42, @"name":@"索福尼亚", @"chapterNum":@3},
                     @{@"index":@43, @"name":@"哈盖", @"chapterNum":@2},
                     @{@"index":@44, @"name":@"匝加利亚", @"chapterNum":@14},
                     @{@"index":@45, @"name":@"玛拉基亚", @"chapterNum":@3},
                     @{@"index":@46, @"name":@"玛窦福音", @"chapterNum":@28},
                     @{@"index":@47, @"name":@"马尔谷福音", @"chapterNum":@16},
                     @{@"index":@48, @"name":@"路加福音", @"chapterNum":@24},
                     @{@"index":@49, @"name":@"若望福音", @"chapterNum":@21},
                     
                     @{@"index":@50, @"name":@"宗徒大事录", @"chapterNum":@28},
                     @{@"index":@51, @"name":@"罗马人书", @"chapterNum":@16},
                     @{@"index":@52, @"name":@"格林多前书", @"chapterNum":@16},
                     @{@"index":@53, @"name":@"格林多后书", @"chapterNum":@13},
                     @{@"index":@54, @"name":@"迦拉达书", @"chapterNum":@6},
                     @{@"index":@55, @"name":@"厄弗所书", @"chapterNum":@6},
                     @{@"index":@56, @"name":@"斐理伯书", @"chapterNum":@4},
                     @{@"index":@57, @"name":@"哥罗森书", @"chapterNum":@4},
                     @{@"index":@58, @"name":@"得撒洛尼前书", @"chapterNum":@5},
                     @{@"index":@59, @"name":@"得撒洛尼后书", @"chapterNum":@3},
                     @{@"index":@60, @"name":@"弟茂德前书", @"chapterNum":@6},
                     @{@"index":@61, @"name":@"弟茂德后书", @"chapterNum":@4},
                     @{@"index":@62, @"name":@"弟铎书", @"chapterNum":@3},
                     @{@"index":@63, @"name":@"费肋孟书", @"chapterNum":@1},
                     @{@"index":@64, @"name":@"希伯来书", @"chapterNum":@13},
                     @{@"index":@65, @"name":@"雅各伯书", @"chapterNum":@5},
                     @{@"index":@66, @"name":@"伯多禄前书", @"chapterNum":@5},
                     @{@"index":@67, @"name":@"伯多禄后书", @"chapterNum":@3},
                     @{@"index":@68, @"name":@"若望一书", @"chapterNum":@5},
                     @{@"index":@69, @"name":@"若望二书", @"chapterNum":@1},
                     @{@"index":@70, @"name":@"若望三书", @"chapterNum":@1},
                     @{@"index":@71, @"name":@"犹达书", @"chapterNum":@1},
                     @{@"index":@72, @"name":@"若望默示录", @"chapterNum":@22},];
    }
    
    return _volumes;
}


@end
