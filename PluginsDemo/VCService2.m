//
//  VCService2.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/25.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "VCService2.h"
#import "AlisRequest.h"
#import "AlisRequestConfig.h"
#import "AlisRequestManager.h"

@implementation VCService2

@synthesize candidateServices;

- (NSDictionary *)requestParams{
    if (ServiceIs(self.currentServiceName, @"AskName")) {
        return nil;
    }else if (ServiceIs(self.currentServiceName, @"uploadAliyun")) {
        return nil;
    }
    return nil;
}

- (NSDictionary *)requestHead{
    if (ServiceIs(self.currentServiceName, @"AskName")) {
        return nil;
    }else if (ServiceIs(self.currentServiceName, @"uploadAliyun")) {
        return nil;
    }
    return nil;
}

- (NSString *)fileURL{
    if (ServiceIs(self.currentServiceName, @"AskName")) {
        return nil;
    }else if (ServiceIs(self.currentServiceName, @"uploadAliyun")) {
        return nil;
    }
    return nil;
}
    //上传情况下的data
- (NSData *)uploadData{
    if (ServiceIs(self.currentServiceName, @"AskName")) {
        return nil;
    }else if (ServiceIs(self.currentServiceName, @"uploadAliyun")) {
        return nil;
    }
    return nil;
}
    
- (NSDictionary *)additionalInfo{
    if (ServiceIs(self.currentServiceName, @"AskName")) {
        return nil;
    }else if (ServiceIs(self.currentServiceName, @"uploadAliyun")) {
        return nil;
    }
    return nil;
}

#pragma mark -- 服务区
- (void)customAsk{
    resumeService(@"AskName");
    sleep(1);
    //cancelService(@"AskName");
}
    
- (void)uploadFile{
    resumeService(@"uploadAliyun");
}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName response:(AlisResponse *)response{
    if (serviceName == nil) return;
    
    NSLog(@"结果已经成功返回给了业务层了");
    //根据请求服务的不同，做对应的处理。
    if(ServiceIs(serviceName, @"AskName")){
        //
    }else if(ServiceIs(serviceName, @"uploadAliyun")){
        //
    }
}


@end
