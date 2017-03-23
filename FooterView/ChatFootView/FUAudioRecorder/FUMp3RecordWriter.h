//
//  FUMp3RecordWriter.h
//    
//
//    on 14-9-11.
//  Copyright (c) 2014年 fuya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FUAudioRecorder.h"

@interface FUMp3RecordWriter : NSObject <FileWriterForFUAudioRecorder>

@property (nonatomic, copy) NSString *filePath;                /**保存文件路径*/
@property (nonatomic, assign) unsigned long maxFileSize;       /**文件最大Size*/
@property (nonatomic, assign) double maxSecondCount;           /**最大录音时长:秒数*/

@end
