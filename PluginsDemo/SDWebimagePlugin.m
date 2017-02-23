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

//- (void)perseConfig:(AlisRequestConfig *)requestConfig
//{
//    
//
//}

//- (void)perseRequest:(AlisRequest *)request
//{
//    __weak typeof(self) weakSelf = self;
//    __weak typeof(request) weakRequest = request;
//    request.startBlock = ^(void){
//        [weakSelf startRequest:weakRequest];
//    };
//    
//    request.cancelBlock = ^(void){
//        //[weakSelf startRequest:weakRequest];
//    };
//    
//}

- (void)perseRequest:(AlisRequest *)request config:(AlisRequestConfig *)config
{

    __weak typeof(self) weakSelf = self;
    __weak typeof(request) weakRequest = request;
    request.startBlock = ^(void){
        [weakSelf startRequest:weakRequest config:config];
    };
    
    request.cancelBlock = ^(void){
        //[weakSelf startRequest:weakRequest];
    };
    
}

- (void)startRequest:(AlisRequest *)request config:(AlisRequestConfig *)config
{
    return;
    NSString *urlString = nil;//[NSMutableString string];
    if (request.server) {
        if (request.api) {
            urlString = [NSString stringWithFormat:@"%@%@",request.server,request.api];
        }
    }else{
        if (request.useGeneralServer == YES) {
            urlString = [NSString stringWithFormat:@"%@%@",config.generalServer,request.api];
        }
    }
    
    NSAssert(urlString, @"url should not nil");
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    //第三方的请求发起
    [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        //request.
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (request.finishBlock) {
            AlisResponse *response = [self perseResponse:image request:request];
            AlisError *_error = [self perseError:error];
            request.finishBlock(request,response,_error);
        }
    }];

}


- (AlisResponse *)perseResponse:(id)remoteResponse request:(AlisRequest *)request
{
    //do sth
    return nil;
}

- (AlisError *)perseError:(id)remoteError
{
    //do sth 
    return nil;


}

@end
