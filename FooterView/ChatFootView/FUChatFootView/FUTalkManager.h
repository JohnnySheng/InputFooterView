//
//  FUTalkManager.h
//  DemoForHR
//
//  Created by "" on 14-8-15.
//  Copyright (c) 2014年 fuya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@protocol FUTalkManagerDelegate;

/**
 *  录音及播放功能类
 */
@interface FUTalkManager : NSObject <AVAudioRecorderDelegate>{
    
    NSTimer* timer;
    NSTimer* timer_;
    
    AVAudioPlayer* _audioPlayer;
    
}
@property (nonatomic, weak) id<FUTalkManagerDelegate> talkManagerDelegate;
@property (nonatomic) int recordTime;
@property (nonatomic, strong) AVAudioPlayer* audioPlayer;
@property (nonatomic, assign) BOOL isVoiceClipBtnTouchUpOutside;


+ (id)sharedFUTalkManager;

/**
 *	@brief	开始录音
 *
 *	@return	N/A
 */
- (void) startRecord;

/**
 *	@brief	暂停录音
 *
 *	@return	N/A
 */
- (void) pauseRecord;

/**
 *	@brief	恢复录音
 *
 *	@return	N/A
 */
- (void) resumeRecord;

/**
 *	@brief	停止并删除录音
 *
 *	@return	N/A
 */
- (void)deleteAndStopRecord;


/**
 *	@brief	停止录音
 *
 *	@return	N/A
 */
- (void) stopRecord;

/**
 *	@brief	播放录音
 *
 *	@return	N/A
 */
- (void) playVoice:(NSString *)filePath;

/**
 *	@brief	停止播放录音
 *
 *	@return	N/A
 */
- (void) stopVoice;

@end

@protocol  FUTalkManagerDelegate <NSObject>

@optional

- (void)talkManager:(FUTalkManager* ) talkManager volume:(CGFloat) currentVolume;

- (void)talkManager:(FUTalkManager *)talkManager peakPowerForChannel:(double)currentPeakPowerForChannel;

- (void)talkManager:(FUTalkManager *)talkManager stopRecord:(NSString* )recordPath timeLong:(long)time;

- (void)talkManagerPlayWithAudio:(FUTalkManager *)talkManager;

- (void)talkManagerStopWithAudio:(FUTalkManager *)talkManager;

- (void)talkManager:(FUTalkManager *)talkManager finishedAudio:(BOOL) flag;

- (void)talkManager:(FUTalkManager *)talkManager timeTransient:(NSUInteger)time;

@end
