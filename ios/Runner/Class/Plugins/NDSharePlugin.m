//
//  SharePlugin.m
//  Runner
//
//  Created by Gustin Lau on 2019/1/22.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "NDSharePlugin.h"
@interface NDSharePlugin()
@property(nonatomic, strong) UIViewController *viewController;
@property(nonatomic,copy) FlutterResult result;
@end

@implementation NDSharePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar; {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"com.gustinlau.nextday/share" binaryMessenger: registrar.messenger];
    NDSharePlugin *instance = [[NDSharePlugin alloc]init];
    instance.viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result; {
    self.result = result;
    if ([call.method isEqual:@"share"]) {
        NSData *arguments=((FlutterStandardTypedData*)call.arguments).data;
        UIImage *image=[UIImage imageWithData:arguments];
        if(image){
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    } else {
        result(FlutterMethodNotImplemented);
        self.result = nil;
    }
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo; {
    if (!error) {
        [self shareWithImage:image];
        self.result(@1);
    }else {
       self.result(@0);
    }
    self.result = nil;
}

- (void)shareWithImage:(UIImage*)image; {
     UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    [self.viewController presentViewController:activityViewController animated:YES completion:nil];
}

@end
