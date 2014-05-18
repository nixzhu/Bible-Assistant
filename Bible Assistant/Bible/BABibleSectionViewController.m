//
//  BABibleSectionViewController.m
//  Bible Assistant
//
//  Created by NIX on 14-3-8.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BABibleSectionViewController.h"
#import "BABibleTitleCell.h"
#import "BABibleTextCell.h"
#import "BABibleTextCellDelegate.h"

#import <UINavigationController+SGProgress.h>

#import "Bookmark.h"
#import "BibleAudio.h"
#import "BibleAudio+BAAdditions.h"
#import "BAAppDelegate.h"

#import "BAAudioPlayer.h"
#import "BAStatusHUD.h"

@interface BABibleSectionViewController () <UITableViewDataSource, UITableViewDelegate, BABibleTextCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *textTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *audioButton;

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic) NSMutableArray *bookmarks;

@end

@implementation BABibleSectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //防御性清零播放进度条
    [self.navigationController setSGProgressPercentage:0.0];
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:100];
    for (ONOXMLElement *element in self.chapter.children) {
        if ([element.tag isEqualToString:@"section"]) {
            [sections addObject:@{@"type":@"bibleText",
                                  @"text":element.stringValue,
                                  @"section":element.attributes[@"value"]}];
        
        } else if ([element.tag isEqualToString:@"t3"]) {
            [sections addObject:@{@"type":@"fakeTitle",
                                  @"text":element.stringValue}];
        }
    }
    self.sections = sections;
    
    //若有可能，滚动到特定的（异步跳转、用户上次的浏览位置等）section
    if (self.biblelLocation) {
        NSInteger row = [self.biblelLocation[@"section"] integerValue];
        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[self.sections objectAtIndex:row]];
        muDic[@"isSelected"] = @YES;
        self.sections[row] = muDic;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textTableView reloadData];
            [self.textTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        });
        
        if (row == 0 && self.biblelLocation[@"contentOffsetY"]) {
            NSNumber *contentOffsetY = self.biblelLocation[@"contentOffsetY"];
            CGPoint contentOffset = self.textTableView.contentOffset;
            contentOffset.y = [contentOffsetY floatValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.textTableView setContentOffset:contentOffset];
            });
            
            [BAStatusHUD showHUDWithString:@"已到达上次阅读位置" andDisappearIn:2.0];
        }
    }
    
    //访问 Bookmarks ，好在 Cell 上做标记
    for (NSInteger i = 0; i < self.sections.count; i++) {
        for (Bookmark *bookmark in self.bookmarks) {
            if ([bookmark.volume integerValue] == [self.biblelLocation[@"volume"] integerValue]  &&
                [bookmark.chapter integerValue] == [self.biblelLocation[@"chapter"] integerValue]  &&
                [bookmark.section integerValue] == i) {
                NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[self.sections objectAtIndex:i]];
                muDic[@"isInBookmarks"] = @YES;
                self.sections[i] = muDic;
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.textTableView reloadData];
    });
    
    //监听系统字体修改通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    //处理自动播放
    NSNumber *autoPlayAudio = self.biblelLocation[@"autoPlayAudio"];
    if (autoPlayAudio && [autoPlayAudio boolValue]) {
        [self playOrPause:self.audioButton];
    }
    
    
    NSInteger volume = [self.biblelLocation[@"volume"] integerValue];
    NSInteger chapter = [self.biblelLocation[@"chapter"] integerValue];
    // 监听播放进度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAudioPlayProgress:) name:[NSString stringWithFormat:@"Volume%dChapter%dAudioPlayProgress", volume, chapter] object:nil];
    
    
    if ([BAAudioPlayer isPlayingVolume:[self.biblelLocation[@"volume"] integerValue] Chapter:[self.biblelLocation[@"chapter"] integerValue]]) {
        [self.audioButton setTitle:@"暂停"];
    }
    // 监听播放状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStateButtonTitle:) name:[NSString stringWithFormat:@"Volume%dChapter%dStateButtonTitle", volume, chapter] object:nil];
    
    
    //监听进入后台，好记录阅读位置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveLastBibleLocation) name:@"applicationDidEnterBackground" object:nil];
}

