//
//  CommentFooterView.h
//  Knowledge
//
//  Created by 付亚 on 15/4/11.
//  Copyright (c) 2015年 fuya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentFooterView.h"
#import "FUChatFootView.h"
#import "FURecordToastView.h"
#import "FUChatFootMenuItemManager.h"
#import "FUChatFootMenuExtendView.h"
#import "FUTalkManager.h"
#import "FUTextView.h"

#import "FUChatFootMenuItemManager.h"

@protocol CommentFooterDelegate <NSObject>

- (UIView *)footerSuperView;

- (void)footerViewChangedOriginY:(CGFloat)height;

- (void)senderText:(NSString *)text;

- (void)startVoice;

- (void)senderVoice:(NSString *)voicePath timeLong:(long)timeLong;

- (void)localPhotoAction;
- (void)takePhotoAction;

- (BOOL)beginClick;

- (void)closeView;

@optional
- (void)liveCoursewareAction;


@end

@interface CommentFooterView : UIView

@property (nonatomic, assign) id<CommentFooterDelegate> delegate;
@property (nonatomic, assign) BOOL footerViewDisabled;
@property (nonatomic, assign) BOOL voiceDisabled;
@property (nonatomic, assign) BOOL smileDisabled;
@property (nonatomic, assign) BOOL notOnlyText;
@property (nonatomic, assign) BOOL extendDisabled;
@property (nonatomic, assign) BOOL showLiveFootItem;
@property (nonatomic, assign) BOOL changeCloseBtn;

@property (nonatomic, strong) FUChatFootMenuItemManager* chatFootMenuItemManager;
@property (nonatomic,strong) FUChatFootMenuExtendView* chatFootMenuExtendView;

- (FUTextView *)contentTextView;

- (void) reloadView;

- (BOOL) commentFooterViewIsUping;

- (void) beginTextViewWithPlaceHolder:(NSString *)text;

- (void) endTextView;

- (void) beginVoice;

- (void)scrollDownExtendedFunctionViewWithAnimation:(BOOL)animation;

- (void)setFooterViewDisabled:(BOOL)footerViewDisabled warnText:(NSString *)text;

@end
