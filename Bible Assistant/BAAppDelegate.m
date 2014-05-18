//
//  BAAppDelegate.m
//  Bible Assistant
//
//  Created by NIX on 14-3-8.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BAAppDelegate.h"
#import "BAAudioPlayer.h"

@import AVFoundation;

@implementation BAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //[[UITabBar appearance] setTintColor:[UIColor emeraldColor]];
    
    // 冷启动时的背景 View，设置为和 LaunchImage 一样的颜色；默认的 rootViewController.view 慢慢出现，看起来比较平滑
    self.window.rootViewController.view.alpha = 0;
    UIView *splashView = [[UIView alloc] initWithFrame:self.window.frame];
    splashView.backgroundColor = [UIColor colorWithRed:145/255.0 green:211/255.0 blue:44/255.0 alpha:1.0];
    [self.window addSubview:splashView];
    [UIView animateWithDuration:0.7 animations:^{
        self.window.rootViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [splashView removeFromSuperview];
    }];
    
    
    // 设置 UITabBarController 的 UITabBarItem 选中状态的图片（普通状态在 Storyboard 里已经设置）
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UITabBarItem *tabBarItem1 = [tabBarController.tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBarController.tabBar.items objectAtIndex:1];
    //UITabBarItem *tabBarItem3 = [tabBarController.tabBar.items objectAtIndex:2]; // 这个是搜索，使用系统原生的搜索
    UITabBarItem *tabBarItem4 = [tabBarController.tabBar.items objectAtIndex:3];
    UITabBarItem *tabBarItem5 = [tabBarController.tabBar.items objectAtIndex:4];
    
    tabBarItem1.selectedImage = [UIImage imageNamed:@"s_bible_selected"];
    tabBarItem2.selectedImage = [UIImage imageNamed:@"leaf_selected"];
    //tabBarItem3.selectedImage = [UIImage imageNamed:@"search-selected.png"];
    tabBarItem4.selectedImage = [UIImage imageNamed:@"audio_list_selected"];
    tabBarItem5.selectedImage = [UIImage imageNamed:@"settings_selected"];
    
    
    // Set AudioSession 以支持后台播放
    NSError *sessionError = nil;
    //[[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    
    /* Pick any one of them */
    // 1. Overriding the output audio route
    //UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    //AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    // 2. Changing the default output audio route
    //UInt32 doChangeDefaultRoute = 1;
    //AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    [[AVAudioSession sharedInstance] setActive: YES error:NULL];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    // 设置 Core Data
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"BAModel"];
    
    // 监听自动播放下一章
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNextChapter:) name:@"playNextChapter" object:nil];
    
    return YES;
}

- (void)playNextChapter:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    NSNumber *volumeNum = dic[@"volumeNum"];
    NSNumber *chapterNum = dic[@"chapterNum"];
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    UINavigationController *navVC = (UINavigationController *)tabBarController.selectedViewController;
    [navVC popToRootViewControllerAnimated:NO]; //防止圣经已经push到章后，下面的跳转导致再次push到圣经（root 卷 章 卷 章）
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BibleGotoVolume" object:nil userInfo:@{@"volume":volumeNum, @"chapter":chapterNum, @"section":@0, @"autoPlayAudio":@(YES)}];
}


// 处理锁屏界面的操作/耳机操作
- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent
{
    if (theEvent.type == UIEventTypeRemoteControl) {
        switch(theEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            case UIEventSubtypeRemoteControlPlay:
            case UIEventSubtypeRemoteControlPause:
                [BAAudioPlayer playOrPause];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [BAAudioPlayer tryPlayNextChapter];
                break;
                
            default:
                return;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // 在进入后台前发个通知，有些地方需要保持状态
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidEnterBackground" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 读取 bible.xml 文件，做成 ONOXMLDocument 供应用全局使用，这样内存效率会比较好
- (ONOXMLDocument *)bible
{
    if (!_bible) {
        NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"bible" ofType:@"xml"];
        NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
        NSError *error;
        _bible = [ONOXMLDocument XMLDocumentWithData:xmlData error:&error];
    }
    return _bible;
}

@end
