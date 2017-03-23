//
//  FUTalkManager.m
//  DemoForHR
//
//  Created by "" on 14-8-15.
//  Copyright (c) 2014年 fuya. All rights reserved.
//

#import "FUTalkManager.h"
#import "AlertView.h"
#import <math.h>
#import "FUMp3RecordWriter.h"
#import "FUAudioRecorder.h"
#import "FUAudioMeterObserver.h"
#import "lame.h"
#import "mp3.h"
#import "VoiceConverter.h"
// 全局指针
lame_t lame;

#define WAVE_UPDATE_FREQUENCY   0.05
#define DOCUMENT_PATH  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


static FUTalkManager *shared = nil;



void volumeListenerCallback (
                             void                      *inClientData,
                             AudioSessionPropertyID    inID,
                             UInt32                    inDataSize,
                             const void                *inData
                             );

@interface FUTalkManager() <AVAudioPlayerDelegate,FUAudioRecorderDelegate>{
    NSString* _voiceFilePath;
    BOOL isNeedDelete;
    
    FUAudioRecorder* _audioRecorder;
    FUMp3RecordWriter *mp3Writer;
    FUAudioMeterObserver *_meterObserver;
    BOOL isFinishedRecord;
}
@property (nonatomic, copy) NSString * voiceFilePath;
@property (nonatomic, strong) AVAudioRecorder * recorder;
@property (nonatomic, strong) FUAudioRecorder* audioRecorder;
@property (nonatomic, strong) FUAudioMeterObserver *meterObserver;

@end

@implementation FUTalkManager
@synthesize talkManagerDelegate = _talkManagerDelegate;
@synthesize voiceFilePath = _voiceFilePath;
@synthesize audioPlayer = _audioPlayer;
@synthesize audioRecorder = _audioRecorder;
@synthesize meterObserver = _meterObserver;


+ (id)sharedFUTalkManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype) init{
    self =  [super init];
    if (self) {
        isNeedDelete = false;
        _isVoiceClipBtnTouchUpOutside = false;
        isFinishedRecord = FALSE;
    }
    return self;
}


- (void)initAudioRecorderAndMp3RecordWriter{
    
    if (!self.audioRecorder) {
        
        mp3Writer = [[FUMp3RecordWriter alloc]init];
        mp3Writer.filePath = _voiceFilePath;
        mp3Writer.maxSecondCount = 300;
        mp3Writer.maxFileSize = 1024*1024*4;
        
        self.audioRecorder = [[FUAudioRecorder alloc]init];
        self.audioRecorder.fileWriterDelegate = mp3Writer;
        self.audioRecorder.delegate = self;
        
        self.meterObserver = [[FUAudioMeterObserver alloc]init];
        
        __weak typeof(self) _weakSelf = self;
        
        self.meterObserver.actionBlock = ^(NSArray *levelMeterStates,FUAudioMeterObserver *meterObserver){
            
            float volumeVaule = [FUAudioMeterObserver volumeForLevelMeterStates:levelMeterStates];
            if (_weakSelf.talkManagerDelegate && [_weakSelf.talkManagerDelegate respondsToSelector:@selector(talkManager:peakPowerForChannel:)]) {
                [_weakSelf.talkManagerDelegate talkManager:_weakSelf peakPowerForChannel:volumeVaule];
            }
            
        };
        
        self.meterObserver.errorBlock = ^(NSError *error,FUAudioMeterObserver *meterObserver){
            //TODO 出错处理暂定
            
            
        };
        
    }
}

- (void)startRecord{
//    if (![share() hasMicphone]) {
//        AlertView * alertview = [[AlertView alloc] initWithFrame:CGRectZero del:self];
//        [alertview showAlertViewWithText:@"无输入设备"];
//        return;
//    }
    _recordTime = 0;
    isFinishedRecord = FALSE;

    [self lazyButtontouchDown];
    [self prepareRecord];
    [self initAudioRecorderAndMp3RecordWriter];
    
    if (self.audioRecorder.isRecording) {
        //取消录音
        [self.audioRecorder stopRecording];
    }else{
        //开始录音
        [self.audioRecorder startRecording];
        self.meterObserver.audioQueue = [self.audioRecorder getAudioQueueRef];
    }
}

