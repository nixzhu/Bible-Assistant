//
//  BAAudioChpaterDelegate.h
//  Bible Assistant
//
//  Created by NIX on 14-3-30.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BAAudioChpaterDelegate <NSObject>

@required
- (void)beginDownload:(NSMutableDictionary *)cellInfo;

@end
