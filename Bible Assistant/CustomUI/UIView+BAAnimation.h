//
//  UIView+BAAnimation.h
//  Bible Assistant
//
//  Created by nixzhu on 14-3-19.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BAAnimation)

- (void)bounceLeftWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)bounceRightWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)bounceDownWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)bounceUpWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

- (void)slideLeftWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)slideRightWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)slideDownWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)slideUpWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

- (void)fadeInWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)fadeOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)fadeInLeftWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)fadeInRightWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)fadeInDownWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)fadeInUpWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

- (void)popWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)morphWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)flashWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)shakeWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)zoomInWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)zoomOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

@end
