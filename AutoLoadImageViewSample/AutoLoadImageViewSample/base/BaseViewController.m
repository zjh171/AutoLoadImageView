//
//  BaseViewController.m
//  AutoLoadImageViewSample
//
//  Created by zhujinhui on 15/4/15.
//  Copyright (c) 2015年 kyson. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)dealloc{
    NSLog(@"%@-> dealloc",self);
}
@end