-(void)pauseRecord{
    
    [self.audioRecorder suspendRecording];
    
}

- (void)resumeRecord{
    
    if (self.audioRecorder) {
        [self.audioRecorder resumeRecording];
    }
}

- (void)stopRecord{
    
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    
    if (!isFinishedRecord) {
        if (_recordTime >= 1 && _isVoiceClipBtnTouchUpOutside) {
            [self.audioRecorder performSelector:@selector(suspendRecording) withObject:nil afterDelay:0.0];
            //TODO 提示说话时间太短
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"放弃该录音吗？" message:nil delegate:self cancelButtonTitle:@"发送" otherButtonTitles:@"放弃", nil];
            [alertView show];
            return;
        }
        else if(_recordTime>= 1 && !_isVoiceClipBtnTouchUpOutside)
        {
            [timer invalidate];timer = nil;
            [self.audioRecorder performSelector:@selector(stopRecording) withObject:nil afterDelay:0.0];
            self.meterObserver.audioQueue = nil;
        }
        else
        {
            [timer invalidate];timer = nil;
            [self.audioRecorder performSelector:@selector(stopRecording) withObject:nil afterDelay:0.0];
            self.meterObserver.audioQueue = nil;
            
            isNeedDelete = TRUE;
            if (_voiceFilePath.length > 0) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:_voiceFilePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:_voiceFilePath error:nil];
                }
            }
            
            _isVoiceClipBtnTouchUpOutside = false;
            
            if (_talkManagerDelegate && [_talkManagerDelegate respondsToSelector:@selector(talkManager:timeTransient:)]) {
                [_talkManagerDelegate talkManager:self timeTransient:_recordTime];
            }
        }
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        _isVoiceClipBtnTouchUpOutside = false;
        [self.audioRecorder performSelector:@selector(stopRecording) withObject:nil afterDelay:0.0];
    }
    else
    {
        isNeedDelete = TRUE;
        [self.audioRecorder performSelector:@selector(stopRecording) withObject:nil afterDelay:0.0];
        if (_voiceFilePath.length > 0) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:_voiceFilePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:_voiceFilePath error:nil];
            }
        }
        
        _isVoiceClipBtnTouchUpOutside = false;
    }
}

- (void)stopVoice{
    [_audioPlayer stop];
    if (_talkManagerDelegate && [_talkManagerDelegate respondsToSelector:@selector(talkManagerStopWithAudio:)]) {
        [_talkManagerDelegate talkManagerStopWithAudio:self];
    }
    _audioPlayer = nil;
}

- (void)playVoice:(NSString *)filePath{
    
    [self getAVAudioPlayerObj:filePath];
}

- (void)toPlayVoice:(NSString *)voiceOriginalPath
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [_audioPlayer setVolume:1.0];
    _audioPlayer.delegate = self;
    bool isPrepare = [_audioPlayer prepareToPlay];
    bool play = [_audioPlayer play];
    
    if (isPrepare && play) {
        if (_talkManagerDelegate && [_talkManagerDelegate respondsToSelector:@selector(talkManagerPlayWithAudio:)]) {
            [_talkManagerDelegate talkManagerPlayWithAudio:self];
        }
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString * wavPath = [DOCUMENT_PATH stringByAppendingPathComponent:@"tmpPlay.wav"];
            NSString * amrPath = [DOCUMENT_PATH stringByAppendingPathComponent:@"tmpPlay.amr"];
            
            NSData * amrData = [NSData dataWithContentsOfURL:[NSURL URLWithString:voiceOriginalPath]];
            [amrData writeToFile:amrPath atomically:YES];
            
            [VoiceConverter amrToWav:amrPath wavSavePath:wavPath];
            
            NSData * data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:wavPath]];
            _audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_audioPlayer) {
                    [self toPlayVoice:voiceOriginalPath];
                }
            });
        });
    }

}

