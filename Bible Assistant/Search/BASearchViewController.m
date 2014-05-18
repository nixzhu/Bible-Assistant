//
//  BASearchViewController.m
//  Bible Assistant
//
//  Created by nixzhu on 14-3-18.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BASearchViewController.h"
#import "BASearchResultCell.h"
#import "BAAppDelegate.h"
#import <Ono.h>

@interface BASearchViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *bibleSearchBar;
@property (nonatomic, strong) NSMutableArray *bibleSearchResults;
//@property (nonatomic, strong) BASearchResultCell *prototypeCell;

@end

@implementation BASearchViewController

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
    // Do any additional setup after loading the view.
    
    //[self searchBibleWithString:@"耶稣"];
    
    //弹出键盘，等待用户输入
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bibleSearchBar becomeFirstResponder];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    //self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"BASearchResultCell"];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)bibleSearchResults
{
    if (!_bibleSearchResults) {
        _bibleSearchResults = [NSMutableArray array];
    }
    return _bibleSearchResults;
}

- (void)searchBibleWithString:(NSString *)string {
    if (_bibleSearchResults.count > 0) {
        _bibleSearchResults = [NSMutableArray array]; //每次搜索都先清空
    }
    
    ONOXMLDocument *bible = ((BAAppDelegate *)[[UIApplication sharedApplication] delegate]).bible;
    
    for (ONOXMLElement *element in bible.rootElement.children) {
        if ([element.tag isEqualToString:@"template"]) {
            NSString *volumeTitle = element.attributes[@"name"];
            NSString *volumeBigTitle = element.attributes[@"sname"];
            
            NSString *volumeNum = element.attributes[@"value"];
            
            NSMutableArray *volumeChapters = [NSMutableArray array];
            
            for (ONOXMLElement *elementChapter in element.children) {
                if ([elementChapter.tag isEqualToString:@"chapter"]) {
                    
                    NSString *chapterTitle = elementChapter.attributes[@"title"];
                    NSString *chapterNum = elementChapter.attributes[@"value"];
                    
                    NSInteger sectionNum = 0;
                    for (ONOXMLElement *elementSection in elementChapter.children) {
                        if ([elementSection.tag isEqualToString:@"section"]) {
                            
                            NSString *bibleText = elementSection.stringValue;
                            if ([bibleText rangeOfString:string].location != NSNotFound) {
                                
                                NSString *sectionNumText = elementSection.attributes[@"value"];
                                [volumeChapters addObject:@{@"volume":volumeTitle,
                                                            @"volumeNum":volumeNum,
                                                            @"chapter":chapterTitle,
                                                            @"chapterNum":chapterNum,
                                                            @"sectionNum":@(sectionNum),
                                                            @"sectionNumText":sectionNumText,
                                                            @"text":bibleText}];
                            }
                        }
                        sectionNum++;
                    }
                }
            }
            if (volumeChapters.count > 0) {
                [self.bibleSearchResults addObject:@{@"volumeChapters": volumeChapters, @"volumeBigTitle": volumeBigTitle}];
            }
            
        }
    }
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 1;
    //NSLog(@"self.bibleSearchResults.count %d", self.bibleSearchResults.count);
    return self.bibleSearchResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return self.bibleSearchResults.count;
    NSDictionary *volume = self.bibleSearchResults[section];
    NSArray *volumeChapters = volume[@"volumeChapters"];
    
    //NSLog(@"section %d volumeChapters.count %d", section, volumeChapters.count);
    return volumeChapters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //NSDictionary *resultDic = self.bibleSearchResults[indexPath.row];
    NSDictionary *volume = self.bibleSearchResults[indexPath.section];
    NSArray *volumeChapters = volume[@"volumeChapters"];
    NSDictionary *resultDic = volumeChapters[indexPath.row];
    
    //NSLog(@"resultDic %@", resultDic);
    
    BASearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BASearchResultCell" forIndexPath:indexPath];
    
    cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@ %@", resultDic[@"volume"], resultDic[@"chapter"] ,resultDic[@"sectionNumText"]];//resultDic[@"volume"];
    
    cell.bibleTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

#if 0
    cell.bibleTextView.text = resultDic[@"text"];
#else
    NSString *text = resultDic[@"text"];
    NSDictionary *attrs = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]};
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attrs];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(%@)", self.bibleSearchBar.text] options:kNilOptions error:nil];

    NSRange range = NSMakeRange(0, text.length);
    
    [regex enumerateMatchesInString:text options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange subStringRange = [result rangeAtIndex:1];
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor alizarinColor] range:subStringRange];
    }];
    
    cell.bibleTextView.attributedText = mutableAttributedString;
