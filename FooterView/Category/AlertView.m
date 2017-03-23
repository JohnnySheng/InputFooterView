//
//  AlertView.m
//  XSLliterature
//
//  Created by biejia on 12-2-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AlertView.h"

@implementation AlertView
@synthesize waitingView = _waitingView;
@synthesize activityView = _activityView;
@synthesize waitingLabel = _waitingLabel;
@synthesize endView = _endView;
@synthesize endLabel = _endLabel;

-(id)initWithFrame:(CGRect)frame  del:(id)_delegate;
{
    self = [super initWithFrame:CGRectZero];
    if (self){
        controller = _delegate;
        self.backgroundColor = [UIColor clearColor];
        
        UIView * view = nil;
        if ([controller isKindOfClass:[UIView class]]) {
            UIView * v = (UIView*)controller;
            CGPoint point = CGPointMake((v.frame.size.width-240)/2, v.frame.size.height-100);
            if (frame.origin.x!=0) {
                point.x = frame.origin.x;
            }
            if (frame.origin.y!=0) {
                point.y = frame.origin.y;
            }
            
            self.frame =  CGRectMake(point.x,point.y, 240, 40);
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 40)];
            view.backgroundColor = [UIColor clearColor];
            [self addSubview:view];
        }
        else
        {
            self.frame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            view = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-240)/2, self.frame.size.height-100, 240, 40)];
            view.backgroundColor = [UIColor clearColor];
            [self addSubview:view];
        }
        
        _waitingView = [[UIView alloc] initWithFrame:CGRectMake(0,0, view.frame.size.width, view.frame.size.height)];
        _waitingView.backgroundColor = [UIColor clearColor];
        _waitingView.autoresizesSubviews = YES;
        _waitingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _waitingView.layer.masksToBounds = YES;
        [view addSubview:_waitingView];
        
        UIView * waitingBgView = [[UIView alloc] initWithFrame:CGRectMake(0,0, view.frame.size.width, view.frame.size.height)];
        waitingBgView.backgroundColor = [UIColor blackColor];
        waitingBgView.alpha = 0.75;
        waitingBgView.layer.cornerRadius = 4;
        waitingBgView.autoresizesSubviews = YES;
        waitingBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        waitingBgView.layer.masksToBounds = YES;
        [_waitingView addSubview:waitingBgView];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(20, (_waitingView.frame.size.height-20)/2, 20, 20)];
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [_waitingView addSubview:_activityView];
        
        _waitingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40,0,_waitingView.frame.size.width-view.frame.size.height, _waitingView.frame.size.height)];
        _waitingLabel.backgroundColor = [UIColor clearColor];
        _waitingLabel.font = [UIFont systemFontOfSize:12];
        _waitingLabel.textColor = [UIColor whiteColor];
        _waitingLabel.textAlignment = NSTextAlignmentCenter;
        _waitingLabel.numberOfLines = 2;
        _waitingLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _waitingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_waitingView addSubview:_waitingLabel];
        
        _endView = [[UIView alloc] initWithFrame:CGRectMake(0,0, view.frame.size.width, view.frame.size.height)];
        _endView.backgroundColor = [UIColor clearColor];
        _endView.autoresizesSubviews = YES;
        _endView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _endView.layer.masksToBounds = YES;
        [view addSubview:_endView];
        
        UIView * endBgView = [[UIView alloc] initWithFrame:CGRectMake(0,0, _endView.frame.size.width, _endView.frame.size.height)];
        endBgView.backgroundColor = [UIColor blackColor];
        endBgView.alpha = 0.75;
        endBgView.layer.cornerRadius = 4;
        endBgView.autoresizesSubviews = YES;
        endBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        endBgView.layer.masksToBounds = YES;
        [_endView addSubview:endBgView];
        
        _endLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,_endView.frame.size.width-20, _endView.frame.size.height)];
        _endLabel.backgroundColor = [UIColor clearColor];
        _endLabel.font = [UIFont systemFontOfSize:12];
        _endLabel.textColor = [UIColor whiteColor];
        _endLabel.textAlignment = NSTextAlignmentCenter;
        _endLabel.numberOfLines = 3;
        _endLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _endLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_endView addSubview:_endLabel];
    }
    return self;
}

