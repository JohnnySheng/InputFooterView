//
//  FUChatFootView.m
//  DemoForHR
//
#import "FUChatFootView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+MyColor.h"
#import <AVFoundation/AVFoundation.h>
#import "AlertView.h"

#define ContentLimitWords    1000
#define FUSubViewHeight      55
#define FUTextViewHeight     45
#define FUButtonWidth        40
#define FUButtonHeight       40
#define FUMarignSpaceWidth   10
#define FUTextBoxMargin      5
#define FUSendButton_Width   45
#define FUSendButton_Height  40
#define FUMaxMessageLine     1

#define BUNDLE_NAME @ "FUFootResource.bundle"
#define APP_DELEGATE_RESIGN_ACTIVE @"APP_DELEGATE_RESIGN_ACTIVE"

static NSString* const FUChatFootMenuFirstUse = @"FUChatFootMenuFirstUse";      // 首次使用底部更多菜单

@interface FUChatFootView(){
    BOOL isEventTouchInside;
    CGFloat defaultX;
    BOOL _isRecording;
}

@end

@implementation FUChatFootView

#pragma mark - 初始化
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isEventTouchInside = FALSE;
        _isRecording = NO;
        [self initMsgInputView];
    }
    return self;
}

- (void)buildSendButton {
    /**发送按钮*/
      _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) -  FUSendButton_Width - FUMarignSpaceWidth, (FUSubViewHeight - FUSendButton_Height) / 2, FUSendButton_Width, FUSendButton_Height)];
    _sendButton.hidden = YES;
    _sendButton.layer.masksToBounds = TRUE;

    [_sendButton setImage:[UIImage imageNamed:@"FUFootResource.bundle/seed_Normal"] forState:UIControlStateNormal];
    [_sendButton setImage:[UIImage imageNamed:@"FUFootResource.bundle/seed_Press.png"] forState:UIControlStateHighlighted];
    [_sendButton setImage:[UIImage imageNamed:@"FUFootResource.bundle/seed_disabled.png"] forState:UIControlStateDisabled];
    _sendButton.enabled = NO;
    [_sendButton addTarget:self action:@selector(sendMeaageEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendButton];
}

