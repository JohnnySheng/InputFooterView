//
//  FURecordToastView.m
//  DemoForHR
//
//  Created by "" on 14-8-14.
//  Copyright (c) 2014年 fuya. All rights reserved.
//

#import "FURecordToastView.h"
#import <QuartzCore/QuartzCore.h>
//TODO:  gzf 
@implementation FURecordToastView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = TRUE;
        self.userInteractionEnabled = FALSE;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView];
        
        UIImage * animateImg = [UIImage imageNamed:@"FUFootResource.bundle/shouzhishanghua_1"];
        _volumeAnimationView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 15, animateImg.size.width, animateImg.size.height)];
        _volumeAnimationView.backgroundColor = [UIColor clearColor];
        [_volumeAnimationView setImage:animateImg];
        [_imageView addSubview:_volumeAnimationView];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    _imageView.image = [UIImage imageNamed:_imageToastName];
}

- (void)setImageToastName:(NSString *)imageToastName{
    if (_imageToastName != imageToastName) {
        _imageToastName = nil;
        _imageToastName = imageToastName;
        [self setNeedsDisplay];
    }
}

- (void)updatePeakPowerForChannelUI:(double)currentPeakPowerForChannel{
    if (currentPeakPowerForChannel > 0 && currentPeakPowerForChannel <= 0.10) {
        [_volumeAnimationView setImage:[UIImage imageNamed:@"FUFootResource.bundle/shouzhishanghua_1"]];
    }else if (currentPeakPowerForChannel > 0.10 && currentPeakPowerForChannel<= 0.20){
         [_volumeAnimationView setImage:[UIImage imageNamed:@"FUFootResource.bundle/shouzhishanghua_2"]];
    }else if (currentPeakPowerForChannel > 0.20 && currentPeakPowerForChannel <= 0.30){
        [_volumeAnimationView setImage:[UIImage imageNamed:@"FUFootResource.bundle/shouzhishanghua_3"]];
    }else if (currentPeakPowerForChannel > 0.30 && currentPeakPowerForChannel <= 0.40){
        [_volumeAnimationView setImage:[UIImage imageNamed:@"FUFootResource.bundle/shouzhishanghua_4"]];
    }else if (currentPeakPowerForChannel > 0.40 && currentPeakPowerForChannel <= 0.50){
        [_volumeAnimationView setImage:[UIImage imageNamed:@"FUFootResource.bundle/shouzhishanghua_5"]];
    }else if(currentPeakPowerForChannel > 0.50){
        [_volumeAnimationView setImage:[UIImage imageNamed:@"FUFootResource.bundle/shouzhishanghua_6"]];
    }
}
@end
