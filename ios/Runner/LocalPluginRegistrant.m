//
//  LocalPluginRegistrant.m
//  Runner
//
//  Created by Gustin Lau on 2019/1/17.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "LocalPluginRegistrant.h"
#import "ImageSaverPlugin.h"

@implementation LocalPluginRegistrant
+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
    [ImageSaverPlugin registerWithRegistrar:[registry registrarForPlugin:@"ImageSaverPlugin"]];
}
@end
