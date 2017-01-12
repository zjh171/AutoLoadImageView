// ImageCache.m
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

#import "ImageCache.h"
#import "FileManager.h"
#import "UIImage+Compress.h"

#define IMAGELENGTH 102400


@interface ImageCache(){
    NSMutableDictionary *memCache;
    NSLock *lock ;

}

@end

@implementation ImageCache

static ImageCache *instance = nil;

+(ImageCache* )shareInstance{
    if (!instance) {
        @synchronized(self){
            instance = [[ImageCache alloc]init];
        }
    }
    return instance;
}

-(id)init{
    if (self = [super init]) {
        memCache = [[NSMutableDictionary alloc]initWithCapacity:100];
        lock = [[NSLock alloc]init];
    }
    return self;
}


-(void)cacheImageWith32Key:(NSString *)key{
    if (nil == key) {
        return;
    }
    
    UIImage *image = [self compressImageWithKey:key];

    if (memCache.allKeys.count > 100) {
        [memCache removeAllObjects];
    }
    
    [self cacheImage:image with32Key:key];
}

-(void)cacheImage:(UIImage *)image with32Key:(NSString *)key{
    if (nil == key) {
        return;
    }
    //compress image
    if (nil != image) {
        [memCache setObject:image forKey:key];
    }
}


-(UIImage *)loadCacheImageWith32Key:(NSString *)key{
    if (nil == key) {
        return nil;
    }
    NSString *lowPiexlFileName = [NSString stringWithFormat:@"%@_low",key];
    UIImage *lowPiexlImage = [memCache objectForKey:lowPiexlFileName] ;
    UIImage *image = nil == lowPiexlImage ? [memCache objectForKey:key] : lowPiexlImage;
    return image;
}


/***
 * compress image
 */
-(UIImage *) compressImageWithKey:(NSString *) key{
    [lock lock];
    NSData *imageData = [FileManager getFileWithName:key type:DirectoryTypeDocument];
    UIImage *image = nil;
    //compress image,perceptual
    if (imageData.length > IMAGELENGTH) {
        NSString *lowPiexlFileName = [NSString stringWithFormat:@"%@_low",key];
        BOOL exist = [FileManager isFileExists:lowPiexlFileName type:DirectoryTypeDocument];

        if (!exist) {
            image = [UIImage imageWithData:imageData];
            NSLog(@"kyson:original image size:%fk",(float)(imageData.length/1024));
            CGSize size = [UIScreen mainScreen].bounds.size;
            size.width *= 2;
            float multiple = image.size.width / size.width;
            size.height = image.size.height / multiple;
            image = [image scaledToSize:size];
            NSData *data = UIImageJPEGRepresentation(image, 0.2);
            [FileManager writeFile:lowPiexlFileName toDirectory:DirectoryTypeDocument withData:data];
            NSLog(@"kyson:compressed image size:%fk",(float)(data.length/1024));
        }else{
            image = [UIImage imageWithData:imageData];
        }
        
    }else{
        image = [UIImage imageWithData:imageData];
    }
    [lock unlock];
    return image;
}

-(void)removeCache:(NSString *)key{
    if (nil == key) {
        return;
    }
    NSString *lowPiexlFileName = [NSString stringWithFormat:@"%@_low",key];
    [memCache removeObjectForKey:lowPiexlFileName];
}


-(void)clearCache{
    [memCache removeAllObjects];
}

@end
