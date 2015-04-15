//
//  AppDelegate.m
//  AutoLoadImageViewSample
//
//  Created by zhujinhui on 15/4/15.
//  Copyright (c) 2015年 kyson. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    self.window.rootViewController = navc;
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

@end
