//
//  BALabel.m
//  Bible Assistant
//
//  Created by nixzhu on 14-3-19.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BALabel.h"
#import "UIView+BAAnimation.h"

@implementation BALabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self bounceLeftWithDuration:0.5 delay:0.4];
        NSLog(@"SB not go here?");
    }
    return self;
}

- (void)awakeFromNib
{
    //[self bounceLeftWithDuration:0.5 delay:0.4];
    //[self bounceRightWithDuration:0.5 delay:0.4];
    //[self bounceDownWithDuration:0.5 delay:0.4];
    //[self bounceUpWithDuration:0.5 delay:0.4];
    
    //[self slideLeftWithDuration:0.5 delay:0.4];
    //[self slideRightWithDuration:0.5 delay:0.4];
    //[self slideDownWithDuration:0.5 delay:0.4];
    //[self slideUpWithDuration:0.5 delay:0.4];
    
    [self fadeInWithDuration:1.0 delay:0.0];
    //[self fadeOutWithDuration:1.0 delay:0.5];
    //[self fadeInLeftWithDuration:1.0 delay:0.0];
    
    //[self popWithDuration:0.5 delay:0.5];
    //[self morphWithDuration:0.5 delay:0.5];
    //[self flashWithDuration:0.5 delay:0.5];
    //[self shakeWithDuration:1.0 delay:0.5];
    //[self zoomInWithDuration:1.0 delay:0.0];
    [self zoomOutWithDuration:1.0 delay:0.0];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
