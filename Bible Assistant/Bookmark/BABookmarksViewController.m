//
//  BABookmarksViewController.m
//  Bible Assistant
//
//  Created by nixzhu on 14-3-27.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BABookmarksViewController.h"
#import "BABookmarkCell.h"

@interface BABookmarksViewController () <UITabBarDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *bookmarksTableView;
@property (nonatomic) NSMutableArray *bookmarks;

@end

@implementation BABookmarksViewController


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    //[self.bookmarksTableView setNeedsLayout];
    [self.bookmarksTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissBookmarkets:(UIBarButtonItem *)sender {
    if (self.dismissWithSelection) {
        self.dismissWithSelection(NULL);
    }
}

- (NSMutableArray *)bookmarks {
    if (!_bookmarks) {
        _bookmarks = [[Bookmark MR_findAll] mutableCopy];
    }
    return _bookmarks;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bookmarks.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BABookmarkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BABookmarkCell" forIndexPath:indexPath];
    
    Bookmark *bookmark = self.bookmarks[indexPath.row];
    
    cell.locationLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    cell.locationLabel.text = [NSString stringWithFormat:@"%@ %@ %@", bookmark.volumeTitle, bookmark.chapterTitle, bookmark.sectionNum];
    
    cell.bibleTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.bibleTextView.text = bookmark.text;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Bookmark *bookmark = self.bookmarks[indexPath.row];
    if (self.dismissWithSelection) {
        self.dismissWithSelection(bookmark);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Bookmark *bookmark = self.bookmarks[indexPath.row];
	NSString *codename = bookmark.text;
	CGRect codenameRect = [codename
                           boundingRectWithSize:CGSizeMake(
                                                           CGRectGetWidth(CGRectIntegral(tableView.bounds)) - 30, //20 + 5 + 5 // left and right padding
                                                           MAXFLOAT) // 40 = 20pt horizontal padding on each side
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}
                           context:nil];
    
	return MAX(44.0f, CGRectGetHeight(CGRectIntegral(codenameRect)) + 30 + 15);
}

#pragma mark - UITableView Delegate

- (void)saveContext {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            //NSLog(@"You successfully saved your context.");
        } else if (error) {
            NSLog(@"Bookmarks Error saving context: %@", error.description);
        }
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Bookmark *bookmarkToDelete = self.bookmarks[indexPath.row];
        [bookmarkToDelete MR_deleteEntity];
        [self saveContext];
        
        [self.bookmarks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
