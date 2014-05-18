//
//  BABibleTextCellDelegate.h
//  Bible Assistant
//
//  Created by NIX on 14-3-25.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BABibleTextCellDelegate <NSObject>

@required
- (void)addBookmark:(NSDictionary *)info;
- (void)deleteBookmark:(NSDictionary *)info;
- (void)shareSection:(NSDictionary *)info;

@end