#endif
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

#if 1
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSString *codename = self.bibleSearchResults[indexPath.row][@"text"];
    NSDictionary *volume = self.bibleSearchResults[indexPath.section];
    NSArray *volumeChapters = volume[@"volumeChapters"];
    NSDictionary *resultDic = volumeChapters[indexPath.row];
    NSString *codename = resultDic[@"text"];
    
	CGRect codenameRect = [codename
                           boundingRectWithSize:CGSizeMake(
                                                           CGRectGetWidth(CGRectIntegral(tableView.bounds)) - 30 - 30, // 20 + 5 + 5, 30(28) section index width
                                                           MAXFLOAT) // 40 = 20pt horizontal padding on each side
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}
                           context:nil];
    
	return MAX(44.0f, CGRectGetHeight(CGRectIntegral(codenameRect)) + 30 + 15);
}
#else
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BASearchResultCell *cell = self.prototypeCell;
    
    NSDictionary *volume = self.bibleSearchResults[indexPath.section];
    NSArray *volumeChapters = volume[@"volumeChapters"];
    NSDictionary *resultDic = volumeChapters[indexPath.row];
    NSString *bibleText = resultDic[@"text"];
    
    cell.bibleTextView.text = bibleText;
    cell.bibleTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGSize textViewSize = [cell.bibleTextView sizeThatFits:CGSizeMake(cell.bibleTextView.frame.size.width-20, FLT_MAX)];
    CGFloat h = size.height + textViewSize.height;
    NSLog(@"index %d, s.h=%f, h=%f", indexPath.row, size.height, h);
    return 1 + MAX(h, 44.0f);
}
#endif

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
    
    //NSDictionary *resultDic = self.bibleSearchResults[indexPath.row];
    NSDictionary *volume = self.bibleSearchResults[indexPath.section];
    NSArray *volumeChapters = volume[@"volumeChapters"];
    NSDictionary *resultDic = volumeChapters[indexPath.row];
    
    NSNumber *volumeNum = @([resultDic[@"volumeNum"] integerValue] - 1);
    NSNumber *chapterNum = @([resultDic[@"chapterNum"] integerValue] - 1);
    NSNumber *sectionNum = @([resultDic[@"sectionNum"] integerValue] - 0);
    
    UINavigationController *navVC = (UINavigationController *)self.tabBarController.selectedViewController;
    [navVC popToRootViewControllerAnimated:NO]; //防止圣经已经push到章后，下面的跳转导致再次push到圣经（root 卷 章 卷 章）
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BibleGotoVolume" object:nil userInfo:@{@"volume":volumeNum, @"chapter":chapterNum, @"section":sectionNum}];

}

//设置表格的索引数组
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *sectionIndexTitles = [NSMutableArray array];
    
    for (NSDictionary *volume in self.bibleSearchResults) {
        [sectionIndexTitles addObject:volume[@"volumeBigTitle"]];
    }
    
    return [sectionIndexTitles copy];
}

#pragma mark - 实现键盘上Search按钮的方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //NSLog(@"您点击了键盘上的Search按钮");
    [searchBar resignFirstResponder];
    [self searchBibleWithString:searchBar.text];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        //[self.tableView setContentOffset:CGPointMake(0, self.navigationController.navigationBar.frame.size.height) animated:YES];
        if (self.bibleSearchResults.count > 0) {
            //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            //TODO 上面这句有缺陷吗？
        }
    });
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

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
