//
//  FURecordToastView.h
//  DemoForHR
//
//  Created by "" on 14-8-14.
//  Copyright (c) 2014年 fuya. All rights reserved.
//
#define FURecordToastViewWidth               130
#define FURecordToastViewHeight              130


#import <UIKit/UIKit.h>

/**
 *  录音提示视图
 */
@interface FURecordToastView : UIView{
    UIImageView* _imageView;
    UIImageView* _volumeAnimationView;
}

@property (strong, nonatomic) UIImageView* imageView;
@property (strong, nonatomic) UIImageView* volumeAnimationView;
@property (strong, nonatomic) NSString* imageToastName;

- (void)updatePeakPowerForChannelUI:(double)currentPeakPowerForChannel;

@end