- (void)getAVAudioPlayerObj:(NSString*) filePath{
    NSString *voiceOriginalPath = filePath;
    if (_audioPlayer == nil) {
        BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:voiceOriginalPath];;
        if (isFileExist) {
            NSURL* audioFilePath = [NSURL fileURLWithPath:voiceOriginalPath];
            
            NSError * error;
            _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFilePath error:&error];
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:voiceOriginalPath]];
                _audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_audioPlayer) {
                        [self toPlayVoice:voiceOriginalPath];
                    }
                });
            });
        }
    }

    if (_audioPlayer) {
        [self toPlayVoice:voiceOriginalPath];
    }
}


- (void)prepareRecord{
    AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume ,
                                    volumeListenerCallback,
                                    (__bridge void *)(self)
                                    
                                    );
    
    _voiceFilePath = [DOCUMENT_PATH stringByAppendingPathComponent:@"tmpRecord.amr"];
}

void volumeListenerCallback (void                      *inClientData,
                             AudioSessionPropertyID    inID,
                             UInt32                    inDataSize,
                             const void                *inData
                             )
{
    //TODO 暂且注释
    /**const float *volumePointer = inData;
     float volume = *volumePointer;
     FUTalkManager* _mTalkManager = (__bridge FUTalkManager* )inClientData;
     if (_mTalkManager && _mTalkManager.talkManagerDelegate && [_mTalkManager respondsToSelector:@selector(talkManager:volume:)]) {
     [[_mTalkManager talkManagerDelegate] talkManager:NULL volume:volume];
     }*/
}

- (void)lazyButtontouchDown
{
    if (!timer) {
        _recordTime = 0;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onScheduledTimer:) userInfo:nil repeats:YES];
        
    }
}

- (void)onScheduledTimer:(NSTimer* ) timer{
    if (_recordTime >= 300) {
        [self stopRecord];
        isFinishedRecord = TRUE;
        _recordTime = 0;
    }
    NSLog(@"========%d",_recordTime);
    _recordTime++;
}

- (void)deleteAndStopRecord{
    isNeedDelete = TRUE;
    [self stopRecord];
    if (_voiceFilePath.length > 0) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:_voiceFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_voiceFilePath error:nil];
        }
    }
    
    _isVoiceClipBtnTouchUpOutside = false;
}


#pragma mark
#pragma mark FUAudioRecorderDelegate
- (void)recordError:(NSError *)error{
    
}

- (void)audioRecorderStop:(FUAudioRecorder* ) audioRecorder{
    
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    
    if (!isNeedDelete) {
        if (_recordTime >=1) {
            if (_talkManagerDelegate && [_talkManagerDelegate respondsToSelector:@selector(talkManager:stopRecord:timeLong:)]) {

                [_talkManagerDelegate talkManager:self stopRecord:_voiceFilePath timeLong:_recordTime];
            }
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:_voiceFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_voiceFilePath error:nil];
        }
    }
    
    isNeedDelete = FALSE;
    mp3Writer = nil;
    self.audioRecorder = nil;
}

#pragma mark
#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setActive:NO error:nil];
    
    if (_talkManagerDelegate && [_talkManagerDelegate respondsToSelector:@selector(talkManager:finishedAudio:)]) {
        [_talkManagerDelegate talkManager:self finishedAudio:flag];
    }
    
    _audioPlayer = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    
}

- (void)dealloc{
    
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    
    _audioPlayer = nil;
    [self.audioRecorder stopRecording];
    self.audioRecorder = nil;
    mp3Writer = nil;
    isFinishedRecord = FALSE;
    self.voiceFilePath = nil;
    
    self.meterObserver.audioQueue = nil;
    self.meterObserver = nil;
}
@end
