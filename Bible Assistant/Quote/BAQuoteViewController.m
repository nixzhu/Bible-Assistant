//
//  BAQuoteViewController.m
//  Bible Assistant
//
//  Created by NIX on 14-3-10.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BAQuoteViewController.h"
#import "BAAppDelegate.h"
#import <Ono.h>
//#import "BALabel.h"

@interface BAQuoteViewController ()

@property (weak, nonatomic) IBOutlet UIView *quoteBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *chapterLabel;
@property (weak, nonatomic) IBOutlet UITextView *sectionTextView;
@property (weak, nonatomic) IBOutlet UIButton *gotoButton;
@property (weak, nonatomic) IBOutlet UIButton *randomButton;

@property (nonatomic, strong) NSNumber *volume;
@property (nonatomic, strong) NSNumber *chapter;
@property (nonatomic, strong) NSNumber *section;

@end

@implementation BAQuoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.volumeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.chapterLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.sectionTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.quoteBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"creampaper"]];
    
    self.quoteBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.quoteBackgroundView.layer.shadowOpacity = 0.9f;
    self.quoteBackgroundView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.quoteBackgroundView.layer.shadowRadius = 4.0f;
    self.quoteBackgroundView.layer.masksToBounds = NO;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.quoteBackgroundView.bounds];
    self.quoteBackgroundView.layer.shadowPath = path.CGPath;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.volumeLabel.text = @"";
    self.chapterLabel.text = @"";
    self.sectionTextView.text = @"";
    
#if 0 /* 看看到底有多少section */
    ONOXMLDocument *bible = ((BAAppDelegate *)[[UIApplication sharedApplication] delegate]).bible;
    //NSLog(@"bible.rootElement.children.count: %d", bible.rootElement.children.count);

    int allSection = 0;
    
    NSMutableString *mutableString = [NSMutableString stringWithString:@"\n"];
    
    int numVolume = 0;
    NSString *volumeTitle = @"";
    for (ONOXMLElement *element in bible.rootElement.children) {
        if ([element.tag isEqualToString:@"template"]) {
            numVolume++;
            
            NSString *title = element.attributes[@"title"];
            NSArray *parts = [title componentsSeparatedByString:@" "];
            if (parts.count > 1) { // 2 or 3
                volumeTitle = parts[1];
            }
            
            int numChapter = 0;
            for (ONOXMLElement *elementChapter in element.children) {
                if ([elementChapter.tag isEqualToString:@"chapter"]) {
                    numChapter++;
                    
                    //int numSection = 0;
                    for (ONOXMLElement *elementSection in elementChapter.children) {
                        if ([elementSection.tag isEqualToString:@"section"]) {
                            //numSection++;
                            allSection++;
                        }
                    }
                    //NSLog(@"numSection: %d", numSection);
                }
            }
            //NSLog(@"numChapter: %d", numChapter);
            [mutableString appendString:[NSString stringWithFormat:@"@{@\"index\":@%d, @\"name\":@\"%@\", @\"chapterNum\":@%d},\n", numVolume-1, volumeTitle, numChapter]];
        }

    }
    //NSLog(@"numVolume: %d", numVolume);
    NSLog(@"allSection: %d", allSection); //35751
    
    NSLog(@"%@", mutableString);
