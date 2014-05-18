//
//  BAAudioSaver.h
//  Bible Assistant
//
//  Created by NIX on 14-3-30.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BibleAudio;

@interface BAAudioSaver : NSObject

+ (BOOL)saveAudio:(NSData*)audio ToDiskAndToBibleAudio:(BibleAudio*)bibleAudio;
+ (void)deleteAudioAtPath:(NSString*)path;

@end
