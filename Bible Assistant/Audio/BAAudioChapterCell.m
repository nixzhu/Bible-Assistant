//
//  BAAudioChapterCell.m
//  Bible Assistant
//
//  Created by NIX on 14-3-30.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BAAudioChapterCell.h"

@interface BAAudioChapterCell()

@property (nonatomic, strong)  UITapGestureRecognizer *tapRecognizer;

@end

@implementation BAAudioChapterCell

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
    // add a pan recognizer
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    //recognizer.delegate = self;
    [self.progressView addGestureRecognizer:self.tapRecognizer];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    if (self.delegate) {
        //NSLog(@"cellInfo %@", self.cellInfo);
        [self.delegate beginDownload:self.cellInfo];
        //[self.progressView removeGestureRecognizer:self.tapRecognizer]; //防止再次点击
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
