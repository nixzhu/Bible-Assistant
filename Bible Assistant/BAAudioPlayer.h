//
//  BAAudioPlayer.h
//  Bible Assistant
//
//  Created by NIX on 14-4-21.
//  Copyright (c) 2014年 nixWork. All rights reserved.

// 全局音频播放

#import <Foundation/Foundation.h>

@interface BAAudioPlayer : NSObject

+ (void)playAudioWithVolume:(NSInteger)volume Chapter:(NSInteger)chapter;
+ (void)playOrPause;

+ (BOOL)isPlaying;
+ (BOOL)isPlayingVolume:(NSInteger)volume Chapter:(NSInteger)chapter;
+ (void)tryPlayNextChapter;

@end
