//
//  SendMassMessageViewController.m
//  DemoForHR
//
//  Created by 付亚 on 15/2/11.
//  Copyright (c) 2015年 "". All rights reserved.
//

//FIXME: 私聊界面底部的toolBar

#define FUFootViewHeight      55
#define FUSubViewHeight       55
#define NormalHeight 150
#define MaxHeight 240

#import "CommentFooterView.h"
#import "FUChatFootView.h"
#import "FURecordToastView.h"
#import "FUChatFootMenuItemManager.h"
#import "FUChatFootMenuExtendView.h"
#import "FUTalkManager.h"
#import "FUTextView.h"
//#import "IShare.h"

#import "AlertView.h"
#import "FUChatFootMenuItemManager.h"
//#import "PhotoUtil.h"

@interface CommentFooterView ()<MessageInputViewDelegate,FUTalkManagerDelegate,UITextViewDelegate>
{
    UIImageView*            _footBgView;        /**更多底部背景*/
    FUChatFootView*         _messageInputView;   /**更多底部视图*/
    
    BOOL                    _isShowFootMenuExtendView;  /**是否已经展开底部更多功能*/
    BOOL                    _keyboardShown;
    double                  _animationDuration;
    double                  _animationCurve;
    CGFloat _viewHeight;
    FUChatFootMenuItemManager * _chatFootMenuItemManager;
    BOOL  _recordIsCanUse;            // 是否可以录音
    FUChatFootMenuExtendView* _chatFootMenuExtendView;
    FURecordToastView* _recordToastView;
    CGFloat  _keyboardHeight;
    FUTalkManager* _talkManager;
    
    AlertView * alertSave;
    CGFloat textViewHeight;
    
    
    NSInteger sendCount;
    NSInteger sendSuccessCount;
    
    
    UIView * disabledView;//禁用底部，提示文字
}

@property (nonatomic, assign) CGFloat viewHeight;

@property (nonatomic, strong) FURecordToastView* recordToastView;
@property (nonatomic,assign) CGFloat keyboardHeight;
@property (nonatomic, strong) AlertView * waitAlert;
@property (nonatomic, strong) NSString * contentStr;


@end

@implementation CommentFooterView

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) beginTextViewWithPlaceHolder:(NSString *)text
{
    if (!_messageInputView.msgTextView || _messageInputView.msgTextView.hidden == YES) {
        return;
    }
    
    [_messageInputView.msgTextView setPlaceHolder:text];
    [_messageInputView.msgTextView setPlaceHolderFont:[UIFont systemFontOfSize:14]];
    [_messageInputView.msgTextView becomeFirstResponder];
}

- (void) beginVoice{
    if (!_messageInputView.voiceButton) {
        return;
    }
    if (_messageInputView.voiceButton.hidden) {
        [_messageInputView intercomButtonPressed:_messageInputView.menuButton];
    }
}

- (FUTextView *)contentTextView
{
    return _messageInputView.msgTextView;
}

- (void) endTextView
{
    _contentStr = _messageInputView.msgTextView.text;
    [_messageInputView updateTextViewFrame];
    [_messageInputView.msgTextView resignFirstResponder];
    _messageInputView.sendButton.enabled = _contentStr.length>0;
}

- (BOOL) commentFooterViewIsUping
{
    return _keyboardShown || _isShowFootMenuExtendView;
}

- (void) reloadView
{
    self.layer.masksToBounds = YES;
    CGRect rect = self.frame;
    rect.size.width = [UIScreen mainScreen].bounds.size.width;
    self.frame = rect;

    self.smileDisabled  = YES;
    [self addObserver];
    [self createFootView];
    
    if (!_chatFootMenuItemManager) {
        _chatFootMenuItemManager =  [[FUChatFootMenuItemManager alloc] init];
    }
}

