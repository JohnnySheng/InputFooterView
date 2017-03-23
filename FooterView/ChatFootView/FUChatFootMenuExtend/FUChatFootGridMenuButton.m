//
//  FUGridMenuButton.m
//  DemoForHR
//
//  Created by "" on 14-8-7.
//  Copyright (c) 2014年 izhixin. All rights reserved.
//

#import "FUChatFootGridMenuButton.h"
#import <QuartzCore/QuartzCore.h>

#define kTitleLabelHeight   20
#define kSpacing            5

@interface FUChatFootGridMenuButton() {
    FUChatFootMenuItem* _chatFootMenuItem;
}
@property (strong, nonatomic) FUChatFootMenuItem* chatFootMenuItem;
@property (weak, nonatomic) id chatFootGridMenuDelegate;
@end

@implementation FUChatFootGridMenuButton
@synthesize chatFootMenuItem =  _chatFootMenuItem;
@synthesize imageView = _imageView;
@synthesize titleLabel = _titleLabel;
@synthesize button = _button;
@synthesize chatFootGridMenuDelegate = _chatFootGridMenuDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame chatFootMenuItem:(FUChatFootMenuItem *)chatFootMenuItem delegate:(id)delegate{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
         _chatFootMenuItem = chatFootMenuItem;
        _chatFootGridMenuDelegate = delegate;
        if (_chatFootMenuItem) {
            _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
            [_button setBackgroundImage:[UIImage imageNamed:_chatFootMenuItem.nomarlImage] forState:UIControlStateNormal];
            [_button setBackgroundImage:[UIImage imageNamed:_chatFootMenuItem.selectedImage] forState:UIControlStateHighlighted];
            [_button addTarget:self action:@selector(tapButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [self setButtonItemEnable:_chatFootMenuItem.enable];
            [self addSubview:_button];
        }
        
        if (_chatFootMenuItem.menuName.length > 0) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.width + kSpacing, frame.size.width, kTitleLabelHeight)];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.text = _chatFootMenuItem.menuName;
            _titleLabel.font = _chatFootMenuItem.menuNameFont;
            _titleLabel.textColor = _chatFootMenuItem.menuNameColor;
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_titleLabel];
        }
    }
    
    return self;
}

- (void)tapButtonAction{
    SEL actionSel = _chatFootMenuItem.selectedMenuItemSelector == nil ? nil :  _chatFootMenuItem.selectedMenuItemSelector ;
    if (_chatFootGridMenuDelegate && [_chatFootGridMenuDelegate respondsToSelector:actionSel]) {
        [_chatFootGridMenuDelegate performSelector:actionSel withObject:[[self superview] superview] withObject:_chatFootMenuItem];
    }
}

- (void)dealloc{
    self.imageView = nil;
    self.titleLabel = nil;
    self.button = nil;
}

- (void)setButtonItemEnable:(BOOL)enable
{
    _button.enabled = enable;
}

@end
