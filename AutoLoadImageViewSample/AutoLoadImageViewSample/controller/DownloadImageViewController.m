//
//  DownloadImageViewController.m
//  AutoLoadImageViewSample
//
//  Created by zhujinhui on 15/4/15.
//  Copyright (c) 2015年 kyson. All rights reserved.
//

#import "DownloadImageViewController.h"
#import "AutoLoadImageView.h"

@interface DownloadImageViewController (){
    __weak IBOutlet AutoLoadImageView *mImageView;
}

@end

@implementation DownloadImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (0 == _rowIndex) {
        [mImageView loadImage:@"https://www.baidu.com/img/bdlogo.png"];
    }else if (1 == _rowIndex){
        [mImageView loadImage:@"http://www.siweiw.com/Upload/sy/2013616/20136161824820.jpg"];
    }
    
    
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
