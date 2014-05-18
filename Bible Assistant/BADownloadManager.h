//
//  BADownloadManager.h
//  Bible Assistant
//
//  Created by NIX on 14-4-12.
//  Copyright (c) 2014年 nixWork. All rights reserved.

//  全局下载管理器，接口非常简单

#import <Foundation/Foundation.h>

@interface BADownloadManager : NSObject

+ (void)downloadItemWithWithVolume:(NSInteger)volume andChapter:(NSInteger)chapter;

@end
