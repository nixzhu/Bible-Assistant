//
//  BAAudioChapterViewController.m
//  Bible Assistant
//
//  Created by NIX on 14-3-30.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BAAudioChapterViewController.h"
#import "BAAudioChapterCell.h"
#import "BibleAudio.h"
#import "BibleAudio+BAAdditions.h"
#import "BAAudioSaver.h"
#import "BAAudioChpaterDelegate.h"

#import "BADownloadManager.h"
#import "BAStatusHUD.h"


#define TagDownloadAllAudios 1001
#define TagNoWiFi 1002
#define TagDeleteAllAudios 1003

@interface BAAudioChapterViewController () <UIAlertViewDelegate, BAAudioChpaterDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *chapters;
@property (nonatomic, strong) NSMutableDictionary *downloadCellInfo;

@end

@implementation BAAudioChapterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)audioSexChanged:(NSNotification *)notification
{
    [self initChapters];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.volume[@"name"];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;


    //监听用户的声音偏好
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSexChanged:) name:@"audioSexChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioDownloadProgress:)
                                                 name:[NSString stringWithFormat:@"Volume%dAudioDownloadProgressNotification", [self.volume[@"index"] integerValue]]
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"audioSexChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"Volume%dAudioDownloadProgressNotification", [self.volume[@"index"] integerValue]] object:nil];
}

- (void)audioDownloadProgress:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    
    NSInteger chapterIndex = [dic[@"chapter"] integerValue];
    
    NSMutableDictionary *chapter = self.chapters[chapterIndex];
    chapter[@"progress"] = [dic[@"progress"] copy];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 下载全部

- (IBAction)audioAction:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"音频操作"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"下载本卷所有音频", @"删除本卷所有音频", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"下载本卷所有音频"]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"下载%@的所有音频？", self.volume[@"name"]]
                                                            message:@"音频容量较大，推荐使用WiFi下载"
                                                           delegate:self
                                                  cancelButtonTitle:@"放弃"
                                                  otherButtonTitles: @"开始下载", nil];
        alertView.tag = TagDownloadAllAudios;
        [alertView show];
        
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"删除本卷所有音频"]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除确认"
                                                            message:[NSString stringWithFormat:@"是否要删除%@的所有音频？", self.volume[@"name"]]
                                                           delegate:self
                                                  cancelButtonTitle:@"点错了"
                                                  otherButtonTitles: @"马上删除", nil];
        alertView.tag = TagDeleteAllAudios;
        [alertView show];
        
        
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TagDownloadAllAudios) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"开始下载"]) {
            [BAStatusHUD showHUDWithString:@"下载即将开始" andDisappearIn:2.0];
            
            for (NSInteger i = 0; i < [self.volume[@"chapterNum"] integerValue]; i++) {
                [BADownloadManager downloadItemWithWithVolume:[self.volume[@"index"] integerValue] andChapter:i];
            }
        }
    } else if (alertView.tag == TagNoWiFi) {
        [self _beginDownload:self.downloadCellInfo];
    } else if (alertView.tag == TagDeleteAllAudios) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"马上删除"]) {
            for (NSInteger i = 0; i < [self.volume[@"chapterNum"] integerValue]; i++) {
                [self deleteAudioWithVolume:[self.volume[@"index"] integerValue] Chapter:i];
            }
            
            [BAStatusHUD showHUDWithString:@"删除成功" andDisappearIn:2.0];
        }
    }
}

#pragma mark - Properties

- (void)initChapters
{
    _chapters = [NSMutableArray array];
    
    NSArray *bibleAudios = [BibleAudio MR_findByAttribute:@"volume" withValue:self.volume[@"index"]];
    
    for (NSInteger i = 0; i < [self.volume[@"chapterNum"] integerValue]; i++) {
        BOOL haveDownloaded = NO;
        
        if ([BibleAudio isUserChooseAudioMale]) { //手动选择了男声
            for (BibleAudio *bibleAudio in bibleAudios) {
                if ([bibleAudio.chapter integerValue] == i && bibleAudio.audio_male && bibleAudio.audio_male.length > 0) {
                    haveDownloaded = YES;
                    break;
                }
            }
        } else { //默认女声
            for (BibleAudio *bibleAudio in bibleAudios) {
                if ([bibleAudio.chapter integerValue] == i && bibleAudio.audio && bibleAudio.audio.length > 0) {
                    haveDownloaded = YES;
                    break;
                }
            }
        }
        
        if (haveDownloaded) {
            [_chapters addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"progress":@1.0,
                                   @"chapter":@(i)}]];
        } else {
            [_chapters addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"progress":@0,
                                   @"chapter":@(i)}]];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (NSMutableArray *)chapters
{
    if (!_chapters) {
        [self initChapters];
    }
    
    return _chapters;
}

#pragma mark - 下载

