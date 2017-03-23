//
//  DetailViewController.h
//  FooterView
//
//  Created by Yuangang Sheng on 2017/3/23.
//  Copyright © 2017年 Johnny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

