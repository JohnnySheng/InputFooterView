//
//  FUGridMenuButton.h
//  DemoForHR
//
//  Created by "" on 14-8-7.
//  Copyright (c) 2014年 izhixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FUChatFootMenuItem.h"

@interface FUChatFootGridMenuButton : UIView{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UIButton *_button;
}
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIButton *button;

- (instancetype) initWithFrame:(CGRect)frame
              chatFootMenuItem:(FUChatFootMenuItem* ) chatFootMenuItem
                      delegate:(id) delegate;

@end
