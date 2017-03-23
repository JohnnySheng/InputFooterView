//
//  UIColor+MyColor.m
//  MPlatform
//
//  Created by ya fu on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIColor+MyColor.h"

@implementation UIColor (MyColor)
+ (UIColor *) colorWithHexString: (NSString *) inColorString
{
//    int r=0,g=0,b=0;
//    char cString = [stringToConvert cStringUsingEncoding:NSUTF8StringEncoding];
//
//    return [UIColor colorWithRed:((float) r / 255.0f)
//                           green:((float) g / 255.0f)
//                            blue:((float) b / 255.0f)
//                           alpha:1.0f];
    
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if ([inColorString hasPrefix:@"#"]) inColorString = [inColorString substringFromIndex:1];
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;

}
@end
