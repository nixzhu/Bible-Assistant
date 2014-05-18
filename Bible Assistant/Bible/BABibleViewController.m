//
//  BABibleViewController.m
//  Bible Assistant
//
//  Created by NIX on 14-3-8.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BABibleViewController.h"
#import "BABibleVolumeCell.h"
#import "BABibleChapterViewController.h"
#import "BABookmarksViewController.h"
#import "BAAppDelegate.h"

#import <Ono.h>

@interface BABibleViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *volumes; //圣经卷数据

@property (nonatomic, strong) NSArray *colorVolume; //颜色区隔
@property (nonatomic, strong) NSArray *volumeColors; //具体颜色

@end

@implementation BABibleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Properties

- (NSArray *)colorVolume
{
    if (!_colorVolume) {
        _colorVolume = @[@0, @5, @21, @28, @34, @46, @50, @51, @64, @72];
    }
    
    return _colorVolume;
}

- (NSArray *)volumeColors
{
    if (!_volumeColors) {
        _volumeColors = @[[UIColor emeraldColor],
                          [UIColor peterRiverColor],
                          [UIColor amethystColor],
                          [UIColor sunFlowerColor],
                          [UIColor alizarinColor],
                          [UIColor turquoiseColor],
                          [UIColor lightPurpleColor],
                          [UIColor carrotColor],
                          [UIColor lightGreenColor],
                          [UIColor lightBlueColor]];
    }
    
    return _volumeColors;
}

//根据卷所在row确定其背景色
- (UIColor *)colorOfVolumeAtRow:(NSInteger)row
{
    for (NSInteger i = 0; i < self.colorVolume.count - 1; i++) {
        if (row >= [self.colorVolume[i] integerValue] && row < [self.colorVolume[i+1] integerValue]) {
            return self.volumeColors[i];
        }
    }
    
    return [self.volumeColors lastObject];
}

#pragma mark - 数据等准备

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //监听异步跳转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoBibleChapter:) name:@"BibleGotoVolume" object:nil];

    //准备圣经数据
    ONOXMLDocument *bible = ((BAAppDelegate *)[[UIApplication sharedApplication] delegate]).bible;
    
    NSMutableArray *volumes = [NSMutableArray arrayWithCapacity:100];

    for (ONOXMLElement *element in bible.rootElement.children) {
        NSString *title = element.attributes[@"name"];
        NSString *bigTitle = element.attributes[@"sname"];
        [volumes addObject:@{@"bigTitle":bigTitle,
                             @"title":title,
                             @"volume":element}];

    }
    self.volumes = volumes;

    //若可能，尝试跳转到上一次阅读的位置
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *lastBibleLocation = [userDefaults objectForKey:@"lastBibleLocation"];
    if (lastBibleLocation) {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        UINavigationController *navVC = (UINavigationController *)self.tabBarController.selectedViewController;
        [navVC popToRootViewControllerAnimated:NO]; //防止圣经已经push到章后，下面的跳转导致再次push到圣经（root 卷 章 卷 章）
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BibleGotoVolume" object:nil userInfo:lastBibleLocation];
    }
}

- (void)gotoBibleChapter:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    
    [self performSegueWithIdentifier:@"toBibleChapter" sender:dic];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.volumes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BABibleVolumeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BABibleVolumeCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor randomColor];
    cell.backgroundColor = [self colorOfVolumeAtRow:indexPath.row];
    NSDictionary *volume = self.volumes[indexPath.row];
    cell.volumeBigTitleLabel.text = volume[@"bigTitle"] ;
    cell.volumeTitleLabel.text = volume[@"title"];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"indexPath selected: %d, %d", indexPath.section, indexPath.row);
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(77, 77);
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //先处理异步跳转
    if ([sender isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)sender;
        //NSLog(@"dic %@",dic);
        BABibleChapterViewController *vc = segue.destinationViewController;
        vc.title = self.volumes[[dic[@"volume"] integerValue]][@"title"];
        vc.volume = self.volumes[[dic[@"volume"] integerValue]][@"volume"];
        vc.volumeNum = [dic[@"volume"] integerValue];
        vc.cellColor = [self colorOfVolumeAtRow:vc.volumeNum];
        vc.gotoDict = [dic copy];
        dic = nil; //需要释放吗？

        return;
    }
    
    //处理来自Storyboard的常规跳转
    if ([segue.identifier isEqualToString:@"toBibleChapter"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        BABibleChapterViewController *vc = segue.destinationViewController;
        vc.title = self.volumes[indexPath.row][@"title"];
        vc.volume = self.volumes[indexPath.row][@"volume"];
        vc.volumeNum = indexPath.row;
        vc.cellColor = [self colorOfVolumeAtRow:vc.volumeNum];
        
    
    } else if ([segue.identifier isEqualToString:@"showBookmarks"]) {
        BABookmarksViewController *vc = segue.destinationViewController;
        //对于被选中的书签，尝试跳转到它指明的章节
        vc.dismissWithSelection = ^(Bookmark *bookmark) {
            [self dismissViewControllerAnimated:YES completion:^{
                if (bookmark) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BibleGotoVolume" object:nil userInfo:@{@"volume":bookmark.volume, @"chapter":bookmark.chapter, @"section":bookmark.section}];
                }
            }];
        };
    }
}

@end
