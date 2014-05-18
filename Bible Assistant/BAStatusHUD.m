//
//  BAStatusHUD.m
//  Bible Assistant
//
//  Created by NIX on 14-4-27.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BAStatusHUD.h"
#import <MBProgressHUD.h>
#import "BAAppDelegate.h"

@implementation BAStatusHUD

+ (void)showHUDWithString:(NSString *)string andDisappearIn:(float)seconds
{
    BAAppDelegate *appDelegate = (BAAppDelegate *)[[UIApplication sharedApplication] delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.userInteractionEnabled = NO;
    hud.labelText = string;
    hud.mode = MBProgressHUDModeText;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [hud hide:YES];
    });
}

@end
