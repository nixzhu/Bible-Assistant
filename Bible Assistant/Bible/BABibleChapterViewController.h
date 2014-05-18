//
//  BABibleChapterViewController.h
//  Bible Assistant
//
//  Created by NIX on 14-3-8.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Ono.h>

@interface BABibleChapterViewController : UICollectionViewController

@property (nonatomic, strong) UIColor *cellColor;
@property (nonatomic, strong) ONOXMLElement *volume;
@property (nonatomic, assign) NSInteger volumeNum;
@property (nonatomic, strong) NSDictionary *gotoDict;

@end