- (void)addObserver{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(notifyKeyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(notifyKeyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (CGFloat)getViewHeight{
     ;
    _viewHeight = CGRectGetHeight([[_delegate footerSuperView] frame]);
    return _viewHeight;
}

- (void)createFootView{
    //创建底部菜单
    if(_footBgView == nil)
    {
        _footBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, FUFootViewHeight)];
        _footBgView.translatesAutoresizingMaskIntoConstraints = NO;
        [_footBgView setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0]];
        [_footBgView setUserInteractionEnabled:YES];
        [self addSubview:_footBgView];
//        [_footBgView addConstraint:[NSLayoutConstraint constraintWithItem:_footBgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:FUFootViewHeight]];
//        [self addConstraint:[NSLayoutConstraint constraintWithItem:_footBgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f]];
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _footBgView.frame.size.width, 0.5)];
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        lineView.backgroundColor = [UIColor colorWithRed:187/255.0 green:187/255.0 blue:187/255.0 alpha:1.0];
        [_footBgView addSubview:lineView];
//        [_footBgView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_footBgView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f]];
    }
    
    [self createFootMessageView];
}

- (void) createFootMessageView{
    if(_messageInputView == nil)
    {
        _messageInputView = [[FUChatFootView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, FUSubViewHeight)];
        _messageInputView.msgInputViewDelegate = self;
        _messageInputView.voiceDisabled = self.voiceDisabled;
        _messageInputView.smileDisabled = self.smileDisabled;
        _messageInputView.changeCloseBtn = self.changeCloseBtn;
        if (!self.notOnlyText) {
            [_messageInputView onlyShowTextView];
        }
        [self addSubview:_messageInputView];
        
        [_messageInputView addConstraint:[NSLayoutConstraint constraintWithItem:_messageInputView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:FUSubViewHeight]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_messageInputView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_messageInputView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f]];
    }
}

- (void)setFooterViewDisabled:(BOOL)footerViewDisabled warnText:(NSString *)text
{
    _footerViewDisabled = footerViewDisabled;
    
    self.userInteractionEnabled = !footerViewDisabled;
    
    if (footerViewDisabled) {
        disabledView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        disabledView.backgroundColor = [UIColor clearColor];
        [self addSubview:disabledView];
        [self bringSubviewToFront:disabledView];
        
        UIView * alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, disabledView.frame.size.width, disabledView.frame.size.height)];
        alphaView.backgroundColor = [UIColor blackColor];
        alphaView.alpha = 0.5;
        [disabledView addSubview:alphaView];
        
        UILabel * warnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, disabledView.frame.size.width, disabledView.frame.size.height)];
        warnLabel.text = text;
        warnLabel.font = [UIFont systemFontOfSize:12];
        warnLabel.textColor = [UIColor whiteColor];
        warnLabel.textAlignment = NSTextAlignmentCenter;
        [disabledView addSubview:warnLabel];
    }
    else
    {
        [disabledView removeFromSuperview];
        disabledView = nil;
    }
}

- (void)setVoiceDisabled:(BOOL)voiceDisabled
{
    _voiceDisabled = voiceDisabled;
    if (_messageInputView) {
        _messageInputView.voiceDisabled = voiceDisabled;
    }
}

- (void)setExtendDisabled:(BOOL)extendDisabled
{
    _extendDisabled = extendDisabled;
    if (_messageInputView) {
        _messageInputView.extendDisabled = extendDisabled;
    }
}

- (void)setSmileDisabled:(BOOL)smileDisabled
{
    _smileDisabled = smileDisabled;
    if (_messageInputView) {
        _messageInputView.smileDisabled = smileDisabled;
    }
}

#pragma mark
#pragma mark MessageInputViewDelegate
//发送文本信息
-(void)msgInputView:(FUChatFootView*)msgInputView sendMessageButtonPressed:(id)sender{
    FUTextView* msgTextView = msgInputView.msgTextView;
    NSString* msgText = [msgTextView text];
    if (msgText.length == 0) {
        return;
    }
    
    if (_delegate&&[_delegate respondsToSelector:@selector(senderText:)])
    {
        [_delegate senderText:msgText];
    }
    msgTextView.text = nil;
    [msgTextView setPlaceHolder:nil];
    
    [_messageInputView updateTextView];//调整输入框高度
}

