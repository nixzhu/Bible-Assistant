//
//  BAAudioVolumeViewController.m
//  Bible Assistant
//
//  Created by NIX on 14-3-30.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BAAudioVolumeViewController.h"
#import "BAAudioChapterViewController.h"

@interface BAAudioVolumeViewController ()

@property (nonatomic, strong) NSArray *volumes;

@end

@implementation BAAudioVolumeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.volumes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BAAudioVolumeCell" forIndexPath:indexPath];
    
    NSDictionary *volume = self.volumes[indexPath.row];
    cell.textLabel.text = volume[@"name"];
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BAAudioChapterViewController *vc = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    vc.volume = self.volumes[indexPath.row];
}


@end
