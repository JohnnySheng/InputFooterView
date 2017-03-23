//
//  FUAudioRecorder.h
//  DemoForHR
//
//  Created by "" on 14-9-11.
//  Copyright (c) 2014年 fuya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class FUAudioRecorder;

@protocol FUAudioRecorderDelegate <NSObject>

@optional
/**
 *  开始录音回调
 *
 *  @param audioRecorder
 */
- (void)audioRecorderStart:(FUAudioRecorder* ) audioRecorder;

/**
 *  结束录音回调
 *
 *  @param audioRecorder
 */
- (void)audioRecorderStop:(FUAudioRecorder* ) audioRecorder;

/**
 *  暂停录音回调
 *
 *  @param audioRecorder
 */
- (void)audioRecorderSuspend:(FUAudioRecorder *)audioRecorder;

/**
 *  恢复录音回调
 *
 *  @param audioRecorder
 */
- (void)audioRecorderResume:(FUAudioRecorder *)audioRecorder;

/**
 *  开始中断录音回调，暂未实现audioSessionInterruptHandler
 *
 *  @param audioRecorder
 */
- (void)audioRecorderBeginInterrupt:(FUAudioRecorder *)audioRecorder;

/**
 *  结束中断录音回调，暂未实现audioSessionInterruptHandler
 *
 *  @param audioRecorder
 */
- (void)audioRecorderEndInterrupt:(FUAudioRecorder *)audioRecorder;

@required
/**
 *  录音遇到了错误，例如创建文件失败、写入失败、关闭文件失败等等。
 */
- (void)recordError:(NSError *)error;

@end

@protocol FileWriterForFUAudioRecorder <NSObject>

@required

- (BOOL)createFileWithRecorder:(FUAudioRecorder* ) audioRecorder;
- (BOOL)writeIntoFileWithData:(NSData*)data withRecorder:(FUAudioRecorder* )recoder inAQ:(AudioQueueRef)						inAQ inStartTime:(const AudioTimeStamp *)inStartTime inNumPackets:(UInt32)inNumPackets inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc;

- (BOOL)completeWriteWithRecorder:(FUAudioRecorder* )recoder withIsError:(BOOL)isError;
@end


@interface FUAudioRecorder : NSObject{

    AudioQueueRef _audioQueue;  /**音频输入队列*/
    AudioStreamBasicDescription _audioStreamBasicFormat; /**音频输入参数设置*/

}

/**
 *  是否正在录音
 */
@property (nonatomic, assign,readonly) BOOL isRecording;
@property (nonatomic, assign) NSUInteger sampleRate;
@property (nonatomic, assign) double bufferDurationSeconds;
@property (nonatomic, weak) id<FileWriterForFUAudioRecorder> fileWriterDelegate;
@property (nonatomic, weak) id<FUAudioRecorderDelegate> delegate;


- (AudioQueueRef)getAudioQueueRef;

/**
 *  开始录音
 */
- (void)startRecording;

/**
 *  结束录音
 */
- (void)stopRecording;

/**
 *  暂停录音
 */
- (void)suspendRecording;

/**
 *  恢复录音
 */
- (void)resumeRecording;



@end
