//
//  BABookmarksViewController.h
//  Bible Assistant
//
//  Created by nixzhu on 14-3-27.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bookmark.h"

typedef void(^DismissWithSelection)(Bookmark *bookmark);

@interface BABookmarksViewController : UIViewController

@property (nonatomic, copy) DismissWithSelection dismissWithSelection;

@end