-(void)msgInputView:(FUChatFootView*)msgInputView
 smileButtonPressed:(id)sender
{
    
}

-(void)msgInputView:(FUChatFootView*)msgInputView moreButtonPressed:(id)sender{
    UIView* msgTextView = [msgInputView msgTextView];
    if (msgTextView && [msgTextView isFirstResponder]) {
        [msgTextView resignFirstResponder];
    }
    [self showExtendedFunctionView:sender];
}

- (BOOL)msgInputViewBeginClick:(FUChatFootView*)msgInputView{
    if (_delegate && [_delegate respondsToSelector:@selector(beginClick)]) {
         return [_delegate beginClick];
    }
    return YES;
}

- (void)msgInputView:(FUChatFootView *)msgInputView voiceButtonPressed:(id)sender{
    FURecordToastView* newRecordTostView = [self createRecordTostView];
    newRecordTostView.imageToastName = @"FUFootResource.bundle/shouzhishanghua_N";
    newRecordTostView.volumeAnimationView.hidden = NO;
    [self createTalkManager];
    [_talkManager startRecord];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(startVoice)]) {
        [self.delegate startVoice];
    }
}

- (void)msgInputView:(FUChatFootView *)msgInputView voiceClipBtnTouchDragInside:(id)sender{
    FURecordToastView* newRecordTostView = [self createRecordTostView];
    newRecordTostView.imageToastName = @"FUFootResource.bundle/shouzhishanghua_N";
    newRecordTostView.volumeAnimationView.hidden = NO;
    [self createTalkManager];
    if (_talkManager) {
        [_talkManager resumeRecord];
    }
}

- (void)msgInputView:(FUChatFootView *)msgInputView voiceClipBtnTouchDragOutside:(id)sender{
    FURecordToastView* newRecordTostView = [self createRecordTostView];
    newRecordTostView.imageToastName = @"FUFootResource.bundle/shouzhisongkai_P";
    newRecordTostView.volumeAnimationView.hidden = YES;
    [self createTalkManager];
    if (_talkManager) {
        [_talkManager pauseRecord];
    }
}

- (void)msgInputView:(FUChatFootView *)msgInputView voiceClipBtnTouchUpOutside:(id)sender{
    if (_recordToastView) {
        [_recordToastView removeFromSuperview];
        _recordToastView = nil;
    }
    [self createTalkManager];
    [_talkManager setIsVoiceClipBtnTouchUpOutside:YES];
    [_talkManager stopRecord];
    
}

- (void)msgInputView:(FUChatFootView *)msgInputView voiceClipBtnUp:(id)sender{
    if (_recordToastView) {
        [_recordToastView removeFromSuperview];
        _recordToastView = nil;
    }
    [self createTalkManager];
    [_talkManager stopRecord];
    
}

- (void)msgInputViewResetRecordIsCanUse{
    _recordIsCanUse = FALSE;
}


-(BOOL)msgInputView:(FUChatFootView* )msgInputView textVoiceButtonPressed:(BOOL)bVoiceMode{
    if (_isShowFootMenuExtendView) {
        [self showExtendedFunctionView:nil];
    }
    
    return TRUE;
}


- (void)msgInputViewWithVoiceInputModel:(FUChatFootView *)msgInputView{
    [self scrollDownExtendedFunctionViewWithAnimation:YES];
    _isShowFootMenuExtendView = NO;
    
}


-(void)msgInputView:(FUChatFootView *)msgInputView
       changeHeight:(CGFloat)changeHeight
{
//    [self resetFootBgViewWithChangeHeight:changeHeight];
}

- (void)closeCurrentView{
    if (_delegate&&[_delegate respondsToSelector:@selector(closeView)])
    {
        [_delegate closeView];
    }
}


