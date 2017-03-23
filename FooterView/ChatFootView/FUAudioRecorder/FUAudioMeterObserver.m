//
//  FUAudioMeterObserver.m
//    
//
//    on 14-9-11.
//  Copyright (c) 2014年 fuya. All rights reserved.
//

#import "FUAudioMeterObserver.h"

#define kDefaultRefreshInterval 0.1 //默认0.1秒刷新一次
#define kMLAudioMeterObserverErrorDomain @"FUAudioMeterObserverErrorDomain"

#define IfAudioQueueErrorPostAndReturn(operation,error) \
if(operation!=noErr) { \
[self postAErrorWithErrorCode:FUAudioMeterObserverErrorCodeAboutQueue andDescription:error]; \
return; \
}   \


@implementation LevelMeterState

@end

@interface FUAudioMeterObserver()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger channelCount;

@end


@implementation FUAudioMeterObserver

- (instancetype)init
{
    self = [super init];
    if (self) {
        _refreshInterval = kDefaultRefreshInterval;
        _levelMeterStates = (AudioQueueLevelMeterState*)malloc(sizeof(AudioQueueLevelMeterState) * 0);
    }
    return self;
}


- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - setter and getter
- (void)setRefreshInterval:(NSTimeInterval)refreshInterval
{
    _refreshInterval = refreshInterval;
    
    //重置timer
    [self.timer invalidate];
    self.timer = [NSTimer
                  scheduledTimerWithTimeInterval:refreshInterval
                  target:self
                  selector:@selector(refresh)
                  userInfo:nil
                  repeats:YES
                  ];
}

- (AudioQueueRef)audioQueue
{
	return _audioQueue;
}

- (void)setAudioQueue:(AudioQueueRef)audioQueue
{
    if (_audioQueue!=NULL&&audioQueue == _audioQueue){
        return;
    }
    
    //关闭定时器
    [self.timer invalidate];
    self.timer = nil;
    if (audioQueue==NULL){
        return;
    }
    
    _audioQueue = audioQueue;

    UInt32 val = 1;
    IfAudioQueueErrorPostAndReturn(AudioQueueSetProperty(audioQueue, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32)), @"couldn't enable metering");
    
    if (!val){
        //TODO 错误处理
        
        return;
    }
    
    AudioStreamBasicDescription queueFormat;
    UInt32 data_sz = sizeof(queueFormat);
    IfAudioQueueErrorPostAndReturn(AudioQueueGetProperty(audioQueue, kAudioQueueProperty_StreamDescription, &queueFormat, &data_sz), @"couldn't get stream description");
    
    self.channelCount = queueFormat.mChannelsPerFrame;
    
    //重新初始化大小
    _levelMeterStates = (AudioQueueLevelMeterState*)realloc(_levelMeterStates, self.channelCount * sizeof(AudioQueueLevelMeterState));
    
    //重新设置timer
    self.timer = [NSTimer
                  scheduledTimerWithTimeInterval:self.refreshInterval
                  target:self
                  selector:@selector(refresh)
                  userInfo:nil
                  repeats:YES
                  ];
}

- (void)refresh
{
    UInt32 data_sz = sizeof(AudioQueueLevelMeterState) * self.channelCount;
    
    IfAudioQueueErrorPostAndReturn(AudioQueueGetProperty(_audioQueue, kAudioQueueProperty_CurrentLevelMeterDB, _levelMeterStates, &data_sz),@"获取meter数据失败");
    
    //转化成LevelMeterState数组传递到block
    NSMutableArray *meters = [NSMutableArray arrayWithCapacity:self.channelCount];
    
    for (int i=0; i<self.channelCount; i++)
    {
        LevelMeterState *state = [[LevelMeterState alloc]init];
        state.mAveragePower = _levelMeterStates[i].mAveragePower;
        state.mPeakPower = _levelMeterStates[i].mPeakPower;
        [meters addObject:state];
    }
    if(self.actionBlock){
        self.actionBlock(meters,self);
    }
}

- (void)postAErrorWithErrorCode:(FUAudioMeterObserverErrorCode)code andDescription:(NSString*)description
{
    self.audioQueue = nil;
    
    NSError *error = [NSError errorWithDomain:kMLAudioMeterObserverErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:description}];
    
    if( self.errorBlock){
        self.errorBlock(error,self);
    }
}

+ (Float32)volumeForLevelMeterStates:(NSArray*)levelMeterStates
{
    
    Float32 averagePowerOfChannels = 0;
    for (int i=0; i<levelMeterStates.count; i++)
    {
        averagePowerOfChannels+=((LevelMeterState*)levelMeterStates[i]).mAveragePower;
    }
    
    Float32 volume = pow(10, (0.05 * averagePowerOfChannels/levelMeterStates.count));
    
    return volume;
}


@end
