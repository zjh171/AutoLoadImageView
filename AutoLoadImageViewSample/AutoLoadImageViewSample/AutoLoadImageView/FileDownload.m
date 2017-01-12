// FileDownload.m
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



#import "FileDownload.h"
#import "FileManager.h"
#import "UIImage+Compress.h"
#import "NSString+Util.h"

#define IMAGELENGTH 204800

#define ERRORSIZE 18

static NSString *picSizeError = @"picture size error";

@interface FileDownload ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>{
    NSURLConnection *connection;
    long long receiveLength;
    long long contentLength;
    NSMutableData *receiveData;
    //
    NSInvocationOperation *filedownloadImpl;
}

@property (nonatomic, assign) BOOL isFinished;


@end

static NSOperationQueue *filedownloadPool = nil;

@implementation FileDownload

-(id) init{
    if (self = [super init]) {
        if (nil == filedownloadPool) {
            filedownloadPool = [[NSOperationQueue alloc]init];
        }
        [filedownloadPool setMaxConcurrentOperationCount:5];
    }
    return self;
}

- (id)initWithFileUrl:(NSString *)fileUrl{
    if (self = [self init]) {
        self.fileUrl = fileUrl;
    }
    return self;
}

-(void)startDownload{
    filedownloadImpl = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(main) object:nil];
    [filedownloadPool addOperation:filedownloadImpl];
}


-(void)main{
    NSURL *fileUrl = [NSURL URLWithString:_fileUrl];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:fileUrl];
    connection =[[NSURLConnection alloc] initWithRequest:request
                                                     delegate:self
                                             startImmediately:YES];
//    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    if (connection) {
        receiveData = [NSMutableData data];
    }

    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    } while (!self.isFinished);
    
    [connection start];
}


#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    self.isFinished = YES;

}

-(void)setFinishedConnect{
    self.isFinished = YES;
}

/**
 */
#pragma mark - NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    contentLength = [response expectedContentLength];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    receiveLength += [data length];
    [receiveData appendData:data];
    if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(fileDownload:downloadPrgoress:)]) {
        float percent = receiveLength/contentLength;
        [self.mDelegate fileDownload:self downloadPrgoress:percent ];
    }
    if (contentLength == receiveLength) {
        /**
         * Check if has error,error size is 18,as known, is "picture size error".
         * if size is not 18, it must have no error,but if it is 18 ,perhaps it has errors
         * it also has no errors,it all depends on the data.
         */
        if (contentLength != ERRORSIZE) {
            [self finishDownload];
        }else{
            NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            if ([string isEqualToString:picSizeError]) {
                if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(fileDownloadError:error:)]) {
                    [self.mDelegate fileDownloadError:self error:picSizeError];
                    // set down load finish
                }
            }else{
                [self finishDownload];
            }
        }
        self.isFinished = YES;
    }
}

-(void)finishDownload{
    if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(fileDownloadDidFinish:data:)]) {
        //save
        [FileManager writeFile:[self.fileUrl md5] toDirectory:DirectoryTypeDocument withData:receiveData];
        [self.mDelegate fileDownloadDidFinish:self data:receiveData];
        // set down load finish
    }
}


-(void)cancelDownload{
    [filedownloadImpl cancel];
    self.isFinished = YES;
}

-(void)dealloc{
    self.mDelegate = nil;
}

@end
