//
//  FUChatFootView.h
//  DemoForHR
//
//  Created by "" on 14-8-8.
//  Copyright (c) 2014年 izhixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FUTextView.h"

@protocol MessageInputViewDelegate;

@interface FUChatFootView : UIView <UITextViewDelegate>{
    NSInteger _preHeight;              // _msgTextView改变高度之前的高度
    NSInteger _maxHeight;              // 显示最大高度，由maxNumberOfLines计算得出
    NSUInteger _minHeight;

}
// 菜单切换按钮
@property (nonatomic,strong) UIButton*  menuButton;
//头像按钮
@property (nonatomic,strong) UIButton * smileButton;
// 更多按钮
@property (nonatomic,strong) UIButton*  extendedButton;
// 输入框背景图
//@property (nonatomic,strong) UIImageView*   textBoxImage;
// 输入框
@property (nonatomic,strong) FUTextView*    msgTextView;
// 发送语音按钮
@property (nonatomic, strong) UIButton*   voiceButton;
//发送按钮
@property (nonatomic, strong) UIButton*   sendButton;
// 文字与语音切换按钮
@property (nonatomic, strong) UIButton*   intercomButton;

@property (nonatomic, assign) BOOL onlyText;
@property (nonatomic, assign) BOOL voiceDisabled;
@property (nonatomic, assign) BOOL smileDisabled;
@property (nonatomic, assign) BOOL extendDisabled;
@property (nonatomic, assign) BOOL changeCloseBtn;

@property (nonatomic, assign) id<MessageInputViewDelegate> msgInputViewDelegate;

//禁用 FootViewMenuButtons
- (void)disabledFootViewMenuButtons;
//启用 FootViewMenuButtons
- (void)enableFootViewMenuButtons;

- (void)onlyShowTextView;

- (void)updateTextView;

- (void)updateTextViewFrame;

- (void)intercomButtonPressed:(id)sender;

@end

@protocol MessageInputViewDelegate <NSObject>

#pragma mark
#pragma mark 更多按钮事件回调
-(void)msgInputView:(FUChatFootView*)msgInputView
 smileButtonPressed:(id)sender;

#pragma mark 更多按钮事件回调
-(void)msgInputView:(FUChatFootView*)msgInputView
  moreButtonPressed:(id)sender;

#pragma mark 发送按钮事件回调
-(void)msgInputView:(FUChatFootView*)msgInputView
  sendMessageButtonPressed:(id)sender;

-(BOOL)msgInputViewBeginClick:(FUChatFootView*)msgInputView;

-(void)msgInputView:(FUChatFootView*)msgInputView changeHeight:(CGFloat) changeHeight;

//语音模式回调处理
- (void)msgInputViewWithVoiceInputModel:(FUChatFootView *)msgInputView;

// 初始化是否可以录音判读
- (void)msgInputViewResetRecordIsCanUse;

-(BOOL)msgInputView:(FUChatFootView* )msgInputView
textVoiceButtonPressed:(BOOL)bVoiceMode;

//开始录音
-(void)msgInputView:(FUChatFootView*)msgInputView
 voiceButtonPressed:(id)sender;

- (void)msgInputView:(FUChatFootView*)msgInputView voiceClipBtnTouchDragOutside:(id)sender;

- (void)msgInputView:(FUChatFootView*)msgInputView  voiceClipBtnTouchDragInside:(id)sender;

- (void)msgInputView:(FUChatFootView*)msgInputView voiceClipBtnTouchUpOutside:(id)sender;

- (void)msgInputView:(FUChatFootView*)msgInputView voiceClipBtnUp:(id)sender;

- (void)closeCurrentView;

@end
