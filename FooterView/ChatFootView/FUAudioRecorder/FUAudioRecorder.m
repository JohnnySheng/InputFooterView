//
//  FUAudioRecorder.m
//  DemoForHR
//
//  Created by "" on 14-9-11.
//  Copyright (c) 2014年 fuya. All rights reserved.
//

#import "FUAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

/**
 *  错误标识
 */
typedef NS_OPTIONS(NSUInteger, FUAudioRecorderErrorCode) {
    FUAudioRecorderErrorCodeAboutFile = 0, //文件操作错误
    FUAudioRecorderErrorCodeAboutQueue, //音频输入队列错误
    FUAudioRecorderErrorCodeAboutSession, //AudioSession错误
    FUAudioRecorderErrorCodeAboutOther, //其他错误
};

/**相关Code描述*/
#define FUAudioRecorderErrorCodeAboutFileDescription            @"音频输入关闭文件失败"
#define FUAudioQueueStartErrorCodeDescription                   @"开始音频输入队列失败"
#define FUAudioQueueEnqueueBufferErrorCodeDescription           @"音频输入队列缓冲区准备失败"
#define FUAudioQueueAllocateBufferErrorCodeDescription          @"音频输入队列建立缓冲区失败"
#define FUAudioQueueNewInputErrorCodeDescription                @"音频输入队列初始化失败"
#define FUAudioRecorderErrorCodeAboutFileCreateDescription      @"音频输入建立文件失败"
#define FUAudioRecorderErrorCodeAboutOtherNoImpDelegateDescription  @"代理未设置或其代理方法不完整"
#define FUAVAudioSessionCategorySettingFailDescription          @"AVAudioSession设置Category失败"
#define FUActiveAVAudioSessionSettingFailDescription            @"Active AVAudioSession失败"

#define kNumberAudioQueueBuffers 3          /**缓存区的个数*/
#define kDefaultBufferDurationSeconds 0.5      /**每次的音频输入队列缓存区所保存的是多少秒的数据*/
#define kDefaultSampleRate 8000         /**采样率*/

#define kFUAudioRecorderErrorDomain @"FUAudioRecorderErrorDomain"


#define IfAudioQueueErrorPostAndReturn(operation,error) \
if(operation!=noErr) { \
[self postAErrorWithErrorCode:FUAudioRecorderErrorCodeAboutQueue andDescription:error]; \
return; \
}   \

@interface FUAudioRecorder(){

    //定义音频缓冲区
    AudioQueueBufferRef _audioBuffers[kNumberAudioQueueBuffers];
}

@property (nonatomic, strong) dispatch_queue_t writeFileQueue;
@property (nonatomic, strong) dispatch_semaphore_t semError; //信号量
@property (nonatomic, assign) BOOL isRecording;
@end

@implementation FUAudioRecorder
@synthesize fileWriterDelegate = _fileWriterDelegate;
@synthesize delegate = _delegate;

- (id)init{
    self =  [super init];
    if (self) {
        
        self.writeFileQueue = dispatch_queue_create("com.izhixin.FUAudioRecorder.writeFileQueue", NULL);
        
        self.sampleRate = kDefaultSampleRate;
        self.bufferDurationSeconds = kDefaultBufferDurationSeconds;
        
        //TODO 设置录音相关参数
        [self setupAudioFormat:kAudioFormatLinearPCM SampleRate:self.sampleRate];
    }
    
    return self;
}

/**
 *  设置录音相关参数
 *
 *  @param inFormatID   inFormat编号
 *  @param sampeleRate 采样率
 */
- (void)setupAudioFormat:(UInt32) inFormatID SampleRate:(int)sampeleRate{
    
    memset(&_audioStreamBasicFormat, 0, sizeof(_audioStreamBasicFormat));
    
    _audioStreamBasicFormat.mSampleRate = sampeleRate;
    
    _audioStreamBasicFormat.mChannelsPerFrame = 1;
    
    _audioStreamBasicFormat.mFormatID = inFormatID;
    
    if (inFormatID == kAudioFormatLinearPCM) {
        
        _audioStreamBasicFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        
        _audioStreamBasicFormat.mBitsPerChannel = 16;
        
        _audioStreamBasicFormat.mBytesPerPacket = _audioStreamBasicFormat.mBytesPerFrame = (_audioStreamBasicFormat.mBitsPerChannel / 8) * _audioStreamBasicFormat.mChannelsPerFrame;
        
		_audioStreamBasicFormat.mFramesPerPacket = 1;

    }
}

