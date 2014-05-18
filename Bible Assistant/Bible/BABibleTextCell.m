//
//  BABibleTextCell.m
//  Bible Assistant
//
//  Created by NIX on 14-3-8.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BABibleTextCell.h"
#import "UIColor+AppColor.h"

@interface BABibleTextCell() <UIGestureRecognizerDelegate>

@end

@implementation BABibleTextCell {
    UILabel* _leftLabel;
    UILabel* _rightLabel;
    
    bool _leftOnDragRelease;
    bool _rightOnDragRelease;
    CGPoint _originalCenter;
}

const float LABEL_LEFT_MARGIN = 15.0f;
const float UI_CUES_MARGIN = 10.0f;
const float UI_CUES_WIDTH = 80.0f;

// utility method for creating the contextual cues
- (UILabel*) createCueLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectNull];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:17.0];
    //label.backgroundColor = [UIColor clearColor];
    return label;
}

- (void) setCueAlpha:(float)alpha
{
    _leftLabel.alpha = alpha;
    _rightLabel.alpha = alpha;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self.contentView.superview setClipsToBounds:NO]; // 若没有这句，在 iOS 7.1 下正常，7.0 下滑动看不到书签信息 http://www.raywenderlich.com/21842/how-to-make-a-gesture-driven-to-do-list-app-part-13
        
        _leftLabel = [self createCueLabel];
        _leftLabel.text = @"取消书签";
        _leftLabel.textAlignment = NSTextAlignmentCenter;
        _leftLabel.backgroundColor = [UIColor alizarinColor];
        [self addSubview:_leftLabel];
        
        _rightLabel = [self createCueLabel];
        _rightLabel.text = @"分享";
        _rightLabel.textAlignment = NSTextAlignmentCenter;
        _rightLabel.backgroundColor = [UIColor orangeColor];
        [self addSubview:_rightLabel];
        
        // add a pan recognizer
        UIGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        recognizer.delegate = self;
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    _leftLabel.frame = CGRectMake(-UI_CUES_WIDTH - UI_CUES_MARGIN, 0,
                                  UI_CUES_WIDTH, self.bounds.size.height);
    _rightLabel.frame = CGRectMake(self.bounds.size.width + UI_CUES_MARGIN, 0,
                                   UI_CUES_WIDTH, self.bounds.size.height);
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) { //避免 http://stackoverflow.com/questions/16239143/uilongpressgesturerecognizer-crashes-even-if-not-implemented
        CGPoint translation = [gestureRecognizer translationInView:[self superview]];
        
        // Check for horizontal gesture
        if (fabsf(translation.x) > fabsf(translation.y)) {
            return YES;
        }
    }
    
    return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    // if the gesture has just started, record the current centre location
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _originalCenter = self.center;
        if (self.info[@"isInBookmarks"] && [self.info[@"isInBookmarks"] boolValue] ) {
            _leftLabel.backgroundColor = [UIColor alizarinColor];
        } else {
            _leftLabel.backgroundColor = [UIColor emeraldColor];
        }
    }
    
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // translate the center
        CGPoint translation = [recognizer translationInView:self];
        
        //if (translation.x < 0) {
            self.center = CGPointMake(_originalCenter.x + translation.x, _originalCenter.y);
        //}
        
        
        // determine whether the item has been dragged far enough to initiate a delete / complete
        _leftOnDragRelease = self.frame.origin.x > self.frame.size.width / 3;
        _rightOnDragRelease = self.frame.origin.x < -self.frame.size.width / 3;
        
        // fade the contextual cues
        float cueAlpha = fabsf(self.frame.origin.x) / (self.frame.size.width / 4);
        [self setCueAlpha:cueAlpha];
        
        // indicate when the item have been pulled far enough to invoke the given action
        //_leftLabel.textColor = _leftOnDragRelease ? [UIColor emeraldColor] : [UIColor whiteColor];
        //_rightLabel.textColor = _rightOnDragRelease ? [UIColor alizarinColor] : [UIColor whiteColor];
        
#if 1
        if (self.info[@"isInBookmarks"] && [self.info[@"isInBookmarks"] boolValue] ) {
            _leftLabel.text = _leftOnDragRelease ? @"\u2717" : @"删除书签";
            //_leftLabel.backgroundColor = [UIColor alizarinColor];
        } else {
            _leftLabel.text = _leftOnDragRelease ? @"\u2713" : @"添加书签";
            //_leftLabel.backgroundColor = [UIColor emeraldColor];
        }
        _leftLabel.font = _leftOnDragRelease ? [UIFont boldSystemFontOfSize:48.0] : [UIFont boldSystemFontOfSize:17.0];
        
        _rightLabel.text = _rightOnDragRelease ? @"\u2713" : @"分享";
        _rightLabel.font = _rightOnDragRelease ? [UIFont boldSystemFontOfSize:48.0] : [UIFont boldSystemFontOfSize:17.0];
#else
        _leftLabel.text = _leftOnDragRelease ? @"\u2717" : @"删除书签";
        _rightLabel.text = _rightOnDragRelease ? @"\u2713" : @"添加书签";
        
        _leftLabel.font = _leftOnDragRelease ? [UIFont boldSystemFontOfSize:48.0] : [UIFont boldSystemFontOfSize:17.0];
        _rightLabel.font = _rightOnDragRelease ? [UIFont boldSystemFontOfSize:48.0] : [UIFont boldSystemFontOfSize:17.0];
#endif
    }
    
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // the frame this cell would have had before being dragged
        CGRect originalFrame = CGRectMake(0, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
        
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = originalFrame;
        }];
        
        if (_leftOnDragRelease) {
            if (self.info[@"isInBookmarks"] && [self.info[@"isInBookmarks"] boolValue] ) {
                [self.delegate deleteBookmark:self.info];
            } else {
                [self.delegate addBookmark:self.info];
            }
        }
        
        if (_rightOnDragRelease) {
            [self.delegate shareSection:self.info];
        }

    }
    
}

@end
