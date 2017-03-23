//
//  FUAudioMeterObserver.h
//    
//
//    on 14-9-11.
//  Copyright (c) 2014年 fuya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class FUAudioMeterObserver;

typedef void (^FUAudioMeterObserverActionBlock)(NSArray *levelMeterStates,FUAudioMeterObserver *meterObserver);
typedef void (^FUAudioMeterObserverErrorBlock)(NSError *error,FUAudioMeterObserver *meterObserver);

/**
 *  错误标识
 */
typedef NS_OPTIONS(NSUInteger, FUAudioMeterObserverErrorCode) {
    FUAudioMeterObserverErrorCodeAboutQueue, //音频输入队列错误
};

@interface LevelMeterState : NSObject

@property (nonatomic, assign) Float32 mAveragePower;
@property (nonatomic, assign) Float32 mPeakPower;

@end

@interface FUAudioMeterObserver : NSObject{
    AudioQueueRef				_audioQueue;
	AudioQueueLevelMeterState	*_levelMeterStates;
}

@property AudioQueueRef audioQueue;

@property (nonatomic, copy) FUAudioMeterObserverActionBlock actionBlock;

@property (nonatomic, copy) FUAudioMeterObserverErrorBlock errorBlock;

@property (nonatomic, assign) NSTimeInterval refreshInterval; //刷新间隔,默认0.1

/**
 *  根据meterStates计算出音量，音量为 0-1
 *
 */
+ (Float32)volumeForLevelMeterStates:(NSArray*)levelMeterStates;

@end
