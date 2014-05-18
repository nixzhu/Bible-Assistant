//
//  BAAppDelegate.h
//  Bible Assistant
//
//  Created by NIX on 14-3-8.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Ono.h>

@import AVFoundation;

@interface BAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) ONOXMLDocument *bible;

@property (nonatomic, strong) AVPlayer *onlinePlayer;
@property (nonatomic, strong) AVAudioPlayer *localPlayer;

@end
