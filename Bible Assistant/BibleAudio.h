//
//  BibleAudio.h
//  Bible Assistant
//
//  Created by NIX on 14-4-5.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BibleAudio : NSManagedObject

@property (nonatomic, retain) NSString * audio;
@property (nonatomic, retain) NSNumber * chapter;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) NSString * url_male;
@property (nonatomic, retain) NSString * audio_male;

@end