/**
 *  开始录音
 */
- (void)startRecording{
    
    NSError *error = nil;
    
    //中断监听处理
    AudioSessionInitialize(NULL,NULL,audioSessionInterruptHandler,(__bridge void *)(self));
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    BOOL ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!ret) {
        //TODO 异常处理
        [self postAErrorWithErrorCode:FUAudioRecorderErrorCodeAboutSession andDescription:FUAVAudioSessionCategorySettingFailDescription];
        return;
    }
    
//    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
//    if (!ret)
//    {
//        //TODO 异常处理
//        [self postAErrorWithErrorCode:FUAudioRecorderErrorCodeAboutSession andDescription:FUActiveAVAudioSessionSettingFailDescription];
//        return;
//    }
    
    if(!self.fileWriterDelegate||![self.fileWriterDelegate respondsToSelector:@selector(createFileWithRecorder:)]||![self.fileWriterDelegate respondsToSelector:@selector(writeIntoFileWithData:withRecorder:inAQ:inStartTime:inNumPackets:inPacketDesc:)]||![self.fileWriterDelegate respondsToSelector:@selector(completeWriteWithRecorder:withIsError:)]){
        //TODO 异常处理
        [self postAErrorWithErrorCode:FUAudioRecorderErrorCodeAboutOther andDescription:FUAudioRecorderErrorCodeAboutOtherNoImpDelegateDescription];
        return;
    }
    
    __block BOOL isContinue = YES;;
    dispatch_sync(self.writeFileQueue, ^{
        if(self.fileWriterDelegate&&![self.fileWriterDelegate createFileWithRecorder:self]){
            dispatch_async(dispatch_get_main_queue(),^{
               //TODO 异常情况处理
                [self postAErrorWithErrorCode:FUAudioRecorderErrorCodeAboutFile andDescription:FUAudioRecorderErrorCodeAboutFileCreateDescription];
            });
            isContinue = NO;
        }
    });

    if(!isContinue){
        return;
    }
    
    self.semError = dispatch_semaphore_create(0); //重新初始化信号量标识
    dispatch_semaphore_signal(self.semError); //设置有一个信号
    
    _audioStreamBasicFormat.mSampleRate = self.sampleRate;
    
    //录音回调函数
    IfAudioQueueErrorPostAndReturn(AudioQueueNewInput(&_audioStreamBasicFormat, inputBufferHandler, (__bridge void *)(self), NULL, NULL, 0, &_audioQueue),FUAudioQueueNewInputErrorCodeDescription);
    
    int frames = (int)ceil(self.bufferDurationSeconds * _audioStreamBasicFormat.mSampleRate);
    int bufferByteSize = frames * _audioStreamBasicFormat.mBytesPerFrame;
    for (int i = 0; i < kNumberAudioQueueBuffers; ++i){
        
        IfAudioQueueErrorPostAndReturn(AudioQueueAllocateBuffer(_audioQueue, bufferByteSize, &_audioBuffers[i]),FUAudioQueueAllocateBufferErrorCodeDescription);
        IfAudioQueueErrorPostAndReturn(AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL),FUAudioQueueEnqueueBufferErrorCodeDescription);
    }
    
    //开始录音
    IfAudioQueueErrorPostAndReturn(AudioQueueStart(_audioQueue, NULL),FUAudioQueueStartErrorCodeDescription);

    self.isRecording = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorderStart:)]) {
        [self.delegate audioRecorderStart:self];
    }
    
}

/**
 *  中断监听回调,需要补充操作
 *
 *  @param inClientData        参数
 *  @param inInterruptionState 中断状态
 */
