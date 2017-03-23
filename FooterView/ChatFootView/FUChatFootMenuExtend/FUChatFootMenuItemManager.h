//
//  FUChatFootMenuItemManager.h
//  DemoForHR
//
//  Created by "" on 14-8-7.
//  Copyright (c) 2014年 izhixin. All rights reserved.
//
/**图片按钮相关参数*/
#define CAMERA_MENU_NAME @"拍照"
#define CAMERA_MENU_NORMAL_IMAGE @"FUFootResource.bundle/footer_camera_Normal"
#define CAMERA_MENU_HEIGHTED_IMAGE @"FUFootResource.bundle/footer_camera_Press"
#define CAMERA_MENU_SELECTOR_NAME @"chatFootMenuExtendView:didSelectedCameraMenuItem:"

#define PIC_MENU_NAME @"选择图片"
#define PIC_MENU_NORMAL_IMAGE @"FUFootResource.bundle/xuanzetupian_Normal"
#define PIC_MENU_HEIGHTED_IMAGE @"FUFootResource.bundle/xuanzetupian_Press"
#define PIC_MENU_SELECTOR_NAME @"chatFootMenuExtendView:didSelectedPicMenuItem:"

#define LIVE_MENU_NAME @"直播课件"
#define LIVE_MENU_NORMAL_IMAGE @"FUFootResource.bundle/Live_courseware_Normal"
#define LIVE_MENU_HEIGHTED_IMAGE @"FUFootResource.bundle/Live_courseware_Press"
#define LIVE_MENU_SELECTOR_NAME @"chatFootMenuExtendView:didSelectedLiveMenuItem:"
#import <Foundation/Foundation.h>
#import "FUChatFootMenuItem.h"

/**
 *  随访聊天界面底部扩展菜单对象管理类
 */
@interface FUChatFootMenuItemManager : NSObject{
    NSMutableArray* _chatFootMenuItemArray;
}

@property (strong,nonatomic) NSMutableArray* photoMenuItemArray;
@property (strong,nonatomic) NSMutableArray* chatFootMenuItemArray;

/**
 *  <#Description#>
 *
 *  @param chatFootMenuItem <#chatFootMenuItem description#>
 */
- (void)addChatFootMenuItem:(FUChatFootMenuItem* ) chatFootMenuItem;

@end
