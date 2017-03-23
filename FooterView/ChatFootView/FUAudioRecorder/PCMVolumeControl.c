//
//  PCMVolumeControl.c
//  Fetion
//
//    on 13-12-10.
//  Copyright (c) 2013年 xinrui.com. All rights reserved.
//

#include <stdio.h>
#include "PCMVolumeControl.h"
#include <string.h>

void RaiseVolume(char* buf, UINT32 size,UINT32 uRepeat,double vol);
int frame_size_get(int inSampleRate, int ChannleNumber);
char* substring(char* ch,int pos,int length);


int frame_size_get(int inSampleRate, int ChannleNumber){
    int size= -1;
    switch(inSampleRate)
    {
        case 8000: {
            size= 320;
        }
            break;
        case 16000:{
            size= 640;
        }
            break;
        case 24000:  {
            size= 960;
        }
            break;
        case 32000: {
            size= 1280;
        }
            break;
        case 48000: {
            size= 1920;
        }
            break;
        case 44100: {
            size= 441*4;//为了保证8K输出有320,441->80,*4->320
        }
            break;
        case 22050: {
            size= 441*2;
        }
            break;
        case 11025: {
            size= 441;
        }
            break;
        default:
            break;
    }
    return ChannleNumber*size;
}

void RaiseVolume(char* buf, UINT32 size,UINT32 uRepeat,double vol){
    if (!size ) {
        return;
    }
    for (int i = 0; i < size;) {
//        signed long minData = -0x8000; //如果是8bit编码这里变成-0x80
//        signed long maxData = 0x7FFF;//如果是8bit编码这里变成0xFF
        signed short wData = buf[i+1];
        wData = MAKEWORD(buf[i],buf[i+1]);
        signed long dwData = wData;
        for (int j = 0; j < uRepeat; j++) {
            dwData = dwData * vol;//1.25;
            if (dwData < -0x8000) {
                dwData = -0x8000;
            }
            else if (dwData > 0x7FFF){
                dwData = 0x7FFF;
            }
        }
        wData = LOWORD(dwData);
        buf[i] = LOBYTE(wData);
        buf[i+1] = HIBYTE(wData);
        i += 2;
    }
}

int pcm_volume_control_byte(const char *originalWaveData,size_t length,
                            char *destWaveData,
                            double vol){
    HXD_WAVFLIEHEAD head;
    int frame_size= 0;
    char* frame_buffer;
    if (NULL == originalWaveData || NULL == destWaveData) {
        return -1;
    }
    if (length == 0) {
        return -1;
    }
    //取得字节Head头
    memcpy(&head, originalWaveData, sizeof(head));
    memcpy(destWaveData, originalWaveData, sizeof(head));
    length -= sizeof(head);
    char *tmpData = (char *)malloc(length);
    char *_tmpData = (char *)malloc(length);
    memset(_tmpData, 0, length);
    strcpy(_tmpData, substring((char *)originalWaveData, sizeof(head), length-sizeof(head)));
    frame_size= frame_size_get(head.nSampleRate,head.nChannleNumber);
    frame_buffer= (char*)malloc(frame_size);
//    char *result_frame_size = malloc(30000);
    size_t index = 0;
    while (frame_size <= length) {
        strcpy(tmpData, substring((char *)_tmpData, index * frame_size, frame_size));
        strncpy(frame_buffer, tmpData, frame_size);
        RaiseVolume(frame_buffer,frame_size,1,vol);
        memset(tmpData, 0, strlen(tmpData) * sizeof(char));
        index++;
        length -= frame_size;
        strcat(destWaveData + index * frame_size, frame_buffer);
        
    }
    free(frame_buffer);
    return 0;
}

//vol取0—10即可，为0时为静音，小于1声音减小，大于1声音增大，测试取大于10的数字效果不明显
int pcm_volume_control(const char* foldname, const char* fnewname, double vol){
    HXD_WAVFLIEHEAD head;
    int frame_size= 0;
    char* frame_buffer;
    FILE* fp_old= fopen(foldname,"rb+");
    FILE* fp_new= fopen(fnewname,"wb+");
    if((NULL== fp_old) || (NULL== fp_new)){
        return -1;
    }
    fread(&head,1,sizeof(head),fp_old);
    fwrite(&head,1,sizeof(head),fp_new);
    frame_size= frame_size_get( head.nSampleRate,head.nChannleNumber);
    frame_buffer= (char*)malloc(frame_size);
    char *result_frame_size = malloc(30000);
    while(frame_size== fread(frame_buffer,1,frame_size,fp_old)){
        printf("fread return is %ld",fread(frame_buffer,1,frame_size,fp_old));
        RaiseVolume(frame_buffer,frame_size,1,vol);
        strcat(result_frame_size, frame_buffer);
        fwrite(frame_buffer,1,frame_size,fp_new);
    }
    if (fp_old != NULL) {
        fclose(fp_old);
    }
    if (fp_new != NULL) {
        fclose(fp_new);
    }
    if (frame_buffer != NULL) {
        free(frame_buffer);
    }
    return 0;
}

char* substring(char* ch,int pos,int length)
{
    char* pch=ch;
    //定义一个字符指针，指向传递进来的ch地址。
    char* subch=calloc(sizeof(char),length+1);
    //通过calloc来分配一个length长度的字符数组，返回的是字符指针。
    int i;
    //只有在C99下for循环中才可以声明变量，这里写在外面，提高兼容性。
    pch=pch+pos;
    //是pch指针指向pos位置。
    for(i=0;i<length;i++)
    {
        subch[i]=*(pch++);
        //循环遍历赋值数组。
    }
    //subch[length]='\0';//加上字符串结束符。
    return subch;       //返回分配的字符数组地址。
}

char* pcm_volume_control_m(const char *originalData,double vol,int inSampleRate, int ChannleNumber){
    int frame_size= 0;
//    int dataSize = 0;
    char* frame_buffer;
    char* result_frame_buffer;
    frame_size= frame_size_get(inSampleRate,ChannleNumber);
    frame_buffer= (char*)malloc(frame_size);
    result_frame_buffer = (char *)malloc(strlen(originalData) * sizeof(char));
    char *tmpData = (char *)malloc(strlen(originalData) * sizeof(char));
    strncpy(tmpData, originalData,strlen(originalData));
    int index = 1;
    while (frame_size <= strlen(tmpData)) {
        strncpy(frame_buffer, tmpData, frame_size);
        RaiseVolume(frame_buffer,frame_size,1,vol);
        strcpy(tmpData, substring((char*)originalData, index * frame_size, frame_size));
        index++;
        strcat(result_frame_buffer, frame_buffer);
    }
    return result_frame_buffer;
}
