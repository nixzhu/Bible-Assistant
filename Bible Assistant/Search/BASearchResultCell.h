//
//  BASearchResultCell.h
//  Bible Assistant
//
//  Created by nixzhu on 14-3-18.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BASearchResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *bibleTextView;

@end