- (CGFloat)buildDynamicButtons {
    //*********隐藏语音、头像************
      CGFloat textViewX = FUMarignSpaceWidth;
    CGFloat textViewWidth = self.frame.size.width - FUMarignSpaceWidth*3 - FUButtonWidth;
    if (!self.onlyText) {
        if (!self.voiceDisabled) {
            /**语音按钮*/
            _menuButton = [[UIButton alloc] initWithFrame:CGRectMake(FUMarignSpaceWidth, (FUSubViewHeight - FUButtonHeight)/2, FUButtonWidth, FUButtonHeight)];
            [_menuButton setImage:[UIImage imageNamed:@"FUFootResource.bundle/yuying_dainjiqian"] forState:UIControlStateNormal];
            [_menuButton setImage:[UIImage imageNamed:@"FUFootResource.bundle/yuying_dainjihou"] forState:UIControlStateHighlighted];
            [_menuButton addTarget:self
                            action:@selector(intercomButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_menuButton];
            
            textViewX = FUButtonWidth + FUMarignSpaceWidth*2;
            textViewWidth = self.frame.size.width - FUMarignSpaceWidth*4 - FUButtonWidth*2;
        }

        if (!self.smileDisabled)
        {
            /**头像按钮*/
            _smileButton = [[UIButton alloc] initWithFrame:CGRectMake(FUButtonWidth + FUMarignSpaceWidth*2, (FUSubViewHeight - FUButtonHeight)/2 , FUButtonWidth, FUButtonHeight)];
            [_smileButton setImage:[UIImage imageNamed:@"FUFootResource.bundle/chat_bottom_smile_nor"] forState:UIControlStateNormal];
            [_smileButton setImage:[UIImage imageNamed:@"FUFootResource.bundle/chat_bottom_smile_press"] forState:UIControlStateHighlighted];
            [_smileButton addTarget:self
                             action:@selector(showSmileFunctionView:)
                   forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_smileButton];
            
            textViewX = FUButtonWidth*2 + FUMarignSpaceWidth*3;
            textViewWidth = self.frame.size.width - FUMarignSpaceWidth*5 - FUButtonWidth*3;
        }
    }

    defaultX = textViewX;
  return textViewWidth;
}

- (void)buildMsgTextView:(CGFloat)textViewWidth {
    /**文本输入框*/
      CGRect textFrame = CGRectMake(defaultX, (FUSubViewHeight - FUTextViewHeight)/2, textViewWidth, FUTextViewHeight);
    _msgTextView = [[FUTextView alloc] initWithFrame:textFrame];
    _msgTextView.layer.borderWidth = 0.8f;
    _msgTextView.layer.cornerRadius = 3.f;
    _msgTextView.layer.borderColor = [UIColor colorWithHexString:@"cccccc"].CGColor;
    _msgTextView.delegate = self;
    _msgTextView.textColor = [UIColor blackColor];
    _msgTextView.tintColor = [UIColor colorWithRed:31/255.0 green:178/255.0 blue:136/255.0 alpha:1.0];
    _msgTextView.font = [UIFont systemFontOfSize:16.0f];
    _msgTextView.textAlignment = NSTextAlignmentLeft;
    _msgTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    _msgTextView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _msgTextView.showsHorizontalScrollIndicator = NO;
    _msgTextView.layoutManager.allowsNonContiguousLayout = NO;
    [self addSubview:_msgTextView];
    _msgTextView.hidden = NO;
    
    _maxHeight = [_msgTextView setMaxNumberOfLines:FUMaxMessageLine];
    
    if (_maxHeight < FUTextViewHeight) {
        _maxHeight = FUTextViewHeight;
    }
    _minHeight = [_msgTextView setMinNumberOfLines:1];
    _preHeight = _msgTextView.frame.size.height;
}

- (void)buildIntercomButton {
    /**左边语音和输入切换按钮*/
      _intercomButton = [[UIButton alloc] initWithFrame:CGRectMake(FUMarignSpaceWidth, (FUSubViewHeight - FUButtonHeight)/2, FUButtonWidth, FUButtonHeight)];
    [_intercomButton setImage:[UIImage imageNamed:@"FUFootResource.bundle/message_keyboard"] forState:UIControlStateNormal];
    [_intercomButton addTarget:self
                        action:@selector(intercomButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_intercomButton];
    _intercomButton.hidden = YES;
}

- (void)buildVoiceButton {
    /**录音按钮*/
      CGFloat width = CGRectGetWidth(self.frame) - FUButtonWidth*2 - FUMarignSpaceWidth*4;
    CGRect frame = CGRectMake(_intercomButton.frame.size.width + FUMarignSpaceWidth*2, 1, width, FUSubViewHeight - 2);
    _voiceButton = [[UIButton alloc] initWithFrame:frame];
    
    UIImage * voiceImage = [UIImage imageNamed:@"FUFootResource.bundle/voice_bt_down_Normal"];
    voiceImage = [voiceImage stretchableImageWithLeftCapWidth:voiceImage.size.width/2 topCapHeight:voiceImage.size.height/2];
    
    UIImage * voiceImagePress = [UIImage imageNamed:@"FUFootResource.bundle/voice_bt_down_Press"];
    voiceImagePress = [voiceImagePress stretchableImageWithLeftCapWidth:voiceImagePress.size.width/2 topCapHeight:voiceImagePress.size.height/2];
    [_voiceButton setBackgroundImage:voiceImage forState:UIControlStateNormal];
    [_voiceButton setBackgroundImage:voiceImagePress forState:UIControlStateHighlighted];
    [_voiceButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [_voiceButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    
    _voiceButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [_voiceButton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_voiceButton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    
    //单点触摸按下事件：用户点触屏幕，或者又有新手指落下的时候
    [_voiceButton addTarget:self action:@selector(sendVoiceClipBtnPressed:) forControlEvents:UIControlEventTouchDown];
    //当一次触摸在控件窗口之外拖动时
    [_voiceButton addTarget:self action:@selector(sendVoiceClipBtnTouchDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
     //所有在控件之外触摸抬起事件(点触必须开始与控件内部才会发送通知)
    [_voiceButton addTarget:self action:@selector(sendVoiceClipBtnTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    //当一次触摸在控件窗口内拖动时
    [_voiceButton addTarget:self action:@selector(sendVoiceClipBtnTouchDragInside:) forControlEvents:UIControlEventTouchDragInside];
    //所有在控件之内触摸抬起事件。
    [_voiceButton addTarget:self action:@selector(sendVoiceClipBtnUp:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_voiceButton];
    _voiceButton.hidden = YES;
}

- (void)buildExtendedButton {
    /**更多按钮*/
      _extendedButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) -  FUButtonWidth - FUMarignSpaceWidth, (FUSubViewHeight - FUButtonHeight) / 2, FUButtonWidth, FUButtonHeight)];
    [_extendedButton setImage:[UIImage imageNamed:@"FUFootResource.bundle/gengduo_dainjiqian"] forState:UIControlStateNormal];
    [_extendedButton setImage:[UIImage imageNamed:@"FUFootResource.bundle/gengduo_dainjihou"] forState:UIControlStateHighlighted];
    [_extendedButton addTarget:self
                        action:@selector(showExtendedFunctionView:)
              forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_extendedButton];
}

- (void)initMsgInputView{
    CGFloat textViewWidth;
    textViewWidth = [self buildDynamicButtons];
    
    [self buildMsgTextView:textViewWidth];
    
    [self buildIntercomButton];
    
    [self buildVoiceButton];

    [self buildExtendedButton];
    
    
    [self buildSendButton];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:APP_DELEGATE_RESIGN_ACTIVE object:nil];
}

- (void)handleNotification:(id)sender {
    if (_isRecording) {
        [self sendVoiceClipBtnUp:nil];
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_DELEGATE_RESIGN_ACTIVE object:nil];
}

#pragma make - 动态配置方法，根据不同的情况进行配置

- (void)onlyShowTextView{
    _onlyText = YES;
    _voiceButton.hidden = YES;
    _smileButton.hidden = YES;
    _extendedButton.hidden = YES;
    _menuButton.hidden = YES;
    _intercomButton.hidden = YES;
    _sendButton.hidden = NO;
    
    CGRect textFrame = _msgTextView.frame;
    textFrame.origin.x = 10;
    textFrame.size.width = self.frame.size.width - 20 - FUSendButton_Width - FUMarignSpaceWidth;
    _msgTextView.frame = textFrame;
}

- (void)setExtendDisabled:(BOOL)extendDisabled{
    _extendDisabled = extendDisabled;
    if (extendDisabled) {
        _sendButton.hidden = NO;
        _extendedButton.hidden = YES;
        [self updateInputTextViewFrame:(self.frame.size.width - FUMarignSpaceWidth * 2 - FUSendButton_Width - defaultX)];
    }
    else{
        _sendButton.hidden = YES;
        _extendedButton.hidden = NO;
        [self updateInputTextViewFrame:(self.frame.size.width - FUMarignSpaceWidth * 2 - FUButtonWidth - defaultX)];
    }
}

- (void)setVoiceDisabled:(BOOL)voiceDisabled{
    _voiceDisabled = voiceDisabled;
    if (voiceDisabled) {
        if (_menuButton.isHidden){
            return;
        }
        _voiceButton.hidden = YES;
        _menuButton.hidden = YES;
        defaultX = _msgTextView.frame.origin.x - FUButtonWidth - FUMarignSpaceWidth;
        
        CGRect msgTextViewFrame = _msgTextView.frame;
        msgTextViewFrame.origin.x = defaultX;
        msgTextViewFrame.size.width = _msgTextView.frame.size.width + FUButtonWidth + FUMarignSpaceWidth;
        _msgTextView.frame = msgTextViewFrame;
    }
    else{
        if (!_menuButton.isHidden) {
            return;
        }
        _menuButton.hidden = NO;
        defaultX = _msgTextView.frame.origin.x + FUButtonWidth + FUMarignSpaceWidth;
        
        CGRect msgTextViewFrame = _msgTextView.frame;
        msgTextViewFrame.origin.x = defaultX;
        msgTextViewFrame.size.width = _msgTextView.frame.size.width - FUButtonWidth - FUMarignSpaceWidth;
        _msgTextView.frame = msgTextViewFrame;
    }
}

- (void)setSmileDisabled:(BOOL)smileDisabled{
    _smileDisabled = smileDisabled;
    if (smileDisabled) {
        if (_smileButton.isHidden) {
            return;
        }
        _smileButton.hidden = YES;
        defaultX = _msgTextView.frame.origin.x - FUButtonWidth - FUMarignSpaceWidth;
        
        CGRect msgTextViewFrame = _msgTextView.frame;
        msgTextViewFrame.origin.x = defaultX;
        msgTextViewFrame.size.width = _msgTextView.frame.size.width + FUButtonWidth + FUMarignSpaceWidth;
        _msgTextView.frame = msgTextViewFrame;
    }
    else{
        if (!_smileButton.isHidden) {
            return;
        }
        _smileButton.hidden = NO;
        defaultX = _msgTextView.frame.origin.x + FUButtonWidth + FUMarignSpaceWidth;
        
        CGRect msgTextViewFrame = _msgTextView.frame;
        msgTextViewFrame.origin.x = defaultX;
        msgTextViewFrame.size.width = _msgTextView.frame.size.width - FUButtonWidth - FUMarignSpaceWidth;
        _msgTextView.frame = msgTextViewFrame;
    }
}

- (void)disabledFootViewMenuButtons{
    _voiceButton.enabled = false;
    _smileButton.enabled = false;
    _sendButton.enabled = false;
    _msgTextView.editable = false;
    _extendedButton.enabled = false;
    _menuButton.enabled = false;
    _intercomButton.enabled = false;
}

- (void)enableFootViewMenuButtons{
    _voiceButton.enabled = YES;
    _smileButton.enabled = YES;
    _sendButton.enabled = YES;
    _msgTextView.editable = YES;
    _extendedButton.enabled = YES;
    _menuButton.enabled = YES;
    _intercomButton.enabled = YES;
}

#pragma mark - 不同的IBActions

- (void)sendVoiceClipBtnPressed:(id) sender{
    
    UIImage * pressImage = [UIImage imageNamed:@"FUFootResource.bundle/voice_bt_down_Press"];
    pressImage = [pressImage stretchableImageWithLeftCapWidth:pressImage.size.width/2 topCapHeight:pressImage.size.height/2];
    [_voiceButton setBackgroundImage:pressImage forState:UIControlStateHighlighted];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if([audioSession respondsToSelector:@selector(requestRecordPermission:)])
    {
        __weak typeof(self) weakSelf = self;
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted == YES) {
                [weakSelf sendVoiceStart];
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(weakSelf.msgInputViewDelegate && [weakSelf.msgInputViewDelegate respondsToSelector:@selector(msgInputViewResetRecordIsCanUse)])
                    {
                        [weakSelf.msgInputViewDelegate msgInputViewResetRecordIsCanUse];
                    }
                    
                    UIAlertView * alertTool = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未启用麦克风，请到[设置]-[隐私]-[麦克风]中打开「医大帮」开关" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertTool show];
                    alertTool = nil;
                });
            }
        }];
    }
}

- (void)sendVoiceClipBtnTouchDragOutside:(id) sender{
    if (isEventTouchInside) {
        isEventTouchInside = FALSE;
        if (self.msgInputViewDelegate && [self.msgInputViewDelegate respondsToSelector:@selector(msgInputView:voiceClipBtnTouchDragOutside:)]) {
            [self.msgInputViewDelegate msgInputView:self voiceClipBtnTouchDragOutside:sender];
        }
    }
    
}

- (void)sendVoiceClipBtnTouchDragInside:(id) sender{
    if (!isEventTouchInside) {
        isEventTouchInside = TRUE;
        if (self.msgInputViewDelegate && [self.msgInputViewDelegate respondsToSelector:@selector(msgInputView:voiceClipBtnTouchDragInside:)]) {
            [self.msgInputViewDelegate msgInputView:self voiceClipBtnTouchDragInside:sender];
        }
    }
}

- (void)sendVoiceClipBtnTouchUpOutside:(id) sender{
    if (self.msgInputViewDelegate && [self.msgInputViewDelegate respondsToSelector:@selector(msgInputView:voiceClipBtnTouchUpOutside:)]) {
        [self.msgInputViewDelegate msgInputView:self voiceClipBtnTouchUpOutside:sender];
    }
}

- (void)showSmileFunctionView:(id)sender
{
    if (self.msgInputViewDelegate && [self.msgInputViewDelegate respondsToSelector:@selector(msgInputView:smileButtonPressed:)]) {
        [self.msgInputViewDelegate msgInputView:self smileButtonPressed:sender];
    }
}

- (void)sendVoiceClipBtnUp:(id) sender{
    _isRecording = NO;
    if (self.msgInputViewDelegate && [self.msgInputViewDelegate respondsToSelector:@selector(msgInputView:voiceClipBtnUp:)]) {
        [self.msgInputViewDelegate msgInputView:self voiceClipBtnUp:sender];
    }
}

-(void)sendVoiceStart
{
    _isRecording = YES;
    if(self.msgInputViewDelegate && [self.msgInputViewDelegate respondsToSelector:@selector(msgInputView:voiceButtonPressed:)])
    {
        [self.msgInputViewDelegate msgInputView:self voiceButtonPressed:_voiceButton];
    }
}

-(void)intercomButtonPressed:(id)sender
{
    BOOL isAllowSwitch = FALSE;
    if(_msgInputViewDelegate && [self.msgInputViewDelegate respondsToSelector:@selector(msgInputView:textVoiceButtonPressed:)])
    {
       isAllowSwitch =  [_msgInputViewDelegate msgInputView:self textVoiceButtonPressed:!_voiceButton.hidden];
    }
    if (isAllowSwitch) {
        if (_voiceButton.hidden) //切换到语音模式
        {
            [self switchVoiceInputModel];
            if (_msgInputViewDelegate && [_msgInputViewDelegate respondsToSelector:@selector(msgInputViewWithVoiceInputModel:)]) {
                [_msgInputViewDelegate msgInputViewWithVoiceInputModel:self];
            }
        }
        else //切换到文字模式
        {
            [self switchTextInputModel];
        }
    }
}

#pragma mark - 切换到语音模式

- (void)switchVoiceInputModel{
    _voiceButton.hidden = NO;
    _smileButton.hidden = YES;
    _menuButton.hidden = YES;
    _msgTextView.hidden = YES;
    _intercomButton.hidden = NO;
    if (_extendDisabled) {
        _extendedButton.hidden = YES;
        _sendButton.hidden = YES;
        CGFloat width = CGRectGetWidth(self.frame) - FUButtonWidth - FUMarignSpaceWidth*3;
        CGRect voiceFrame = _voiceButton.frame;
        voiceFrame.size.width = width;
        _voiceButton.frame = voiceFrame;
    }
    else
    {
        _extendedButton.hidden = NO;
        _sendButton.hidden = YES;
        if (self.changeCloseBtn) {
            AlertView *alert = [[AlertView alloc] initWithFrame:CGRectZero del:[[[UIApplication sharedApplication] windows] objectAtIndex:0]];
            [alert showAlertViewWithText:@"为了保证直播的有效性，不要使用语音"];
            [self switchCloseBtnWithOpen:YES];
        }
        
        CGFloat width = CGRectGetWidth(self.frame) - FUButtonWidth*2 - FUMarignSpaceWidth*4;
        CGRect voiceFrame = _voiceButton.frame;
        voiceFrame.size.width = width;
        _voiceButton.frame = voiceFrame;
    }
    [_msgTextView resignFirstResponder];
}

#pragma mark - 切换到文字模式

- (void)switchTextInputModel{
    _voiceButton.hidden = YES;
    _smileButton.hidden = _smileDisabled;
    _menuButton.hidden = _voiceDisabled;
    _msgTextView.hidden = NO;
    _intercomButton.hidden = YES;
    
    if (_extendDisabled) {
        _extendedButton.hidden = YES;
        _sendButton.hidden = NO;
        CGFloat width = CGRectGetWidth(self.frame) - FUButtonWidth - FUSendButton_Width - FUMarignSpaceWidth*4;
        CGRect voiceFrame = _voiceButton.frame;
        voiceFrame.size.width = width;
        _voiceButton.frame = voiceFrame;
    }
    else{
        _extendedButton.hidden = NO;
        _sendButton.hidden = YES;
        if (self.changeCloseBtn) {
            [self switchCloseBtnWithOpen:NO];
        }
        CGFloat width = CGRectGetWidth(self.frame) - FUButtonWidth*2 - FUMarignSpaceWidth*4;
        CGRect voiceFrame = _voiceButton.frame;
        voiceFrame.size.width = width;
        _voiceButton.frame = voiceFrame;
    }
    [_msgTextView becomeFirstResponder];
}

#pragma mark - 切换到更多模式

- (void)switchMoreInputModel{
    
    _voiceButton.hidden = YES;
    _menuButton.hidden = _voiceDisabled;
    _smileButton.hidden = _smileDisabled;
    _msgTextView.hidden = NO;
    _intercomButton.hidden = YES;
    _extendedButton.hidden = NO;
    _sendButton.hidden = YES;
}


#pragma mark  - 更多与关闭切换

- (void)switchCloseBtnWithOpen:(BOOL)open{
    if (open) {
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _extendedButton.transform = CGAffineTransformMakeRotation(M_PI/4*3);
        } completion:^(BOOL finished) {
            
        }];
    }
    else{
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _extendedButton.transform = CGAffineTransformMakeRotation(- M_PI/2);
        } completion:^(BOOL finished) {
            
        }];
    }
}



