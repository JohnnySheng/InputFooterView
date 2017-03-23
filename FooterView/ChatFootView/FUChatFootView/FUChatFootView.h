//
//  FUChatFootView.h
//  DemoForHR
//
//  Created by "" on 14-8-8.
//  Copyright (c) 2014年 izhixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FUTextView.h"

@protocol FUVoiceButtonDelegate;

@interface FUVoiceButton : UIButton{
    
}
@property (nonatomic, weak) id<FUVoiceButtonDelegate> voiceButtonDelegate;

- (id)initWithFrame:(CGRect)frame withDelegate:(id<FUVoiceButtonDelegate>) delegate;
@end

@protocol FUVoiceButtonDelegate <NSObject>

@optional
- (void)voiceButtonTouchesMoved:(FUVoiceButton* ) voiceButton;
- (void)voiceButtonTouchesBegin:(FUVoiceButton *)voiceButton;
- (void)voiceButtonTouchesCancel:(FUVoiceButton *)voiceButton;
- (void)voiceButtonTouchesEnd:(FUVoiceButton *)voiceButton;

@end



@protocol MessageInputViewDelegate;

@interface FUChatFootView : UIView <UITextViewDelegate,FUVoiceButtonDelegate>{
    UIButton*      _menuButton;             // 菜单切换按钮
    UIButton*      _smileButton;            //头像按钮
    UIButton*      _extendedButton;         // 更多按钮
    UIImageView*   _textBoxImage;           // 输入框背景图
    FUTextView*    _msgTextView;            // 输入框
    UIButton*      _voiceButton;            // 发送语音按钮
    UIButton*      _intercomButton;         // 文字与语音切换按钮
    UIButton*      _sendButton;             //发送按钮
    NSInteger      _preHeight;              // _msgTextView改变高度之前的高度
    NSInteger     _maxHeight;              // 显示最大高度，由maxNumberOfLines计算得出
    NSUInteger   _minHeight;

}

@property (nonatomic,strong) UIButton*  menuButton;
@property (nonatomic,strong) UIButton * smileButton;
@property (nonatomic,strong) UIButton*  extendedButton;
//@property (nonatomic,strong) UIImageView*   textBoxImage;
@property (nonatomic,strong) FUTextView*    msgTextView;
@property (nonatomic,assign) BOOL onlyText;
@property (nonatomic, assign) BOOL voiceDisabled;
@property (nonatomic, assign) BOOL smileDisabled;
@property (nonatomic, assign) BOOL extendDisabled;
@property (nonatomic, assign) BOOL changeCloseBtn;
@property (nonatomic,weak) id<MessageInputViewDelegate> msgInputViewDelegate;
@property (nonatomic, strong) UIButton*   voiceButton;
@property (nonatomic, strong) UIButton*   sendButton;
@property (nonatomic, strong) UIButton*   intercomButton;

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