// ImageDownloader.m
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

#import "ImageDownloader.h"
#import "NSString+Util.h"
#import "FileDownload.h"
#import "ImageCache.h"
#import "FileManager.h"

#import "UIImage+Compress.h"
#import "FileDownload.h"

#define IMAGELENGTH 204800

@interface ImageDownloader()<FileDownloadDelegate>{
    ImageCache *imageCache;
    FileDownload *fileDownload;
}

@end

@implementation ImageDownloader

-(id)init{
    if (self = [super init]) {
        @synchronized(self){
            imageCache = [ImageCache shareInstance];
        }
    }
    return self;
}


-(void)downloadImageWithUrl:(NSString *)imgUrl{
    NSString *md5 = [imgUrl md5];
    UIImage *cachedImage = [imageCache loadCacheImageWith32Key:md5];
    
    if (0x00 == cachedImage) {
        //get file at sandbox
        BOOL exist = [FileManager isFileExists:md5 type:DirectoryTypeDocument];
        if (exist) {
            [imageCache cacheImageWith32Key:md5];
            cachedImage = [imageCache loadCacheImageWith32Key:md5];
            
            //callback
            if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(imageDownloader:downloadFinishedWithImage:)]) {
                [self.mDelegate imageDownloader:self downloadFinishedWithImage:cachedImage];
            }
            
        }else{
            //start down load
            fileDownload = [[FileDownload alloc]initWithFileUrl:imgUrl];
            fileDownload.mDelegate = self;
            [fileDownload startDownload];
        }
        
    }else{
        //callback
        if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(imageDownloader:downloadFinishedWithImage:)]) {
            [self.mDelegate imageDownloader:self downloadFinishedWithImage:cachedImage];
        }
        
    }
    
}

#pragma mark - FileDownloadDelegate
-(void)fileDownloadDidFinish:(FileDownload *)filedownload data:(NSData *)data{
    NSString *md5 = [filedownload.fileUrl md5];
    [imageCache cacheImageWith32Key:md5];
    UIImage *cachedImage = [imageCache loadCacheImageWith32Key:md5];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        //call back
        if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(imageDownloader:downloadFinishedWithImage:)]) {
            [self.mDelegate imageDownloader:self downloadFinishedWithImage:cachedImage];
        }
    });
}

-(void)fileDownloadError:(FileDownload *)filedownload error:(NSString *)error{
    dispatch_sync(dispatch_get_main_queue(), ^{
        //call back
        if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(imageDownloader:downloadErrorWithError:)]) {
            [self.mDelegate imageDownloader:self downloadErrorWithError:error];
        }
    });
}


-(void)cancelDownload{
    [fileDownload cancelDownload];
}

- (void)dealloc
{
    self.mDelegate = nil;
    [self cancelDownload];
    fileDownload.mDelegate = nil;
}



@end
