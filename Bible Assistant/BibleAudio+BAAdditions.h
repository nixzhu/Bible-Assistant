//
//  BibleAudio+BAAdditions.h
//  Bible Assistant
//
//  Created by NIX on 14-4-5.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BibleAudio.h"

@interface BibleAudio (BAAdditions)

+ (BOOL)isUserChooseAudioMale;
+ (NSString *)urlAttribute;
+ (BibleAudio *)bibleAudioWithVolume:(NSInteger)volume Chapter:(NSInteger)chapter;

+ (NSString *)femaleAudioURLStringWithVolume:(NSInteger)volume Chapter:(NSInteger)chapter;
+ (NSString *)maleAudioURLStringWithVolume:(NSInteger)volume Chapter:(NSInteger)chapter;

@end
