//
//  BibleAudio+BAAdditions.m
//  Bible Assistant
//
//  Created by NIX on 14-4-5.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "BibleAudio+BAAdditions.h"

@implementation BibleAudio (BAAdditions)

+ (BOOL)isUserChooseAudioMale
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *audioSex = [userDefaults objectForKey:@"audioSex"];
    if (audioSex && [audioSex isEqualToString:@"audioMale"]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)urlAttribute
{
    return [self isUserChooseAudioMale]? @"url_male" : @"url";
}

+ (BibleAudio *)bibleAudioWithVolume:(NSInteger)volume Chapter:(NSInteger)chapter
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"volume = %d AND chapter = %d", volume, chapter];
    BibleAudio *bibleAudio = [BibleAudio MR_findFirstWithPredicate:predicate];
    if (bibleAudio) {
        return bibleAudio;
    } else {
        return nil;
    }
}

+ (NSString *)femaleAudioURLStringWithVolume:(NSInteger)volume Chapter:(NSInteger)chapter
{
    return [NSString stringWithFormat:@"http://media.cathassist.org/bible/mp3/cn/female/%03d/%03d.mp3", volume+1, chapter+1];
}

+ (NSString *)maleAudioURLStringWithVolume:(NSInteger)volume Chapter:(NSInteger)chapter
{
    return [NSString stringWithFormat:@"http://media.cathassist.org/bible/mp3/cn/male/%03d/%03d.mp3", volume+1, chapter+1];
}

@end
