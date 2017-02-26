//
//  SDWebimagePlugin.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  关键是保存了 AlisRequest 几个block，

#import "SDWebimagePlugin.h"
#import "SDWebImageManager.h"
#import "AlisRequest.h"
#import "AlisRequestConfig.h"

@implementation SDWebimagePlugin

- (void)perseRequest:(AlisRequest *)request config:(AlisRequestConfig *)config
{
//    __weak typeof(self) weakSelf = self;
//    __weak typeof(request) weakRequest = request;
//    request.startBlock = ^(void){
//        [weakSelf startRequest:weakRequest config:config];
//    };
//    
//    request.cancelBlock = ^(void){
//        [weakSelf cancelRequest:weakRequest];
//    };
    [self startRequest:request config:config];
    
}

- (void)startRequest:(AlisRequest *)request config:(AlisRequestConfig *)config
{
//    return;
//    NSString *urlString = nil;//[NSMutableString string];
//    if (request.server) {
//        if (request.api) {
//            urlString = [NSString stringWithFormat:@"%@%@",request.server,request.api];
//        }
//    }else{
//        if (request.useGeneralServer == YES) {
//            urlString = [NSString stringWithFormat:@"%@%@",config.generalServer,request.api];
//        }
//    }
//    
//    NSAssert(urlString, @"url should not nil");
//    
//    NSURL *url = [NSURL URLWithString:urlString];
    
    //第三方的请求发起
    request.bindRequest = [[SDWebImageManager sharedManager] downloadImageWithURL:request.url options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (request.progressBlock) {
            request.progressBlock(receivedSize,expectedSize);
        }

    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (request.finishBlock) {
            AlisResponse *response = [self perseResponse:image request:request];
            AlisError *_error = [self perseError:error];
            request.finishBlock(request,response,_error);
        }
    }];

}

- (AlisResponse *)perseResponse:(id)rawResponse request:(AlisRequest *)request
{
    if ( !rawResponse || ![rawResponse isKindOfClass:[UIImage class]]) {
        return nil;
    }
    NSDictionary *data = @{@"image":rawResponse};
    AlisResponse *response = [[AlisResponse alloc]initWithInfo:data];
    return response;
}

- (AlisError *)perseError:(id)rawError
{
    if (!rawError || ![rawError isKindOfClass:[NSError class]]) {
        return nil;
    }
    
    AlisError *_error = [[AlisError alloc]init];
    _error.code = ((NSError *)rawError).code;
    _error.name = ((NSError *)rawError).domain;
    _error.userInfo = ((NSError *)rawError).userInfo;
    return _error;
}

@end