#pragma mark - UITextViewDelegate

- (void)updateTextViewFrame{
    [self textViewDidChange:_msgTextView];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if(_msgInputViewDelegate && [_msgInputViewDelegate respondsToSelector:@selector(msgInputViewBeginClick:)])
    {
        return [_msgInputViewDelegate msgInputViewBeginClick:self];
    }
    
    return TRUE;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return TRUE;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
//    [self resetTextView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkTextViewLength:) object:textView];
    [self performSelector:@selector(checkTextViewLength:) withObject:textView afterDelay:0.0];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if(_msgTextView != textView)
    {
        return;
    }
    NSString* textViewContent = [_msgTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([textViewContent length] > 0)
    {
        [_msgTextView setIsShowPlaceHolder:NO];
        _sendButton.enabled = TRUE;
        
        if (!_onlyText) {
            _sendButton.hidden = NO;
            _extendedButton.hidden = YES;
            
            [self updateInputTextViewFrame:(self.frame.size.width - FUMarignSpaceWidth*2 - FUSendButton_Width - defaultX)];
        }
    }
    else
    {
        [_msgTextView setIsShowPlaceHolder:YES];
        
        if (!_onlyText) {
            _sendButton.enabled = FALSE;
            
            if(!_extendDisabled)
            {
                _sendButton.hidden = YES;
                _extendedButton.hidden = NO;
                [self updateInputTextViewFrame:(self.frame.size.width - FUMarignSpaceWidth*2 - FUButtonWidth - defaultX)];
            }
        }
    }
    
    [self resetTextView];
}


#pragma mark - private

-(void) checkTextViewLength:(UITextView *)textView{
    NSString * textViewStr = textView.text;
    NSUInteger lengthStr = [self lenghtWithString:textViewStr];
    if (lengthStr > ContentLimitWords) {
        while (lengthStr > ContentLimitWords) {
            CGFloat location = textViewStr.length - 1;
            textViewStr = [textViewStr substringToIndex:location];
            lengthStr = [self lenghtWithString:textViewStr];
        }
        textView.text = textViewStr;
    }
}

- (NSUInteger) lenghtWithString:(NSString *)string
{
    NSUInteger len = string.length;
    // 汉字字符集
    NSString * pattern  = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    // 计算中文字符的个数
    NSInteger numMatch = [regex numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, len)];
    
    return len + numMatch;
}


