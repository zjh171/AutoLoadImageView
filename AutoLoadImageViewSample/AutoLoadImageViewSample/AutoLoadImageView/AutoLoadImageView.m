//
//  AutoLoadImageView.m
//  Pitch
//
//  Created by zhujinhui on 14-9-29.
//  Copyright (c) 2014年 zhujinhui. All rights reserved.
//

#import "AutoLoadImageView.h"
#import "ImageDownloader.h"

@interface AutoLoadImageView ()<ImageDownloaderDelegate>{
    ImageDownloader *imageDownloader;
}

@end

@implementation AutoLoadImageView

-(void)loadImage:(NSString *)imageUrl{
    self.hasImageFetchFinished = NO;
    imageDownloader = [[ImageDownloader alloc]init];
    imageDownloader.mDelegate = self;
    self.image = nil;
    
    [imageDownloader downloadImageWithUrl:imageUrl];
}

-(void)imageDownloader:(ImageDownloader *)downloader downloadFinishedWithImage:(UIImage *)img{
    self.image = img;
    self.hasImageFetchFinished = YES;
}

-(void)imageDownloader:(ImageDownloader *)downloader downloadErrorWithError:(NSString *)error{
    self.image = nil;
    self.hasImageFetchFinished = YES;
}



-(void)dealloc{
    [imageDownloader cancelDownload];
    imageDownloader.mDelegate = nil;
    imageDownloader = nil;
}


@end
