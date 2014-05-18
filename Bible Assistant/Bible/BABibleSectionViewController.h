//
//  BABibleSectionViewController.h
//  Bible Assistant
//
//  Created by NIX on 14-3-8.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Ono.h>

@interface BABibleSectionViewController : UIViewController

@property (nonatomic, strong) ONOXMLElement *volume;
@property (nonatomic, strong) ONOXMLElement *chapter;
@property (nonatomic, strong) NSDictionary *biblelLocation;


@end
