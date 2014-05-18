//
//  Bookmark.h
//  Bible Assistant
//
//  Created by NIX on 14-4-5.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bookmark : NSManagedObject

@property (nonatomic, retain) NSNumber * chapter;
@property (nonatomic, retain) NSString * chapterTitle;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * section;
@property (nonatomic, retain) NSString * sectionNum;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) NSString * volumeTitle;

@end
