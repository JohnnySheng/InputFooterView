//
//  FUChatFootMenuItemManager.m
//  DemoForHR
//
//  Created by "" on 14-8-7.
//  Copyright (c) 2014年 izhixin. All rights reserved.
//

#import "FUChatFootMenuItemManager.h"



@interface FUChatFootMenuItemManager()
{
    FUChatFootMenuItem * liveMenuItem;
}

@end


@implementation FUChatFootMenuItemManager

@synthesize chatFootMenuItemArray = _chatFootMenuItemArray;
@synthesize photoMenuItemArray = _photoMenuItemArray;
- (id)init{
    self = [super init];
    if (self) {
        _chatFootMenuItemArray = [[NSMutableArray alloc] init];
        _photoMenuItemArray = [[NSMutableArray alloc] init];
        [self load];
    }
    
    return self;
}

/**
 *  装载FUChatFootMenuItem对象
 */
- (void)load{
    
    if (_chatFootMenuItemArray.count > 0) {
        [_chatFootMenuItemArray removeAllObjects];
    }
    
    if (_photoMenuItemArray.count > 0) {
        [_photoMenuItemArray removeAllObjects];
    }
    
    /**拍照菜单对象*/
    FUChatFootMenuItem* cameraMenuItem = [[FUChatFootMenuItem alloc] init];
    cameraMenuItem.menuNameColor =  [UIColor blackColor];
    cameraMenuItem.nomarlImage = CAMERA_MENU_NORMAL_IMAGE;
    cameraMenuItem.selectedImage = CAMERA_MENU_HEIGHTED_IMAGE;
    cameraMenuItem.selectedMenuItemSelector = NSSelectorFromString(CAMERA_MENU_SELECTOR_NAME);
    
    [_chatFootMenuItemArray addObject:cameraMenuItem];
    [_photoMenuItemArray addObject:cameraMenuItem];
    
    /**选择图片菜单对象*/
    FUChatFootMenuItem* picMenuItem = [[FUChatFootMenuItem alloc] init];
    picMenuItem.menuNameColor = [UIColor blackColor];
    picMenuItem.nomarlImage = PIC_MENU_NORMAL_IMAGE;
    picMenuItem.selectedImage = PIC_MENU_HEIGHTED_IMAGE;
    picMenuItem.selectedMenuItemSelector = NSSelectorFromString(PIC_MENU_SELECTOR_NAME);
    
    [_chatFootMenuItemArray addObject:picMenuItem];
    [_photoMenuItemArray addObject:picMenuItem];

}

- (void)addChatFootMenuItem:(FUChatFootMenuItem *)chatFootMenuItem{
    if (_chatFootMenuItemArray && chatFootMenuItem) {
        [_chatFootMenuItemArray addObject:chatFootMenuItem];
    }
}

- (void)dealloc{
    if (_chatFootMenuItemArray && [_chatFootMenuItemArray count] > 0) {
        [_chatFootMenuItemArray removeAllObjects];
        _chatFootMenuItemArray = nil;
    }
}

@end