void audioSessionInterruptHandler(void* inClientData, UInt32 inInterruptionState){
    NSLog(@"audioSessionInterruptHandler");
//    FUAudioRecorder *recorder;
//    @try {
//        recorder = (__bridge FUAudioRecorder *)(inClientData);
//        if (inInterruptionState == kAudioSessionBeginInterruption) {
//            if (recorder.delegate && [recorder.delegate respondsToSelector:@selector(audioRecorderBeginInterruption:)]) {
//                [recorder.delegate audioRecorderBeginInterrupt:recorder];
//            }
//        }
//        
//        if (inInterruptionState == kAudioSessionEndInterruption) {
//            if (recorder.delegate && [recorder.delegate respondsToSelector:@selector(audioRecorderEndInterrupt:)]) {
//                [recorder.delegate audioRecorderEndInterrupt:recorder];
//            }
//        }
//    } @catch (NSException *exception) {
//        NSLog(@"%@", exception.description);
//    } @finally {
//        
//    }
//    
//    
}

void inputBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc){
    
    FUAudioRecorder *recorder = (__bridge FUAudioRecorder*)inUserData;
    
    if (inNumPackets > 0) {
        NSData *pcmData = [[NSData alloc]initWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        
        if (pcmData&&pcmData.length>0) {
            
            dispatch_async(recorder.writeFileQueue, ^{
                if (recorder.fileWriterDelegate&&![recorder.fileWriterDelegate writeIntoFileWithData:pcmData withRecorder:recorder inAQ:inAQ inStartTime:inStartTime inNumPackets:inNumPackets inPacketDesc:inPacketDesc]) {
                    if (dispatch_semaphore_wait(recorder.semError,DISPATCH_TIME_NOW)==0){
                        dispatch_async(dispatch_get_main_queue(),^{
                           //TODO  异常处理
                            
                        });
                    }
                }
            });
        }
    }
    
    if (recorder.isRecording) {
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}

/**
 *  停止录音
 */
- (void)stopRecording{
    
    if (self.isRecording) {
        self.isRecording = NO;
        
        AudioQueueFlush(_audioQueue);
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true);
        
//        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        
        
        __block BOOL isContinue = YES;
        dispatch_sync(self.writeFileQueue, ^{
            if (self.fileWriterDelegate&&![self.fileWriterDelegate completeWriteWithRecorder:self withIsError:NO]) {
                dispatch_async(dispatch_get_main_queue(),^{
                    //TODO 异常处理
                    [self postAErrorWithErrorCode:FUAudioRecorderErrorCodeAboutFile andDescription:FUAudioRecorderErrorCodeAboutFileDescription];
                });
                isContinue = NO;
            }
        });
        if(!isContinue) return;
       
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorderStop:)]) {
            [self.delegate audioRecorderStop:self];
        }
    }
}

/**
 *  暂停录音
 */
- (void)suspendRecording{

    IfAudioQueueErrorPostAndReturn(AudioQueuePause(_audioQueue),
                                   FUAudioQueueStartErrorCodeDescription);
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorderSuspend:)]) {
        [self.delegate audioRecorderSuspend:self];
    }
}

/**
 *  恢复录音
 */
- (void)resumeRecording{
    
    IfAudioQueueErrorPostAndReturn(AudioQueueStart(_audioQueue, NULL),
                                   FUAudioQueueStartErrorCodeDescription);
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorderResume:)]) {
        [self.delegate audioRecorderResume:self];
    }
    
}

- (AudioQueueRef)getAudioQueueRef{
    return _audioQueue;
}

- (void)postAErrorWithErrorCode:(FUAudioRecorderErrorCode)code andDescription:(NSString*)description
{
    self.isRecording = NO;
    
    AudioQueueStop(_audioQueue, true);
    AudioQueueDispose(_audioQueue, true);
//    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    if(self.fileWriterDelegate){
        dispatch_sync(self.writeFileQueue, ^{
            [self.fileWriterDelegate completeWriteWithRecorder:self withIsError:YES];
        });
    }
    
    NSLog(@"录音发生错误");
    
    NSError *error = [NSError errorWithDomain:kFUAudioRecorderErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:description}];
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(recordError:)]){
        [self.delegate recordError:error];
    }
}

@end
