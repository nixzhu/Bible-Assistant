//
//  BABibleChapterViewController.m
//  Bible Assistant
//
//  Created by NIX on 14-3-8.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BABibleChapterViewController.h"
#import "BABibleChapterCell.h"
#import "BABibleSectionViewController.h"

@interface BABibleChapterViewController ()

@property (nonatomic, strong) NSArray *chapters;

@end

@implementation BABibleChapterViewController

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

    NSMutableArray *chapters = [NSMutableArray arrayWithCapacity:100];
    
    for (ONOXMLElement *element in self.volume.children) {
        if ([element.tag isEqualToString:@"chapter"]) {
            [chapters addObject:@{@"title":element.attributes[@"title"],
                                  @"chapter":element}];
        }
    }
    self.chapters = chapters;
}

- (void)viewDidAppear:(BOOL)animated
{
    //处理来自 金句等地 的异步跳转
    if (self.gotoDict) {
        [self performSegueWithIdentifier:@"toBibleSection" sender:self.gotoDict];
        self.gotoDict = nil; // 防止返回时再被跳转
    }
    
    //Calling pushViewController before viewDidAppear is unsafe.
    //http://stackoverflow.com/questions/5525519/iphone-uinavigation-issue-nested-push-animation-can-result-in-corrupted-naviga
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
    return self.chapters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BABibleChapterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BABibleChapterCell" forIndexPath:indexPath];
    cell.backgroundColor = self.cellColor;
    cell.chapterLabel.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    
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
    return CGSizeMake(50, 50);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //通用准备异步跳转
    if ([sender isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)sender;
        //NSLog(@"in chapter dic %@",dic);
        BABibleSectionViewController *vc = segue.destinationViewController;
        vc.title = self.chapters[[dic[@"chapter"] integerValue]][@"title"];
        vc.volume = self.volume;
        vc.chapter = self.chapters[[dic[@"chapter"] integerValue]][@"chapter"];
        vc.biblelLocation = [dic copy];
        dic = nil;
        
        return;
    }
    
    //常规跳转
    if ([segue.identifier isEqualToString:@"toBibleSection"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        BABibleSectionViewController *vc = segue.destinationViewController;
        vc.title = self.chapters[indexPath.row][@"title"];
        vc.volume = self.volume;
        vc.chapter = self.chapters[indexPath.row][@"chapter"];
        vc.biblelLocation = @{@"volume":@(self.volumeNum),
                              @"chapter":@(indexPath.row),
                              @"section":@(0)};
    }
}

@end