- (void)updateAudioPlayProgress:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    [self.navigationController setSGProgressPercentage:[[dic objectForKey:@"progress"] floatValue]*100.0];
}

- (void)updateStateButtonTitle:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    [self.audioButton setTitle:dic[@"buttonTitle"]];
    
    if ([dic[@"buttonTitle"] isEqualToString:@"暂停"]) {
        [BAStatusHUD showHUDWithString:@"即将播放" andDisappearIn:2.0];
    } else if ([dic[@"buttonTitle"] isEqualToString:@"播放"]) {
        [BAStatusHUD showHUDWithString:@"暂停" andDisappearIn:1.0];
    }
    
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    //[self.bookmarksTableView setNeedsLayout];
    [self.textTableView reloadData];
}

- (void)saveLastBibleLocation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //[userDefaults setObject:self.biblelLocation forKey:@"lastBibleLocation"]; //这样会尝试播放音频，还是算了
    [userDefaults setObject:@{@"volume":self.biblelLocation[@"volume"], @"chapter":self.biblelLocation[@"chapter"], @"section":@(0), @"contentOffsetY":@(self.textTableView.contentOffset.y)} forKey:@"lastBibleLocation"];
    //NSLog(@"saveLastBibleLocation");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController setSGProgressPercentage:0.0];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //保存今次阅读的位置，为下一次启动做准备
    [self saveLastBibleLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.sections[indexPath.row];
    
    if ([dic[@"type"] isEqualToString:@"bibleText"]) { //圣经文本Cell
        BABibleTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BABibleTextCell" forIndexPath:indexPath];
        
        cell.sectionNumLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.sectionNumLabel.text = dic[@"section"];
        cell.bibleTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.bibleTextView.text = dic[@"text"];
        
        //设置cell的自定义“代理和数据”，处理手势需要
        cell.delegate = self;
        cell.info = dic;
        
        
        if (dic[@"isInBookmarks"]) { //如果此Cell所代表的section在书签里，改变其isInBookmarksView的背景色为翡翠色
            cell.isInBookmarksView.backgroundColor = [dic[@"isInBookmarks"] boolValue] ? [UIColor emeraldColor] : [UIColor clearColor];
        } else if (dic[@"isSelected"]) { //如果此Cell所代表的section被选中（来自异步跳转等），改变其isInBookmarksView的背景色为蓝色（默认tintColor）
            cell.isInBookmarksView.backgroundColor = [dic[@"isSelected"] boolValue] ? self.view.tintColor : [UIColor clearColor];
        } else { //否则使其不可见
            cell.isInBookmarksView.backgroundColor = [UIColor clearColor];
        }
        
        return cell;
    
    } else if ([dic[@"type"] isEqualToString:@"fakeTitle"]) { //t2标题Cell
        BABibleTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BABibleTitleCell" forIndexPath:indexPath];
        cell.fakeTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.fakeTitleLabel.text = dic[@"text"];
        
        return cell;
    }
    
    return nil;
}

//动态计算Cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = self.sections[indexPath.row];
    
	NSString *codename = dic[@"text"];
	CGRect codenameRect = [codename
                           boundingRectWithSize:CGSizeMake(
                                                           CGRectGetWidth(CGRectIntegral(tableView.bounds)) - 78, //68 + 5 + 5
                                                           MAXFLOAT) // 40 = 20pt horizontal padding on each side
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}
                           context:nil];
    
	return MAX(44.0f, CGRectGetHeight(CGRectIntegral(codenameRect)) + 20);
    // 20 = 10pt vertical padding on each end
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - BABibleTextCellDelegate, CoreData

