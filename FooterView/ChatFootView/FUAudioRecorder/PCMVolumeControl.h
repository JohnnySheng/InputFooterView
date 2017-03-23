//
//  PCMVolumeControl.h
//  Fetion
//
//    on 13-12-10.
//  Copyright (c) 2013年 xinrui.com. All rights reserved.
//

#ifndef Fetion_PCMVolumeControl_h
#define Fetion_PCMVolumeControl_h

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>

typedef u_short WORD;
typedef u_long DWORD;
typedef u_char CHAR;

typedef unsigned long UINT32 ;
typedef unsigned char BYTE;
typedef unsigned long DWORD_PTR;

#define MAKEWORD(a, b)      ((WORD)(((BYTE)(((DWORD_PTR)(a)) & 0xff)) | ((WORD)((BYTE)(((DWORD_PTR)(b)) & 0xff))) << 8))
#define LOWORD(l)           ((WORD)((DWORD_PTR)(l) & 0xffff))
#define HIWORD(l)           ((WORD)((DWORD_PTR)(l) >> 16))
#define HIBYTE(n) ((n)>>8)
#define LOBYTE(n) ((n)&0xff)

struct tagHXD_WAVFLIEHEAD
{
    CHAR RIFFNAME[4];
    DWORD nRIFFLength;
    CHAR WAVNAME[4];
    CHAR FMTNAME[4];
    DWORD nFMTLength;
    WORD nAudioFormat;
    
    WORD nChannleNumber;
    DWORD nSampleRate;
    DWORD nBytesPerSecond;
    WORD nBytesPerSample;
    WORD    nBitsPerSample;
    CHAR    DATANAME[4];
    DWORD   nDataLength;
};

typedef struct tagHXD_WAVFLIEHEAD HXD_WAVFLIEHEAD;

int pcm_volume_control(const char* foldname, const char* fnewname, double vol);

char * pcm_volume_control_m(const char *originalData,double vol,int inSampleRate, int ChannleNumber);

int pcm_volume_control_byte(const char *originalWaveData,size_t length, char *destWaveData,double vol);
#endif
