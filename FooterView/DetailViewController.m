//
//  DetailViewController.m
//  FooterView
//
//  Created by Yuangang Sheng on 2017/3/23.
//  Copyright © 2017年 Johnny. All rights reserved.
//

#import "DetailViewController.h"
#import "CommentFooterView.h"

@interface DetailViewController ()<CommentFooterDelegate>
@property (nonatomic, strong)CommentFooterView *footer;

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    _footer = [[CommentFooterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-55, self.view.frame.size.width, 55)];
    _footer.delegate = self;
    _footer.notOnlyText = YES;
    [_footer reloadView];
    [self.view addSubview:_footer];
    [self.view bringSubviewToFront:_footer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Managing the detail item

- (void)setDetailItem:(NSDate *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}


#pragma mark -
- (UIView *)footerSuperView{
    return self.view;
}

- (void)footerViewChangedOriginY:(CGFloat)height{
    
}

- (void)senderText:(NSString *)text{
    
}

- (void)startVoice{
    
}

- (void)senderVoice:(NSString *)voicePath timeLong:(long)timeLong{
    
}

- (void)localPhotoAction{
    
}
- (void)takePhotoAction{
    
}

- (BOOL)beginClick{
    return YES;
}

- (void)closeView{
    
}

@end
