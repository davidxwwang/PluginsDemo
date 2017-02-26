//
//  AFNetworkingPlugin.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/24.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AFNetworkingPlugin.h"
#import "AFNetworking.h"
#import "AlisRequest.h"
#import "AlisRequestConfig.h"

@implementation AFNetworkingPlugin

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
    AFHTTPSessionManager  *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    //request
    sessionManager.requestSerializer.timeoutInterval = request.timeoutInterval;
    sessionManager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
  //  sessionManager.requestSerializer.networkServiceType = urlRequest.networkServiceType;
  //  sessionManager.requestSerializer.cachePolicy = urlRequest.cachePolicy;
    NSDictionary *headerInfo = request.header;
    if ([headerInfo count] > 0) {
        for (NSString *key in [headerInfo allKeys]) {
            NSString *value = [headerInfo objectForKey:key];
            if (value && [value isKindOfClass:[NSString class]]) {
                [sessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
            }
        }
    }
    
    NSError *error = nil;
    NSMutableURLRequest *__request = [sessionManager.requestSerializer requestWithMethod:@"GET" URLString:request.url parameters:request.parameters error:&error];
    if (error ) {
        if (request.finishBlock) {
         //   AlisResponse *response = [self perseResponse:image request:request];
            AlisError *_error = [self perseError:error];
            request.finishBlock(request,nil,_error);
        }
    }
    __request.timeoutInterval = request.timeoutInterval;
//    __request.networkServiceType = urlRequest.networkServiceType;
//    __request.cachePolicy = urlRequest.cachePolicy;
    __request.allHTTPHeaderFields = request.header;
    //response
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/xml", @"text/html", @"text/plain",nil];
    [(AFJSONResponseSerializer *)sessionManager.responseSerializer setRemovesKeysWithNullValues:YES];
    //task
    NSURLSessionTask *task = [sessionManager dataTaskWithRequest:__request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if (request.finishBlock) {
                    AlisResponse *response = [self perseResponse:responseObject request:request];
                    AlisError *_error = [self perseError:error];
                    request.finishBlock(request,response,_error);
                }    }];
    
    NSURLSessionTask *task2 = [sessionManager dataTaskWithRequest:__request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%@ down load %lld",task2,downloadProgress.completedUnitCount/downloadProgress.totalUnitCount    );
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
         NSLog(@"finished"  );
        if (request.finishBlock) {
            AlisResponse *response = [self perseResponse:responseObject request:request];
            AlisError *_error = [self perseError:error];
            request.finishBlock(request,response,_error);
        }
    
    }];


    request.bindRequest = task2;
    [task2 resume];

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



