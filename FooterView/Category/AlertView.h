//
//  AlertView.h
//  XSLliterature
//
//  Created by biejia on 12-2-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertView : UIView
{
    AlertView * _alert;
    id controller;
}

@property (nonatomic,strong) UIView * waitingView;
@property (nonatomic,strong) UIActivityIndicatorView * activityView;
@property (nonatomic,strong) UILabel * waitingLabel;
@property (nonatomic,strong) UIView * endView;
@property (nonatomic,strong) UILabel * endLabel;
-(id)initWithFrame:(CGRect)frame del:(id)_delegate;
-(id)initSquareWithFrame:(CGRect)frame del:(id)_delegate;

-(void)showEndViewWithText:(NSString*)waitingText;
-(void)showWaitingViewWithText:(NSString*)endText;
-(void)showAlertViewWithText:(NSString *)_text;
@end