- (void)updateInputTextViewFrame:(CGFloat) width{
    CGRect msgTextViewFrame = _msgTextView.frame;
    msgTextViewFrame.size.width = width;
    _msgTextView.frame = msgTextViewFrame;
}

- (void)resetTextView{
    NSInteger newSizeH = _msgTextView.contentSize.height - 6;
    
    if([_msgTextView.text length] == 0)
    {
        newSizeH = FUTextViewHeight;
        
        [_msgTextView setContentSize:CGSizeMake(_msgTextView.contentSize.width, newSizeH)];
    }
    if(newSizeH <= FUTextViewHeight)
    {
        newSizeH = FUTextViewHeight;
    }
    else if(newSizeH >= _maxHeight)
    {
        newSizeH = _maxHeight;
    }
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height += (newSizeH - _preHeight);
    self.frame = selfFrame;
    
    CGRect textViewframe = _msgTextView.frame;
    textViewframe.size.height = newSizeH;
    _msgTextView.frame = textViewframe;

    
    if(self.msgInputViewDelegate && [self.msgInputViewDelegate respondsToSelector:@selector(msgInputView:changeHeight:)])
    {
        [self.msgInputViewDelegate msgInputView:self changeHeight:(newSizeH - _preHeight)];
    }
    
    _preHeight = newSizeH;
}


