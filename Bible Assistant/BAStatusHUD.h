//
//  BAStatusHUD.h
//  Bible Assistant
//
//  Created by NIX on 14-4-27.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BAStatusHUD : NSObject

+ (void)showHUDWithString:(NSString *)string andDisappearIn:(float)seconds;

@end