- (void)_beginDownload:(NSMutableDictionary *)cellInfo
{
    if (cellInfo) {
        [BADownloadManager downloadItemWithWithVolume:[self.volume[@"index"] integerValue] andChapter:[cellInfo[@"chapter"] integerValue]];
    }
}

- (void)beginDownload:(NSMutableDictionary *)cellInfo
{
    //判断是否已下载
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"volume = %@ AND chapter = %d", self.volume[@"index"], [cellInfo[@"chapter"] integerValue]];
    //BibleAudio *bibleAudio = [BibleAudio MR_findFirstWithPredicate:predicate];
    
    BibleAudio *bibleAudio = [BibleAudio bibleAudioWithVolume:[self.volume[@"index"] integerValue] Chapter:[cellInfo[@"chapter"] integerValue]];
    
    if (bibleAudio) {
        //NSLog(@"已下载 %@ %d",  self.volume[@"index"], [cellInfo[@"chapter"] integerValue]);
        
        if ([BibleAudio isUserChooseAudioMale]) {
            if (bibleAudio.audio_male) {
                return;
            }
        } else {
            if (bibleAudio.audio) {
                return;
            }
        }
    }
    
    //先检查一下网络状况吧
    Reachability *reach = [Reachability reachabilityWithHostname:@"media.cathassist.org"];
    
    //NSLog(@"reach %d", reach.currentReachabilityStatus);
    
    if (reach.currentReachabilityStatus == NotReachable) {
        [[[UIAlertView alloc] initWithTitle:@"没有网络"
                                    message:@"抱歉，无法下载音频！"
                                   delegate:nil
                          cancelButtonTitle:@"了解"
                          otherButtonTitles: nil] show];
        return;
    } else if (reach.currentReachabilityStatus == ReachableViaWWAN) {
        self.downloadCellInfo = cellInfo; //只能先记住了，如果用户速度很快地点击多次，会不会有问题？
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有WiFi网络"
                                                            message:@"仍然使用蜂窝网络下载吗？"
                                                           delegate:self
                                                  cancelButtonTitle:@"放弃"
                                                  otherButtonTitles:@"仍然下载", nil];
        alertView.tag = TagNoWiFi;
        [alertView show];
        
        return;
    } else if (reach.currentReachabilityStatus == ReachableViaWiFi) {
        [self _beginDownload:cellInfo];
    }
}

- (void)saveContext {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        //NSLog(@"success %d", success);
        if (success) {
            //NSLog(@"You successfully saved your context.");
        } else if (error) {
            NSLog(@"Error saving context: %@", error.description);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.volume[@"chapterNum"] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BAAudioChapterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BAAudioChapterCell" forIndexPath:indexPath];
    
    cell.chapterLabel.text = [NSString stringWithFormat:@"第%d章", indexPath.row + 1];
    
    NSMutableDictionary *chapter = self.chapters[indexPath.row];
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        cell.progressView.progress = [chapter[@"progress"] floatValue];
    //});
    
    cell.delegate = self;
    cell.cellInfo = chapter;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *chapter = self.chapters[indexPath.row];
    if ([chapter[@"progress"] floatValue] == 1.0) {
        //进入章节并播放
        NSNumber *volumeNum = self.volume[@"index"];
        NSNumber *chapterNum = @(indexPath.row);
        NSNumber *sectionNum = @(0);
        
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        UINavigationController *navVC = (UINavigationController *)self.tabBarController.selectedViewController;
        [navVC popToRootViewControllerAnimated:NO]; //防止圣经已经push到章后，下面的跳转导致再次push到圣经（root 卷 章 卷 章）
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BibleGotoVolume"
                                                            object:nil
                                                          userInfo:@{@"volume":volumeNum, @"chapter":chapterNum, @"section":sectionNum, @"autoPlayAudio":@(YES)}];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *chapter = self.chapters[indexPath.row];
    if ([chapter objectForKey:@"progress"]) {
        if ([chapter[@"progress"] floatValue] == 1.0) {
            return YES;
        }
    }
    
    return NO;
}

- (void)deleteAudioWithVolume:(NSInteger)volume Chapter:(NSInteger)chapter
{
    BibleAudio *bibleAudio = [BibleAudio bibleAudioWithVolume:volume Chapter:chapter];
    
    if (bibleAudio) {
        if ([BibleAudio isUserChooseAudioMale]) {
            if (bibleAudio.audio_male) {
                [BAAudioSaver deleteAudioAtPath:bibleAudio.audio_male];
                bibleAudio.audio_male = nil;
            }
        } else {
            if (bibleAudio.audio) {
                [BAAudioSaver deleteAudioAtPath:bibleAudio.audio];
                bibleAudio.audio = nil;
            }
        }
        
        [self saveContext];
        
        [self initChapters]; //更新
    }

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteAudioWithVolume:[self.volume[@"index"] integerValue] Chapter:indexPath.row];
        //[self.chapters removeObjectAtIndex:indexPath.row];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