-(id)initSquareWithFrame:(CGRect)frame del:(id)_delegate
{
    self = [super initWithFrame:CGRectZero];
    if (self){
        controller = _delegate;
        self.backgroundColor = [UIColor clearColor];
        
        UIView * view = nil;
        if ([controller isKindOfClass:[UIView class]]) {
            UIView * v = (UIView*)controller;
            CGPoint point = CGPointMake((v.frame.size.width-120)/2, v.frame.size.height-120);
            if (frame.origin.x!=0&&frame.origin.y!=0) {
                point = frame.origin;
            }
            
            self.frame =  CGRectMake((v.frame.size.width-120)/2,(v.frame.size.height-120)/2, 120, 120);
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
            view.backgroundColor = [UIColor clearColor];
            [self addSubview:view];
        }
        else
        {
            self.frame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            view = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-120)/2, (self.frame.size.height-120)/2, 120, 120)];
            view.backgroundColor = [UIColor clearColor];
            [self addSubview:view];
        }
        
        _waitingView = [[UIView alloc] initWithFrame:CGRectMake(0,0, view.frame.size.width, view.frame.size.height)];
        _waitingView.backgroundColor = [UIColor clearColor];
        _waitingView.autoresizesSubviews = YES;
        _waitingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _waitingView.layer.masksToBounds = YES;
        [view addSubview:_waitingView];
        
        UIView * waitingBgView = [[UIView alloc] initWithFrame:CGRectMake(0,0, view.frame.size.width, view.frame.size.height)];
        waitingBgView.backgroundColor = [UIColor blackColor];
        waitingBgView.alpha = 0.75;
        waitingBgView.layer.cornerRadius = 4;
        waitingBgView.autoresizesSubviews = YES;
        waitingBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        waitingBgView.layer.masksToBounds = YES;
        [_waitingView addSubview:waitingBgView];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(20, (_waitingView.frame.size.height-40)/2, 20, 20)];
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [_waitingView addSubview:_activityView];
        
        _waitingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,_waitingView.frame.size.height-40,_waitingView.frame.size.width-20, 20)];
        _waitingLabel.backgroundColor = [UIColor clearColor];
        _waitingLabel.font = [UIFont systemFontOfSize:12];
        _waitingLabel.textColor = [UIColor whiteColor];
        _waitingLabel.textAlignment = NSTextAlignmentCenter;
        _waitingLabel.numberOfLines = 2;
        _waitingLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _waitingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_waitingView addSubview:_waitingLabel];
        
        _endView = [[UIView alloc] initWithFrame:CGRectMake(0,0, view.frame.size.width, view.frame.size.height)];
        _endView.backgroundColor = [UIColor clearColor];
        _endView.autoresizesSubviews = YES;
        _endView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _endView.layer.masksToBounds = YES;
        [view addSubview:_endView];
        
        UIView * endBgView = [[UIView alloc] initWithFrame:CGRectMake(0,0, _endView.frame.size.width, _endView.frame.size.height)];
        endBgView.backgroundColor = [UIColor blackColor];
        endBgView.alpha = 0.75;
        endBgView.layer.cornerRadius = 4;
        endBgView.autoresizesSubviews = YES;
        endBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        endBgView.layer.masksToBounds = YES;
        [_endView addSubview:endBgView];
        
        UIImageView * endImgView = [[UIImageView alloc] initWithFrame:CGRectMake((_endView.frame.size.width-50)/2,25, 50, 50)];
        endImgView.image = [UIImage imageNamed:@"pic_yes"];
        [_endView addSubview:endImgView];
        
        _endLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,_endView.frame.size.height-45,_endView.frame.size.width-20, 40)];
        _endLabel.backgroundColor = [UIColor clearColor];
        _endLabel.font = [UIFont systemFontOfSize:12];
        _endLabel.textColor = [UIColor whiteColor];
        _endLabel.textAlignment = NSTextAlignmentCenter;
        _endLabel.numberOfLines = 3;
        _endLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _endLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_endView addSubview:_endLabel];
    }
    return self;
}

-(void)showEndViewWithText:(NSString*)endText
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.2];
    _waitingView.alpha = 0.01;
    [UIView commitAnimations];
    
    _waitingView.hidden = YES;_waitingView = nil;
    [_activityView stopAnimating];_activityView = nil;
    if (!endText) {
        [self removeFromSuperview];
        return;
    }
    _endView.hidden = NO;
    _endLabel.text = endText;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:1.5];
    _endView.alpha = 0.01;
    [UIView setAnimationDidStopSelector:@selector(stopAction:)];
    [UIView commitAnimations];
    
}

-(void)stopAction:(id)sender
{
    [self removeFromSuperview];
}

- (void)dealloc
{
    self.waitingView = nil;
    self.activityView = nil;
    self.waitingLabel = nil;
    self.endView = nil;
    self.endLabel = nil;
}

-(void)showWaitingViewWithText:(NSString*)waitingText
{
    [_activityView startAnimating];
    _waitingView.hidden = NO;
    _waitingLabel.text = waitingText;
    _waitingLabel.backgroundColor = [UIColor clearColor];
    CGSize size = [_waitingLabel sizeThatFits:CGSizeMake(MAXFLOAT, _waitingLabel.frame.size.height)];
    CGFloat width = size.width;
    if (width>_waitingLabel.frame.size.width) {
        width = width > 160?160:width;
        CGFloat offsetWidth =  width>_waitingLabel.frame.size.width?(width-_waitingLabel.frame.size.width):0;
        
        UIView * bgView = _waitingView.superview;
        CGRect bgViewFrame = bgView.frame;
        bgViewFrame.origin.x = bgViewFrame.origin.x-offsetWidth/2;
        bgViewFrame.size.width= bgViewFrame.size.width+offsetWidth;
        bgView.frame = bgViewFrame;
    }
    
    CGFloat x = (_waitingView.frame.size.width-width-_activityView.frame.size.width)/2;
    CGRect _activityViewFrame = _activityView.frame;
    _activityViewFrame.origin.x = x;
    _activityView.frame = _activityViewFrame;
    
    _endView.hidden = YES;
    if ([controller isKindOfClass:[UIView class]]) {
        [(UIView *)controller addSubview:self];
    }
    else
    {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    }
    
}

-(void)showAlertViewWithText:(NSString *)_text
{
    _waitingView.hidden = YES;
    _endLabel.text = _text;
    _endView.hidden = NO;
    if ([controller isKindOfClass:[UIView class]]) {
        [(UIView *)controller addSubview:self];
    }
    else
    {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:1.5];
    _endView.alpha = 0.01;
    [UIView setAnimationDidStopSelector:@selector(stopAction:)];
    [UIView commitAnimations];
}

@end