- (NSMutableArray *)bookmarks {
    //if (!_bookmarks) {
        _bookmarks = [[Bookmark MR_findAll] mutableCopy]; //每次访问时都是新的，好对比 //根据 Core Data 的特性，应该有更好的实现，也许没有，因为CD的存储是不完全的
    //}
    return _bookmarks;
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

- (void)addBookmark:(NSDictionary *)info
{
    //NSLog(@"addBookmark: %@", info);
    NSInteger index = [self.sections indexOfObject:info];
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:info];
    muDic[@"isInBookmarks"] = @YES;
    self.sections[index] = muDic;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.textTableView reloadData];
    });
    
    // MagicalRecord
    NSInteger volume = [self.biblelLocation[@"volume"] integerValue];
    NSInteger chapter = [self.biblelLocation[@"chapter"] integerValue];
    NSInteger section = index;
    
    BOOL isInBookmarks = NO;
    for (Bookmark *bookmark in self.bookmarks) {
        //NSLog(@"bookmark: %@", bookmark);
        if ([bookmark.volume integerValue] == volume &&
            [bookmark.chapter integerValue] == chapter &&
            [bookmark.section integerValue] == section) {
            isInBookmarks = YES;
            break;
        }
    }
    
    if (!isInBookmarks) {
        Bookmark *bookmark = [Bookmark MR_createEntity];
        if (bookmark) {
            bookmark.volume = self.biblelLocation[@"volume"];
            bookmark.chapter = self.biblelLocation[@"chapter"];
            bookmark.section =  @(index);

            NSString *title = self.volume.attributes[@"title"];
            NSArray *parts = [title componentsSeparatedByString:@" "];
            if (parts.count > 1) { // 2 or 3
                bookmark.volumeTitle = parts[1];
            }
            bookmark.chapterTitle = self.chapter.attributes[@"title"];
            bookmark.sectionNum = info[@"section"];
            
            bookmark.text = info[@"text"];
        }
        
        [self saveContext];
    } else {
        NSLog(@"isInBookmarks");
    }
}

- (void)deleteBookmark:(NSDictionary *)info
{
    //NSLog(@"deleteBookmark: %@", info);
    NSInteger index = [self.sections indexOfObject:info];
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:info];
    muDic[@"isInBookmarks"] = @NO;
    self.sections[index] = muDic;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.textTableView reloadData];
    });
    
    NSInteger volume = [self.biblelLocation[@"volume"] integerValue];
    NSInteger chapter = [self.biblelLocation[@"chapter"] integerValue];
    NSInteger section = index;
    
    for (Bookmark *bookmark in self.bookmarks) {
        //NSLog(@"bookmark: %@", bookmark);
        if ([bookmark.volume integerValue] == volume &&
            [bookmark.chapter integerValue] == chapter &&
            [bookmark.section integerValue] == section) {
            [bookmark MR_deleteEntity];
            [self saveContext];

            break;
        }
    }
    //[self.bookmarks removeObject:bookmarkToDelete]; //其实是不必要的，只需要从数据库删除就行了
}

- (void)shareSection:(NSDictionary *)info
{
    dispatch_async(dispatch_queue_create("share", NULL), ^{
        NSString *bigTitle = self.volume.attributes[@"sname"];
        NSArray *activityItems = @[[NSString stringWithFormat:@"%@（%@ %@:%@）来自:圣经小助手", info[@"text"], bigTitle, self.chapter.attributes[@"value"],info[@"section"]]];

        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                         applicationActivities:nil];
        activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                     UIActivityTypePrint,];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:activityController  animated:YES completion:nil];
        });
    });
}

#pragma mark - Play MP3 from web or local

- (IBAction)playOrPause:(UIBarButtonItem *)sender {
    [BAAudioPlayer playAudioWithVolume:[self.biblelLocation[@"volume"] integerValue] Chapter:[self.biblelLocation[@"chapter"] integerValue]];
}

@end
