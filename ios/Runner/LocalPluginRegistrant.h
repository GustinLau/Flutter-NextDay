//
//  LocalPluginRegistrant.h
//  Runner
//
//  Created by Gustin Lau on 2019/1/17.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Flutter/Flutter.h>

@interface LocalPluginRegistrant : NSObject
+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry;
@end

