//
//  BASettingsViewController.m
//  Bible Assistant
//
//  Created by NIX on 14-4-5.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BASettingsViewController.h"
#import "BibleAudio+BAAdditions.h"

@interface BASettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *autoPlayNextChapterSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *audioSexSegmentedControl;

@end

@implementation BASettingsViewController

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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *autoPlayNextChapter = [userDefaults objectForKey:@"autoPlayNextChapter"];
    if (autoPlayNextChapter && [autoPlayNextChapter boolValue]) {
        self.autoPlayNextChapterSwitch.on = YES;
    }
    
    if ([BibleAudio isUserChooseAudioMale]) {
        self.audioSexSegmentedControl.selectedSegmentIndex = 0;
    } else {
        self.audioSexSegmentedControl.selectedSegmentIndex = 1;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)autoPlayNextChapter:(UISwitch *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (sender.isOn) {
        [userDefaults setObject:@(YES) forKey:@"autoPlayNextChapter"];
    } else {
        [userDefaults setObject:@(NO) forKey:@"autoPlayNextChapter"];
    }
    //NSLog(@"set autoPlayNextChapter to %@", [userDefaults objectForKey:@"autoPlayNextChapter"]);
}

- (IBAction)chooseAudioSex:(UISegmentedControl *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    if (sender.selectedSegmentIndex == 0) {
        [userDefaults setObject:@"audioMale" forKey:@"audioSex"];
    } else if (sender.selectedSegmentIndex == 1) {
        [userDefaults setObject:@"audioFemale" forKey:@"audioSex"];
    }
    //NSLog(@"audioSex: %@", [userDefaults objectForKey:@"audioSex"]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"audioSexChanged" object:nil];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            NSString *appURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", @"851014654"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
        } else if (indexPath.row == 1) {
            dispatch_async(dispatch_queue_create("share", NULL), ^{
                NSArray *activityItems = @[[NSString stringWithFormat:@"圣经小助手 https://appsto.re/cn/-pxUY.i \n提供圣经文本阅读、金句、关键字查询、书签等服务，并可播放圣经朗读音频。"]];

                UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                                 applicationActivities:nil];
                activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                             UIActivityTypePrint,];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:activityController  animated:YES completion:nil];
                });
                
            });
        } else if (indexPath.row == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://cathassist.org/3rd/aboutus.html"]];
        }
    }
}

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