-(void)resetFootBgViewWithChangeHeight:(CGFloat)changeHeight
{
    CGRect sFame = self.frame;
    sFame.origin.y -=  changeHeight;
    sFame.size.height += changeHeight;
    [self setFrame:sFame];
    
//    CGRect fFame = _footBgView.frame;
//    fFame.origin.y = 0;
//    fFame.size.height += changeHeight;
//    [_footBgView setFrame:fFame];
//    
//    CGRect messageInputViewFrame = _messageInputView.frame;
//    messageInputViewFrame.origin.y = 0;
//    messageInputViewFrame.size.height +=changeHeight;
//    _messageInputView.frame = messageInputViewFrame;
    
    //footerView height changed
    if (self.delegate && [self.delegate respondsToSelector:@selector(footerViewChangedOriginY:)]) {
        [self.delegate footerViewChangedOriginY:sFame.origin.y];
    }
}

#pragma mark- recordToast
- (FURecordToastView* )createRecordTostView{
    if (!_recordToastView) {
        _recordToastView = [[FURecordToastView alloc] initWithFrame:CGRectMake((CGRectGetWidth([[_delegate footerSuperView] frame]) - FURecordToastViewWidth)/2, (CGRectGetHeight([[_delegate footerSuperView] frame]) - FURecordToastViewHeight)*3/5, FURecordToastViewWidth, FURecordToastViewWidth)];
        [[_delegate footerSuperView] addSubview:_recordToastView];
    }
    
    return _recordToastView;
}

- (void)removeRecordTostView{
    if (_recordToastView && [_recordToastView superview]) {
        [_recordToastView removeFromSuperview];
        _recordToastView = nil;
    }
}

- (void)createTalkManager{
    if (!_talkManager) {
        _talkManager =  [FUTalkManager sharedFUTalkManager];
    }
    _talkManager.talkManagerDelegate = self;
}


#pragma mark- extendedFunction底部菜单
- (void)showExtendedFunctionView:(id) sender{
    _viewHeight = [self getViewHeight];
    
    if (!_isShowFootMenuExtendView)
    {
        _isShowFootMenuExtendView = YES;
        
        if (_chatFootMenuExtendView == nil)
        {
            if (self.showLiveFootItem) {
                /**直播课件菜单对象*/
                FUChatFootMenuItem *liveMenuItem = [[FUChatFootMenuItem alloc] init];
                liveMenuItem.menuNameColor = [UIColor blackColor];
                liveMenuItem.nomarlImage = LIVE_MENU_NORMAL_IMAGE;
                liveMenuItem.selectedImage = LIVE_MENU_HEIGHTED_IMAGE;
                liveMenuItem.selectedMenuItemSelector = NSSelectorFromString(LIVE_MENU_SELECTOR_NAME);
                [_chatFootMenuItemManager addChatFootMenuItem:liveMenuItem];
            }
            _chatFootMenuExtendView= [[FUChatFootMenuExtendView alloc] initWithDelegate:self];
            [_chatFootMenuExtendView setMenuItems:_chatFootMenuItemManager.chatFootMenuItemArray];
            _chatFootMenuExtendView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:_chatFootMenuExtendView];
            UIView * footerSuperView = [self.delegate footerSuperView];
            [footerSuperView addSubview:_chatFootMenuExtendView];
            [footerSuperView bringSubviewToFront:_chatFootMenuExtendView];
            
            [_chatFootMenuExtendView addConstraint:[NSLayoutConstraint constraintWithItem:_chatFootMenuExtendView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CGRectGetHeight(_chatFootMenuExtendView.frame)]];
            [_chatFootMenuExtendView addConstraint:[NSLayoutConstraint constraintWithItem:_chatFootMenuExtendView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CGRectGetWidth(_chatFootMenuExtendView.frame)]];
            NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:_chatFootMenuExtendView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerSuperView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.f];
            [footerSuperView addConstraint:constraintTop];
        }

        
        
        CGRect rFrame = _chatFootMenuExtendView.frame;
        CGRect sFrame = self.frame;
        CGFloat sHeight = rFrame.size.height + FUSubViewHeight;
        CGFloat originY = _viewHeight - sHeight;
        
        sFrame.origin.y = originY;
        sFrame.size.height = sHeight;
        [self setFrame:sFrame];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(footerViewChangedOriginY:)]) {
            [self.delegate footerViewChangedOriginY:originY];
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.20];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.keyboardHeight = 216;
        _chatFootMenuExtendView.alpha = 1;
