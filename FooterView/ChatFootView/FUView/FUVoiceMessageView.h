//
//  FUVoiceMessageView.h
//  
//
//
//  Copyright (c) 2014年 fuya. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ViewPositionLeft,
    ViewPositionRight,
} ViewPosition;

@interface FUVoiceMessageView : UIView{
    UIImageView* _voiceImageView;
}
@property (nonatomic, strong) UIImageView* voiceImageView;

- (void)updateVoiceImageViewImageAndAnimationImages:(BOOL) messageReceive;

- (void)updateVoiceImageViewImageAndAnimationImages:(ViewPosition)viewPosition imageNameKey:(NSString *)key;

@end
