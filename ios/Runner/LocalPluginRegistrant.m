//
//  LocalPluginRegistrant.m
//  Runner
//
//  Created by Gustin Lau on 2019/1/17.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "LocalPluginRegistrant.h"
#import "NDCacheManagerPlugin.h"
#import "NDSharePlugin.h"

@implementation LocalPluginRegistrant
+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
    [NDCacheManagerPlugin registerWithRegistrar:[registry registrarForPlugin:@"NDCacheManagerPlugin"]];
    [NDSharePlugin registerWithRegistrar:[registry registrarForPlugin:@"NDSharePlugin"]];
}
@end
