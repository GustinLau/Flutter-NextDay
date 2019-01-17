//
//  ImageSaverPlugin.m
//  Runner
//
//  Created by Gustin Lau on 2019/1/17.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "ImageSaverPlugin.h"
@interface ImageSaverPlugin()
@property(nonatomic,copy) FlutterResult result;
@end

@implementation ImageSaverPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar; {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"com.gustinlau.nextday/image_saver" binaryMessenger: registrar.messenger];
    ImageSaverPlugin *instance = [[ImageSaverPlugin alloc]init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;{
    self.result = result;
    if([call.method isEqual:@"saveImageToAlbum"]){
        NSData* arguments=((FlutterStandardTypedData*)call.arguments).data;
        UIImage*image=[UIImage imageWithData:arguments];
        if(image){
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }else{
        result(FlutterMethodNotImplemented);
        self.result=nil;
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;{
    if(self.result){
        self.result(@(!error));
        self.result=nil;
    }
}

@end
