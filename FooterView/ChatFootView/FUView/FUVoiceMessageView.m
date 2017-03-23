//
//  FUVoiceMessageView.m
//
//  Copyright (c) 2014年 fuya. All rights reserved.
//

#import "FUVoiceMessageView.h"

#define VoiceImageView_Width 20
#define VoiceImageView_Height 20

@interface FUVoiceMessageView(){
    NSMutableArray* animationImagesArray;
}
@end

@implementation FUVoiceMessageView
@synthesize voiceImageView = _voiceImageView;

- (void)updateVoiceImageViewImageAndAnimationImages:(ViewPosition)viewPosition imageNameKey:(NSString *)key
{
    NSString * keyName = @"";
    if (key != nil) {
        keyName = @"_w";
    }
    
    NSString * namePath = nil;
    if (viewPosition == ViewPositionLeft) {
        namePath = [NSString stringWithFormat:@"FUFootResource.bundle/voice_noplay_%@_normal%@",@"left",keyName];
    }
    else if(viewPosition == ViewPositionRight)
    {
        namePath = [NSString stringWithFormat:@"FUFootResource.bundle/voice_noplay_%@_normal%@",@"right",keyName];
    }
    
    
    _voiceImageView.image = [UIImage imageNamed:namePath];

    _voiceImageView.animationImages = [self createAnimationImages:viewPosition imageNameKey:key];
    _voiceImageView.animationDuration = 1.f;
    _voiceImageView.animationRepeatCount = 0;
    _voiceImageView.userInteractionEnabled = TRUE;

    [_voiceImageView setNeedsDisplay];
}

- (void)updateVoiceImageViewImageAndAnimationImages:(BOOL) messageReceive{
    if (!messageReceive) {
        [self updateVoiceImageViewImageAndAnimationImages:ViewPositionRight imageNameKey:nil];
        _voiceImageView.image = [UIImage imageNamed:@"FUFootResource.bundle/voice_noplay_right_normal"];
    }else{
        [self updateVoiceImageViewImageAndAnimationImages:ViewPositionLeft imageNameKey:nil];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _voiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, VoiceImageView_Width, VoiceImageView_Height)];
        [self addSubview:_voiceImageView];
    }
    
    return self;
}

- (NSArray *)createAnimationImages:(ViewPosition)viewPosition imageNameKey:(NSString *)key
{
    if (animationImagesArray) {
        [animationImagesArray removeAllObjects];
        animationImagesArray = nil;
    }
    
    NSString * keyName = @"";
    if (key != nil) {
        keyName = @"_w";
    }
    
    NSString* animationImageName_one = nil;
    NSString* animationImageName_two = nil;
    NSString* animationImageName_three = nil;
    
    NSString * namePath = nil;
    if (viewPosition == ViewPositionLeft) {
        animationImageName_one = [NSString stringWithFormat:@"FUFootResource.bundle/voice_play_%@_animation%@_one",@"left",keyName];
        animationImageName_two = [NSString stringWithFormat:@"FUFootResource.bundle/voice_play_%@_animation%@_two",@"left",keyName];
        animationImageName_three = [NSString stringWithFormat:@"FUFootResource.bundle/voice_play_%@_animation%@_three",@"left",keyName];
    }
    else if(viewPosition == ViewPositionRight)
    {
        animationImageName_one = [NSString stringWithFormat:@"FUFootResource.bundle/voice_play_%@_animation%@_one",@"right",keyName];
        animationImageName_two = [NSString stringWithFormat:@"FUFootResource.bundle/voice_play_%@_animation%@_two",@"right",keyName];
        animationImageName_three = [NSString stringWithFormat:@"FUFootResource.bundle/voice_play_%@_animation%@_three",@"right",keyName];
    }

    animationImagesArray = [[NSMutableArray alloc] initWithCapacity:0];
    [animationImagesArray addObject:[UIImage imageNamed:animationImageName_one]];
    [animationImagesArray addObject:[UIImage imageNamed:animationImageName_two]];
    [animationImagesArray addObject:[UIImage imageNamed:animationImageName_three]];
    
    return animationImagesArray;
}

- (void)dealloc{
    if ([animationImagesArray count] > 0) {
        [animationImagesArray removeAllObjects];
        animationImagesArray = nil;
    }
    
    _voiceImageView = nil;
}
@end
