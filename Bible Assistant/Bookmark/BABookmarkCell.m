//
//  BABookmarkCell.m
//  Bible Assistant
//
//  Created by nixzhu on 14-3-27.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BABookmarkCell.h"

@implementation BABookmarkCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
