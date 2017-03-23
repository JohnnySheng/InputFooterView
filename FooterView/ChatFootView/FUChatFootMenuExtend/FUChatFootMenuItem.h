//
//  FUChatFootMenuItem.h
//  DemoForHR
//
//  Created by "" on 14-8-7.
//  Copyright (c) 2014年 izhixin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  随访聊天界面底部扩展菜单单一对象
 */
@interface FUChatFootMenuItem : NSObject

@property (strong, nonatomic) NSString* menuName;  /**菜单名称*/
@property (strong, nonatomic) NSString*  nomarlImage;  /**默认图片*/
@property (strong, nonatomic) NSString*  selectedImage;  /**选中后图片*/
@property (strong, nonatomic) UIFont*   menuNameFont;  /**菜单名称字体*/
@property (strong, nonatomic) UIColor*  menuNameColor;  /**菜单名称颜色*/
@property (assign, nonatomic) BOOL enable; /**是否可用*/

@property (assign, nonatomic)  SEL selectedMenuItemSelector;  /**单击事件*/

@end
