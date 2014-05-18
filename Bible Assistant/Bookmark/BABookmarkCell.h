//
//  BABookmarkCell.h
//  Bible Assistant
//
//  Created by nixzhu on 14-3-27.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BABookmarkCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextView *bibleTextView;

@end
