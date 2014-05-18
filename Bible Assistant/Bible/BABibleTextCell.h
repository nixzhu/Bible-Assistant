//
//  BABibleTextCell.h
//  Bible Assistant
//
//  Created by NIX on 14-3-8.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BABibleTextCellDelegate.h"

@interface BABibleTextCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, weak) id<BABibleTextCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *sectionNumLabel;
@property (weak, nonatomic) IBOutlet UITextView *bibleTextView;
@property (weak, nonatomic) IBOutlet UIView *isInBookmarksView;

@end
