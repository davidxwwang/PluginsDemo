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
    //上传
    if (request.requestType == AlisRequestUpload) {
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

        __block NSError *serializationError = nil;
        NSMutableURLRequest *urlRequest = [sessionManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:request.url parameters:request.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [request.uploadFormDatas enumerateObjectsUsingBlock:^(AlisUpLoadFormData *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.fileData) {
                    [formData appendPartWithFormData:obj.fileData name:obj.name];
                }else if (obj.fileURL)
                {
                    NSError *fileError = nil;
                    [formData appendPartWithFileURL:obj.fileURL name:obj.fileName error:&fileError];
                    
                    if (fileError) {
                        serializationError = fileError;
                        *stop = YES;
                    }
                }                
            }];
            
        } error:&serializationError];
        
//        if (serializationError) {
//            if (completionHandler) {
//                dispatch_async(xm_request_completion_callback_queue(), ^{
//                    completionHandler(nil, serializationError);
//                });
//            }
//            return;
//        }
//        
//        [self xm_processURLRequest:urlRequest byXMRequest:request];
        
//        NSURLSessionUploadTask *uploadTask = nil;
//        __weak __typeof(self)weakSelf = self;
//        uploadTask = [sessionManager
//                      uploadTaskWithStreamedRequest:urlRequest
//                                            progress:request.progressBlock
//                                   completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                    __strong __typeof(weakSelf)strongSelf = weakSelf;
//        
//                                       [strongSelf xm_processResponse:response
//                                                                             object:responseObject
//                                                                              error:error
//                                                                            request:request
//                                                                  completionHandler:completionHandler];
//                                                 }];
//        [uploadTask resume];

       
    }
    
    
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
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/xml", @"text/html", @"text/plain",@"video/mp4",nil];
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
        if (request.progressBlock) {
            request.progressBlock(downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
        }
        //NSLog(@"%@ down load %f",task2,  progress  );
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



