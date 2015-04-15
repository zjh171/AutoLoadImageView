//
//  HomeViewController.m
//  AutoLoadImageViewSample
//
//  Created by zhujinhui on 15/4/15.
//  Copyright (c) 2015年 kyson. All rights reserved.
//

#import "HomeViewController.h"
#import "DownloadImageViewController.h"

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>{
    __weak IBOutlet UITableView *mTableView;
    NSArray *cellData;
}

@end

//static NSString *tableViewCell;

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    mTableView.dataSource = self;
    mTableView.delegate = self;
    
    cellData = [[NSArray alloc] initWithObjects:@"download small image",@"download big image with compress", nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return cellData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellTag = @"cellTag";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTag];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellTag];
    }
    cell.textLabel.text = [cellData objectAtIndex:indexPath.row];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DownloadImageViewController *downloadImageViewController = [[DownloadImageViewController alloc] init];
    downloadImageViewController.rowIndex = indexPath.row;
    [self.navigationController pushViewController:downloadImageViewController animated:YES];
}



@end
