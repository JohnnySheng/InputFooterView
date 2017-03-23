//
//  FUTextView.h
//  DemoForHR
//
//  Created by "" on 14-8-12.
//  Copyright (c) 2014年 fuya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FUTextView : UITextView{
    
    UILabel* _placeHoldLabel;
    BOOL     _isShowPlaceHolder;
    NSString * _linkUrl;
}

@property(nonatomic,assign)BOOL isShowPlaceHolder;

// 求最大高度,返回高度  (备注：计算有误差)
-(NSUInteger)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines;

//默认一行，暂不处理，返回高度 (备注：计算有误差)
-(NSUInteger)setMinNumberOfLines:(NSUInteger)minNumberOfLines;


//设置文字内容
-(void)setText:(NSString *)text;

//设置文字的字体
-(void)setTextFont:(UIFont *)font;

//设置默认的文字
-(void)setPlaceHolder:(NSString*)text;

//设置默认的文字的字体
-(void)setPlaceHolderFont:(UIFont *)font;

//设置隐含链接地址
- (void)setlinkUrl:(NSString *)url;
//获取隐含链接地址
- (NSString *)getLinkUrl;

@end
