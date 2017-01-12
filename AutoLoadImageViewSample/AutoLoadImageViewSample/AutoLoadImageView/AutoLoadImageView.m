// AutoLoadImageView.m
// Copyright (c) 2014–2017 Kyson ( http://kyson.cn )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
