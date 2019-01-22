//
//  CacheManagerPlugin.m
//  Runner
//
//  Created by Gustin Lau on 2019/1/22.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "NDCacheManagerPlugin.h"
@interface NDCacheManagerPlugin()
@property(nonatomic, strong) NSArray<NSString *> *cachePaths;
@end


@implementation NDCacheManagerPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar; {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"com.gustinlau.nextday/cache_manager" binaryMessenger: registrar.messenger];
    NDCacheManagerPlugin *instance = [[NDCacheManagerPlugin alloc]init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result; {
    if ([call.method isEqual:@"cleanCache"]) {
        for (NSString *path in self.cachePaths) {
            [self clearCache:path];
        }
        result(@1);
    } else if([call.method isEqual:@"cacheSize"]){
        unsigned long long folderSize = 0;
        for (NSString *path in self.cachePaths) {
            if (path.length > 0) {
                folderSize += [self folderSizeAtPath:path];
            }
        }
        result(@(folderSize));
    } else {
         result(FlutterMethodNotImplemented);
    }
}

/**
 * 计算单个文件大小
 * @param path
 * @return
 */
- (unsigned long long)fileSizeAtPath:(NSString *)path; {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size;
    }
    return 0;
}

/**
 * 计算目录大小
 * @param path
 * @return
 */
- (unsigned long long)folderSizeAtPath:(NSString *)path; {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    unsigned long long folderSize = 0;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:absolutePath];
        }
        return folderSize;
    }
    return 0;
}

/**
 * 清理缓存文件
 * @param path
 */
- (void)clearCache:(NSString *)path; {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
}


// 缓存路径
- (NSArray<NSString *> *)cachePaths; {
    if (!_cachePaths) {
        NSString *pathOfLibrary = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
        _cachePaths = @[[pathOfLibrary stringByAppendingPathComponent:@"Caches"]];
    }
    return _cachePaths;
}

@end
