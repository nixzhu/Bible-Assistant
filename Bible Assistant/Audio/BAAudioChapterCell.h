//
//  BAAudioChapterCell.h
//  Bible Assistant
//
//  Created by NIX on 14-3-30.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FFCircularProgressView.h>
#import "BAAudioChpaterDelegate.h"

@interface BAAudioChapterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *chapterLabel;
@property (weak, nonatomic) IBOutlet FFCircularProgressView *progressView;

@property (nonatomic, weak) NSMutableDictionary *cellInfo;
@property (nonatomic, weak) id<BAAudioChpaterDelegate> delegate;

@end