//        rFrame.origin.y = _viewHeight- rFrame.size.height;
//        rFrame.size.width = self.frame.size.width;
//        _chatFootMenuExtendView.frame = rFrame;
        
        //footerView height changed
        [UIView commitAnimations];
    }else{
        [self scrollDownExtendedFunctionViewWithAnimation:YES];
    }
}

- (void)scrollDownExtendedFunctionViewWithAnimation:(BOOL)bAnimation
{
    if (!_isShowFootMenuExtendView) {
        return;
    }
    
    self.keyboardHeight = 0;
    _isShowFootMenuExtendView = NO;
    _viewHeight = [self getViewHeight];
    CGRect sFrame = self.frame;
//    CGRect rFrame = _chatFootMenuExtendView.frame;
    
    if (bAnimation)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.20];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    }
    _chatFootMenuExtendView.alpha = 0;
//    rFrame.origin.y = _viewHeight;
//    rFrame.size.width = self.frame.size.width;
//    _chatFootMenuExtendView.frame = rFrame;
    
    sFrame.origin.y = _viewHeight - FUSubViewHeight;
    sFrame.size.height = FUFootViewHeight;
    [self setFrame:sFrame]; //设置footBgV和footView
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(footerViewChangedOriginY:)]) {
        [self.delegate footerViewChangedOriginY:sFrame.origin.y];
    }
    
    sFrame = self.frame;
    if (bAnimation)
    {
        [UIView commitAnimations];
    }
}

#pragma mark
#pragma mark FUTalkManagerDelegate
- (void)talkManager:(FUTalkManager *)talkManager volume:(CGFloat)currentVolume{
    
}

- (void)talkManager:(FUTalkManager *)talkManager timeTransient:(NSUInteger)time{
    FURecordToastView* newRecordTostView = [self createRecordTostView];
    newRecordTostView.imageToastName = @"FUFootResource.bundle/voice_time_transient";
    newRecordTostView.volumeAnimationView.hidden = TRUE;
    
    __weak typeof(self) _weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.0),
                   dispatch_get_main_queue(), ^{
                       [_weakSelf removeRecordTostView];
                   });
}


- (void)talkManager:(FUTalkManager *)talkManager peakPowerForChannel:(double)currentPeakPowerForChannel{
    if (_recordToastView) {
        [_recordToastView updatePeakPowerForChannelUI:currentPeakPowerForChannel];
    }
}

- (void)talkManager:(FUTalkManager *)talkManager stopRecord:(NSString *)recordPath timeLong:(long)time{
    [self removeRecordTostView];
    UIImage * normalImg = [UIImage imageNamed:@"FUFootResource.bundle/voice_bt_down_Normal"];
    [[_messageInputView voiceButton] setBackgroundImage:[normalImg stretchableImageWithLeftCapWidth:normalImg.size.width/2 topCapHeight:normalImg.size.width/2] forState:UIControlStateHighlighted];
    if (self.delegate && [self.delegate respondsToSelector:@selector(senderVoice:timeLong:)]) {
        [self.delegate senderVoice:recordPath timeLong:time];
    }
}

#pragma mark FUChatFootMenuExtendViewDelegate
- (void)chatFootMenuExtendView:(FUChatFootMenuExtendView* ) chatFootMenuExtendView
        didSelectedPicMenuItem:(FUChatFootMenuItem* ) chatFootMenuItem{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]||[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(localPhotoAction)]) {
            [self.delegate localPhotoAction];
        }
    }
    else
    {
        AlertView * alertview = [[AlertView alloc] init];
        [alertview showAlertViewWithText:@"该设备不支持此功能"];
    }
}