// 更新输入框内容
- (void)updateTextView
{
    [self resetTextView];
}

- (void)showExtendedFunctionView:(id)sender{

    if (self.changeCloseBtn && !_voiceButton.hidden) {
        if (_msgInputViewDelegate && [_msgInputViewDelegate respondsToSelector:@selector(closeCurrentView)])
        {
            [_msgInputViewDelegate closeCurrentView];
        }
        return;
    }
    
    [self switchMoreInputModel];
    if (_msgInputViewDelegate && [_msgInputViewDelegate respondsToSelector:@selector(msgInputView:moreButtonPressed:)])
    {
        [_msgInputViewDelegate msgInputView:self moreButtonPressed:sender];
    }
}

- (void)sendMeaageEvent:(id)sender{
    _sendButton.enabled = FALSE;
    if (!_onlyText) {
        if(!_extendDisabled)
        {
            _sendButton.hidden = YES;
            _extendedButton.hidden = NO;
            [self updateInputTextViewFrame:(self.frame.size.width - FUMarignSpaceWidth*2 - FUButtonWidth - defaultX)];
        }
    }
    
    if (_msgInputViewDelegate && [_msgInputViewDelegate respondsToSelector:@selector(msgInputView:sendMessageButtonPressed:)]) {
        [_msgInputViewDelegate msgInputView:self sendMessageButtonPressed:sender];
    }
}
@end
