//
//  FUTextView.m
//  DemoForHR
//
//  Created by "" on 14-8-12.
//  Copyright (c) 2014年 fuya. All rights reserved.
//

#import "FUTextView.h"
#import "NSString+Size.h"
//#import "FUChatConstant.h"

@implementation FUTextView

//设置文字内容
- (void)setText:(NSString *)text
{
    [super setText:text];
}


//设置文字的字体
-(void)setTextFont:(UIFont *)font
{
    [super setFont:font];
}

- (void)setContentOffset:(CGPoint)s
{
    if (self.text.length<1) {
        s.y=0;
    }
    [super setContentOffset:CGPointMake(0, s.y)];
//	if (self.tracking || self.decelerating)
//    {
//		//initiated by user...
//        self.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);//UIEdgeInsetsZero;
//	}
//    else
//    {
//		float bottomOffset = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom);
//		if (s.y < bottomOffset && self.scrollEnabled)
//        {
//			self.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
//		}
//        else
//        {
//            s = CGPointMake(0, 2);
//        }
//	}
//	
//	[super setContentOffset:s];
}

- (void)setContentInset:(UIEdgeInsets)s
{
	[super setContentInset:s];
}


-(void)setIsShowPlaceHolder:(BOOL)isShowPlaceHolder
{
    if(_isShowPlaceHolder == isShowPlaceHolder && _isShowPlaceHolder == NO)
        return;
    
    _isShowPlaceHolder = isShowPlaceHolder;
    
    if(_placeHoldLabel)
    {
        [_placeHoldLabel setHidden:!_isShowPlaceHolder];
    }
    
    if(_isShowPlaceHolder)
    {
        CGRect pFrame = self.bounds;
        pFrame.origin.x += 10;
        pFrame.size.width -= 10;
        pFrame.size.height = 35;
        [_placeHoldLabel setFrame:pFrame];
        [_placeHoldLabel setHidden:NO];
    }
}

- (void)createPlaceHolder
{
    if(_placeHoldLabel == nil)
    {
        CGRect pFrame = self.bounds;
        pFrame.origin.x += 10;
        pFrame.size.width -= 10;
        pFrame.size.height = 30;
        _placeHoldLabel = [[UILabel alloc] initWithFrame:pFrame];
        [_placeHoldLabel setTextColor:[UIColor lightGrayColor]];
        [_placeHoldLabel setBackgroundColor:[UIColor clearColor]];
        [_placeHoldLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_placeHoldLabel];
        _isShowPlaceHolder = YES;
    }
}

-(void)setPlaceHolder:(NSString*)text
{
    [self createPlaceHolder];
    [_placeHoldLabel setText:text];
}


//设置默认的文字的字体
-(void)setPlaceHolderFont:(UIFont *)font
{
    [self createPlaceHolder];
    [_placeHoldLabel setFont:font];
}


//设置隐含链接地址
- (void)setlinkUrl:(NSString *)url
{
    _linkUrl = url;
}

//获取隐含链接地址
- (NSString *)getLinkUrl
{
    return _linkUrl;
}

// 求最大高度
-(NSUInteger)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines
{
	NSMutableString *newLines = [NSMutableString string];
	if (maxNumberOfLines == 1) {
		[newLines appendString:@"-"];
	}
    else {
		for (int i = 1; i < maxNumberOfLines; i++) {
			[newLines appendString:@"\n"];
		}
	}
    
    CGSize size =  [newLines sizeWithFont:self.font size:CGSizeMake(self.frame.size.width, MAXFLOAT)];//[newLines sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    return  size.height;
}


//默认一行，暂不处理
-(NSUInteger)setMinNumberOfLines:(NSUInteger)minNumberOfLines
{
	return self.contentSize.height;
}



@end
