//
//  UIColor+AppColor.m
//  Bible Assistant
//
//  Created by NIX on 14-3-8.
//  Copyright (c) 2014年 nixWork. All rights reserved.
//

#import "UIColor+AppColor.h"

@implementation UIColor (AppColor)

+ (UIColor *)randomColor
{
    return [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1.0];
}

+ (UIColor *)coloredSectionColor
{
    return [UIColor colorWithRed:(57)/255.0 green:(202)/255.0 blue:(116)/255.0 alpha:1.0]; //EMERALD
}


+ (UIColor *)turquoiseColor
{
    return [UIColor colorWithRed:(41)/255.0 green:(187)/255.0 blue:(156)/255.0 alpha:1.0]; //TURQUOISE
}

+ (UIColor *)emeraldColor
{
    return [UIColor colorWithRed:(57)/255.0 green:(202)/255.0 blue:(116)/255.0 alpha:1.0]; //EMERALD
}

+ (UIColor *)peterRiverColor
{
    return [UIColor colorWithRed:(58)/255.0 green:(153)/255.0 blue:(216)/255.0 alpha:1.0]; //PETER RIVER
}

+ (UIColor *)amethystColor
{
    return [UIColor colorWithRed:(154)/255.0 green:(92)/255.0 blue:(180)/255.0 alpha:1.0]; //AMETHYST
}

+ (UIColor *)sunFlowerColor
{
    return [UIColor colorWithRed:(240)/255.0 green:(195)/255.0 blue:(48)/255.0 alpha:1.0]; //SUN FLOWER
}

+ (UIColor *)carrotColor
{
    return [UIColor colorWithRed:(228)/255.0 green:(126)/255.0 blue:(48)/255.0 alpha:1.0]; //CARROT
}

+ (UIColor *)alizarinColor
{
    return [UIColor colorWithRed:(229)/255.0 green:(77)/255.0 blue:(66)/255.0 alpha:1.0]; //ALIZARIN
}

+ (UIColor *)wetAsphaltColor
{
    return [UIColor colorWithRed:(53)/255.0 green:(73)/255.0 blue:(93)/255.0 alpha:1.0]; //WET ASPHALT
}

+ (UIColor *)lightPurpleColor
{
    return [UIColor colorWithRed:(196)/255.0 green:(68)/255.0 blue:(252)/255.0 alpha:1.0];
}

+ (UIColor *)greenSeaColor
{
    return [UIColor colorWithRed:(35)/255.0 green:(159)/255.0 blue:(133)/255.0 alpha:1.0]; //GREEN SEA
}

+ (UIColor *)lightGreenColor
{
    return [UIColor colorWithRed:(76)/255.0 green:(217)/255.0 blue:(100)/255.0 alpha:1.0];
}

+ (UIColor *)pumpkinColor
{
    return [UIColor colorWithRed:(209)/255.0 green:(84)/255.0 blue:(25)/255.0 alpha:1.0]; //PUMPKIN
}

+ (UIColor *)lightBlueColor
{
    return [UIColor colorWithRed:(90)/255.0 green:(200)/255.0 blue:(250)/255.0 alpha:1.0];
}

@end