- (void)chatFootMenuExtendView:(FUChatFootMenuExtendView *)chatFootMenuExtendView
     didSelectedCameraMenuItem:(FUChatFootMenuItem *)chatFootMenuItem{

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        BOOL isCameraValid = YES;
        //判断iOS7的宏，没有就自己写个，下边的方法是iOS7新加的，7以下调用会报错
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied||authStatus == AVAuthorizationStatusRestricted)
        {
            isCameraValid = NO;
        }
        
        if (isCameraValid) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(takePhotoAction)]) {
                [self.delegate takePhotoAction];
            }
        }
        else
        {
            AlertView * alertview = [[AlertView alloc] init];
            [alertview showAlertViewWithText:@"您未开启照片权限"];
        }
    }
    else
    {
        AlertView * alertview = [[AlertView alloc] init];
        [alertview showAlertViewWithText:@"该设备不支持此功能"];
    }
}

- (void)chatFootMenuExtendView:(FUChatFootMenuExtendView *)chatFootMenuExtendView
     didSelectedLiveMenuItem:(FUChatFootMenuItem *)chatFootMenuItem{
    if (self.delegate && [self.delegate respondsToSelector:@selector(liveCoursewareAction)]) {
        [self.delegate liveCoursewareAction];
    }
}

#pragma mark- keyboard
- (void)notifyKeyboardWillShow:(NSNotification* ) notification{
    if ([_delegate footerSuperView] != nil) {
        if (![[_delegate footerSuperView] window]) { //判断是否为当前显示的窗口，其他窗口操作键盘不处理
            return;
        }
        _keyboardShown = YES;
        CGRect tmpkeyboardFrame;
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&tmpkeyboardFrame];
        self.keyboardHeight = tmpkeyboardFrame.size.height;
        NSNumber *duration = (NSNumber *)[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        _animationDuration = [duration doubleValue];
        _animationCurve = [curve doubleValue];
        
        double delayInSeconds = _animationDuration / 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self changeFrame];
            if (_contentStr && _contentStr.length>0) {
                _messageInputView.msgTextView.text = _contentStr;
                [_messageInputView updateTextViewFrame];
                _messageInputView.sendButton.enabled = true;
            }
        });
    }
}

- (void)changeFrame{
    _viewHeight = [self getViewHeight];
    
    CGFloat originY = _viewHeight - _keyboardHeight - self.frame.size.height;
    [UIView animateWithDuration:_animationDuration animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:_animationCurve];

        CGRect sFrame = self.frame;
        sFrame.origin.y = originY;
        [self setFrame:sFrame];
        
    }];
    
    //footerView height changed
    if (self.delegate && [self.delegate respondsToSelector:@selector(footerViewChangedOriginY:)]) {
        [self.delegate footerViewChangedOriginY:originY];
    }
    
    _isShowFootMenuExtendView = NO;
}

- (void)notifyKeyboardWillHide:(NSNotification* )notification{
    
    if (![[_delegate footerSuperView] window]) { //判断是否为当前显示的窗口，其他窗口操作键盘不处理
        return;
    }
    
    if (!_keyboardShown)
    {
        return;
    }
    
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&_animationDuration];
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&_animationCurve];
    [self scrollDownKeyboard];
}

- (void)scrollDownKeyboard
{
    _keyboardShown = NO;
    
    self.keyboardHeight = 0;
    if (!_isShowFootMenuExtendView)
    {
        _viewHeight = [self getViewHeight];
        
        CGFloat originY = _viewHeight - self.frame.size.height;
        [UIView animateWithDuration:_animationDuration animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:_animationCurve];
            
            _chatFootMenuExtendView.alpha = 0;
            
            CGRect sFrame = self.frame;
            sFrame.origin.y = originY;
            sFrame.size.height = FUFootViewHeight;
            [self setFrame:sFrame]; //设置footBgV

//            CGRect rFrame = _chatFootMenuExtendView.frame;
//            rFrame.origin.y = _viewHeight;
//            rFrame.size.width = self.frame.size.width;
//            _chatFootMenuExtendView.frame = rFrame;
        }];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(footerViewChangedOriginY:)]) {
            [self.delegate footerViewChangedOriginY:originY];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

@end
