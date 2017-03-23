//
//  NSString+Size.m
//  BaseShell
//
//  Created by yafu on 15/11/5.
//  Copyright © 2015年 fuya. All rights reserved.
//

#import "NSString+Size.h"

#define SystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]

@implementation NSString (Size)

- (CGSize)sizeWithFont:(UIFont *)font size:(CGSize)size
{
    CGSize sizeToFit = CGSizeZero;
    
    if (SystemVersion>7.0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary *attributes = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName : paragraphStyle };
        // 计算文本的大小
        sizeToFit = [self boundingRectWithSize:size
                                               options:NSStringDrawingUsesLineFragmentOrigin                                             attributes:attributes
                                            context:nil].size;
    }
    else
    {
        sizeToFit = [self sizeWithFont:font
                     constrainedToSize:size
                         lineBreakMode:NSLineBreakByWordWrapping];

    }
    return sizeToFit;
}

@end
