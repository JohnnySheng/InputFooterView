//
//  FUChatFootMenuExtendView.m
//  DemoForHR
//
//  Created by "" on 14-8-7.
//  Copyright (c) 2014年 izhixin. All rights reserved.
//

#import "FUChatFootMenuExtendView.h"
#import "FUChatFootGridMenuButton.h"
#import "FUChatFootMenuItem.h"

#define SCROLLVIEW_MENUITEM_ROWS 1
#define SCROLLVIEW_MENUITEM_COLS 4

#define MENU_ITEM_WIDTH 50
#define MENU_ITEM_HEIGHT 67
#define MENU_ITEM_TOP 10
#define MENU_ITEM_BOTTOM 5
#define MENU_ITEM_LEFT [self getGridButtonSide]
#define MENU_ITEM_RIGHT [self getGridButtonSide]
#define MENU_ITEM_SIDE_MIN 5

@interface FUChatFootMenuExtendView() <UIScrollViewDelegate> {
    
    UIScrollView* _footMenuScrollView;
    NSUInteger _pageCount;
    
}
@property (nonatomic, weak) id menuItemDelegate;
@property (nonatomic, strong) UIScrollView* footMenuScrollView;
@property (nonatomic, assign) NSUInteger pageCount;
@end

@implementation FUChatFootMenuExtendView
@synthesize menuItemDelegate = _menuItemDelegate;
@synthesize menuItems = _menuItems;
@synthesize footMenuScrollView = _footMenuScrollView;
@synthesize pageCount = _pageCount;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame delegate:nil];
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate{
    self = [super initWithFrame:frame];
    if (self) {
        _menuItemDelegate = delegate;
    }
    
    return self;
}

- (instancetype)initWithDelegate:(id)delegate{
    return [self initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [self scrollViewHeight]) delegate:delegate];
}

- (void)setMenuItems:(NSMutableArray *)menuItems{
    _menuItems = [menuItems copy];
    [self reset];
}

- (void)reset{
    
    NSArray* subMenuItems = [_footMenuScrollView subviews];
    if ([subMenuItems count] > 0) {
        for (int i = 0; i < [subMenuItems count]; i++) {
            UIView* subView = [subMenuItems objectAtIndex:i];
            [subView removeFromSuperview];
        }
    }
    
    [self update];
}

- (void)update{
    
    if (!_footMenuScrollView) {
        CGRect selfOriginFrame = self.frame;
        selfOriginFrame.size.height = [self scrollViewHeight];
        self.frame = selfOriginFrame;
        
        UIImage * img = [UIImage imageNamed:@"FUFootResource.bundle/tianjia_gengduo"] ;
        UIImageView * bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        bgView.userInteractionEnabled = YES;
        bgView.image = [img stretchableImageWithLeftCapWidth:10 topCapHeight:30];
        [self addSubview:bgView];
        
        _footMenuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _footMenuScrollView.userInteractionEnabled = YES;
        _footMenuScrollView.showsVerticalScrollIndicator = FALSE;
        _footMenuScrollView.showsHorizontalScrollIndicator = FALSE;
        _footMenuScrollView.contentInset = UIEdgeInsetsZero;
        _footMenuScrollView.pagingEnabled = NO;
        _footMenuScrollView.delegate = self;
        _footMenuScrollView.contentOffset =  CGPointZero;
        [self addSubview:_footMenuScrollView];
        
        CGRect selfFrame = self.frame;
        selfFrame.size.height = _footMenuScrollView.frame.size.height;
        selfFrame.size.width = _footMenuScrollView.frame.size.width;
        self.frame = selfFrame;
    }
    
    _pageCount = 1;
    
    [self fillScrollView];
}

/**
 *  计算ScrollView高度
 *
 *  @return  N/A
 */
- (CGFloat) scrollViewHeight{
    CGFloat oneRowHeight =  MENU_ITEM_TOP + MENU_ITEM_HEIGHT + MENU_ITEM_BOTTOM;
    NSInteger rowCount = _menuItems.count%SCROLLVIEW_MENUITEM_COLS!=0?(_menuItems.count/SCROLLVIEW_MENUITEM_COLS+1):(_menuItems.count/SCROLLVIEW_MENUITEM_COLS);
    return ceilf(oneRowHeight * rowCount);
}

- (NSInteger)getColumns{
    CGFloat scrollViewWidth = CGRectGetWidth(_footMenuScrollView.frame);
    CGFloat gridMenuButtonWidth = MENU_ITEM_LEFT + MENU_ITEM_WIDTH + MENU_ITEM_RIGHT;
    return floorf(scrollViewWidth / gridMenuButtonWidth);
}


- (CGFloat)getGridButtonSide{
    
    CGFloat width = CGRectGetWidth(_footMenuScrollView.frame);
    CGFloat sideWidth = width - SCROLLVIEW_MENUITEM_COLS * MENU_ITEM_WIDTH;
    return sideWidth/(SCROLLVIEW_MENUITEM_COLS + 1) < MENU_ITEM_SIDE_MIN ? MENU_ITEM_SIDE_MIN : sideWidth/(SCROLLVIEW_MENUITEM_COLS + 1);
}


- (void)fillScrollView{
    FUChatFootMenuItem* chatFootMenuItem = nil;
    FUChatFootGridMenuButton* gridMenuButton = nil;
    CGFloat x = 0;
    CGFloat y = 0;
    
    int count = 0, page = 0, row = 0, column = 0;
    for (page = 0; page < _pageCount; page++) {
        y = MENU_ITEM_TOP;
        
        NSInteger rowCount = _menuItems.count%SCROLLVIEW_MENUITEM_COLS!=0?(_menuItems.count/SCROLLVIEW_MENUITEM_COLS+1):(_menuItems.count/SCROLLVIEW_MENUITEM_COLS);
        for (row = 0; row < rowCount; row++) {
            for (column = 0; column < SCROLLVIEW_MENUITEM_COLS && count < [_menuItems count]; column++) {
                if (column == 0) {
                    x = MENU_ITEM_LEFT;
                }
                chatFootMenuItem = [_menuItems objectAtIndex:count];
                count++;
                
                gridMenuButton = [[FUChatFootGridMenuButton alloc] initWithFrame:
                                  CGRectMake(x, y, MENU_ITEM_WIDTH, MENU_ITEM_HEIGHT)
                                                                chatFootMenuItem:chatFootMenuItem
                                                                        delegate:_menuItemDelegate];
                [_footMenuScrollView addSubview:gridMenuButton];
                if (column == SCROLLVIEW_MENUITEM_COLS - 1) {
                    x += (MENU_ITEM_WIDTH + MENU_ITEM_RIGHT);
                }else{
                    x += (MENU_ITEM_WIDTH + MENU_ITEM_LEFT);
                }
            }
            y += (MENU_ITEM_HEIGHT + MENU_ITEM_TOP * (row + 1) + MENU_ITEM_BOTTOM);
        }
    }
}

- (void)showChatFootMenuExtentViewWithAnimation:(BOOL)animation{
    
}

- (void)hideChatFootMenuExtentViewWithAnimation:(BOOL)animation{
    
}

@end