#endif
    
    [self randomNextSection];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    [self.view setNeedsLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gotoBibleSection:(UIButton *)sender {
    self.tabBarController.selectedViewController= [self.tabBarController.viewControllers objectAtIndex:0];

    UINavigationController *navVC = (UINavigationController *)self.tabBarController.selectedViewController;
    [navVC popToRootViewControllerAnimated:NO]; //防止圣经已经push到章后，下面的跳转导致再次push到圣经（root 卷 章 卷 章）
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BibleGotoVolume" object:nil userInfo:@{@"volume":self.volume, @"chapter":self.chapter, @"section":self.section}];
}

- (void)randomNextSection {
    ONOXMLDocument *bible = ((BAAppDelegate *)[[UIApplication sharedApplication] delegate]).bible;
    
    int randomSection = arc4random() % 35751;
    int indexOfAllSection = 0;
    int indexOfVolume = 0;
    int indexOfChapter = 0;
    int indexOfSection = 0;

    ONOXMLElement *choosedVolume;
    ONOXMLElement *choosedChapter;
    ONOXMLElement *choosedSection;
    for (ONOXMLElement *element in bible.rootElement.children) {
        if ([element.tag isEqualToString:@"template"]) {
            choosedVolume = element;
            indexOfChapter = 0;
            for (ONOXMLElement *elementChapter in element.children) {
                if ([elementChapter.tag isEqualToString:@"chapter"]) {
                    choosedChapter = elementChapter;
                    indexOfSection = 0;
                    
                    for (ONOXMLElement *elementSection in elementChapter.children) {
                        if ([elementSection.tag isEqualToString:@"section"]) {
                            if (indexOfAllSection == randomSection) {
                                choosedSection = elementSection;
                                goto OUT;
                            }
                            //indexOfSection++;
                            indexOfAllSection++;
                        }
                        indexOfSection++; //这里就是包括计入fakeTitle
                    }
                    indexOfChapter++;
                }
            }
            indexOfVolume++;
        }
        
    }
OUT:
    //NSLog(@"%d, %d, %d, %d", indexOfVolume, indexOfChapter, indexOfSection, indexOfAllSection);
    self.volume = @(indexOfVolume);
    self.chapter = @(indexOfChapter);
    self.section = @(indexOfSection);
    
    dispatch_async(dispatch_queue_create("rander", NULL), ^{
        
        NSString *title = choosedVolume.attributes[@"title"];
        NSArray *parts = [title componentsSeparatedByString:@" "];
        if (parts.count > 1) { // 2 or 3
            NSString *volumeTitle = parts[1];
            
            UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            UIColor *textColor = [UIColor wetAsphaltColor];
            
            NSDictionary *attrs = @{NSForegroundColorAttributeName: textColor,
                                    NSFontAttributeName: font,
                                    NSTextEffectAttributeName: NSTextEffectLetterpressStyle};
            
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:volumeTitle attributes:attrs];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.volumeLabel.attributedText = attrString;
            });
        }
        
        if (choosedChapter.attributes[@"title"] && choosedSection.attributes[@"value"]) {
            UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
            UIColor *textColor = [UIColor sunFlowerColor];
            
            NSDictionary *attrs = @{NSForegroundColorAttributeName: textColor,
                                    NSFontAttributeName: font,
                                    NSTextEffectAttributeName: NSTextEffectLetterpressStyle};
            NSString *string = [NSString stringWithFormat:@"%@ %@", choosedChapter.attributes[@"title"], choosedSection.attributes[@"value"]];
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attrs];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.chapterLabel.attributedText = attrString;
            });
        }
        
        if (choosedSection.stringValue) {
            //UIBezierPath *exclusionPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(50, 0, 70, 50)];
            //self.sectionTextView.textContainer.exclusionPaths = @[exclusionPath];
            
            UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            UIColor *textColor = [UIColor emeraldColor];
            
            NSDictionary *attrs = @{NSForegroundColorAttributeName: textColor,
                                    NSFontAttributeName: font,
                                    NSTextEffectAttributeName: NSTextEffectLetterpressStyle};
            
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:choosedSection.stringValue attributes:attrs];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sectionTextView.attributedText = attrString;
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.gotoButton.enabled = YES;
            self.randomButton.enabled = YES;
        });
        
    });

    //NSLog(@"%@, %@, %@", choosedVolume.attributes[@"title"], choosedChapter.attributes[@"title"], choosedSection.attributes[@"value"]);
}

- (IBAction)randomNextSection:(UIButton *)sender {
    [self randomNextSection];
}

@end
