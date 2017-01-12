// FileManager.m
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

#import "FileManager.h"

@implementation FileManager



+(NSString *)documentDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
//    NSString *database_path = [documents stringByAppendingPathComponent:DBNAME];
    return documents;
}


+(NSString *)homeDir{
    NSString *homeDir = NSHomeDirectory();
    return homeDir;
}

+(NSString *)resourceWithFileName:(NSString *)name
                             type:(NSString *)type{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    return imagePath;

}

+(NSString *)generateFilePath:(NSString *) fileName toDirectory:(DirectoryType) type{
    NSString *filePath = nil;
    switch (type) {
        case DirectoryTypeDocument:{
            NSString *documentDir = [FileManager documentDir];
            filePath = [documentDir stringByAppendingPathComponent:fileName];
        }
            break;
            
        default:
            break;
    }
    return filePath;
}


+(BOOL)writeFile:(NSString *)fileName toDirectory:(DirectoryType) type withData:(NSData *)data{
    BOOL result = NO;
    NSString *path = [FileManager generateFilePath:fileName toDirectory:type];
    if (path) {
        NSError *error = nil;
        result = [data writeToFile:path options:NSDataWritingWithoutOverwriting error:&error];
        if (NO == result) {
            NSLog(@"write failed!,error:%@",error);
        }
    }
    
    return result;
}

+(BOOL)isFileExists:(NSString *)fileName type:(DirectoryType) type{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [FileManager generateFilePath:fileName toDirectory:type];
    return [manager fileExistsAtPath:path];
}


+(NSData *)getFileWithName:(NSString *)fileName type:(DirectoryType )type{
    NSString *path = [FileManager generateFilePath:fileName toDirectory:type];
    NSData* fileData = [NSData dataWithContentsOfFile:path];
    return fileData;

}

+(BOOL)removeAllFileAtDirectory:(DirectoryType) type{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *documentDir = [FileManager documentDir];
    
    NSArray *contents = [manager contentsOfDirectoryAtPath:documentDir error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    BOOL hasError = NO;
    int errorCount = 0;
    while ((filename = [e nextObject])) {
        NSError *error = nil;
        [manager removeItemAtPath:[documentDir stringByAppendingPathComponent:filename] error:&error];
        if (error) {
            hasError = YES;
            ++errorCount;
        }
    }
    if (errorCount < 5) {
        hasError = NO;
    }
    return !hasError;
}

//get directionary size
+ (float ) folderSizeAtDirectionary:(DirectoryType) type{
    NSString *documentDir = [FileManager documentDir];

    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:documentDir]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:documentDir] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [documentDir stringByAppendingPathComponent:fileName];
//        if ([fileAbsolutePath hasSuffix:@"_low"]) {
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
//        }
    }
    return folderSize/(1024.0*1024.0);
}

//单个文件的大小
+ (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}


@end
