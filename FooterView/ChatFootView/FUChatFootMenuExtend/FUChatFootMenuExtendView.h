//
//  FUChatFootMenuExtendView.h
//  DemoForHR
//
//  Created by "" on 14-8-7.
//  Copyright (c) 2014年 izhixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FUChatFootMenuItem.h"

/**
 *  随访聊天界面底部菜单扩展视图
 */
@interface FUChatFootMenuExtendView : UIView{
    NSMutableArray* _menuItems;
}
@property (strong,nonatomic) NSMutableArray* menuItems;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id) delegate;

- (instancetype)initWithDelegate:(id) delegate;

/**
 *  显示扩展菜单
 *
 *  @param animation 是否动画
 */
- (void)showChatFootMenuExtentViewWithAnimation:(BOOL) animation;

/**
 *  隐藏扩展菜单
 *
 *  @param animation 是否动画
 */
- (void)hideChatFootMenuExtentViewWithAnimation:(BOOL) animation;

@end

@protocol FUChatFootMenuExtendViewDelegate <NSObject>

@optional
/**
 *  图片菜单按钮回调事件
 *
 *  @param chatFootMenuExtendView FUChatFootMenuExtendView 目标对象
 *  @param chatFootMenuItem       FUChatFootMenuItem 实体对象
 */
- (void)chatFootMenuExtendView:(FUChatFootMenuExtendView* ) chatFootMenuExtendView
            didSelectedPicMenuItem:(FUChatFootMenuItem* ) chatFootMenuItem;

/**
 *  拍照菜单按钮回调事件
 *
 *  @param chatFootMenuExtendView FUChatFootMenuExtendView 目标对象
 *  @param chatFootMenuItem       FUChatFootMenuItem 实体对象
 */
- (void)chatFootMenuExtendView:(FUChatFootMenuExtendView *)chatFootMenuExtendView
      didSelectedCameraMenuItem:(FUChatFootMenuItem *)chatFootMenuItem;

/**
 *  快捷回复菜单按钮回调事件
 *
 *  @param chatFootMenuExtendView FUChatFootMenuExtendView 目标对象
 *  @param chatFootMenuItem       FUChatFootMenuItem 实体对象
 */
- (void)chatFootMenuExtendView:(FUChatFootMenuExtendView *)chatFootMenuExtendView
      didSelectedShortcutBackMenuItem:(FUChatFootMenuItem *)chatFootMenuItem;

/**
 *  随访方案菜单按钮回调事件
 *
 *  @param chatFootMenuExtendView FUChatFootMenuExtendView 目标对象
 *  @param chatFootMenuItem       FUChatFootMenuItem 实体对象
 */
- (void)chatFootMenuExtendView:(FUChatFootMenuExtendView *)chatFootMenuExtendView didSelectedSuifangSchemeMenuItem:(FUChatFootMenuItem *)chatFootMenuItem;

@end
