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

@implementation VCService2


- (NSString *)api
{
    if([self.serviceName isEqualToString:@""])
    return nil;
    return nil;
}

- (instancetype)init{
    if (self = [super init]) {
        __weak typeof (self)weakself = self;
        self.businessLayer_requestFinishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
            
            NSLog(@"--->请求的服务方是%@",request.bindRequestModel);
            //compare with service type
            NSLog(@"在业务层完成了请求成功的回调");
            for (NSString *service in weakself.servicesArray) {
                if([request.bindRequestModel isEqualToString:service]){
                    [weakself performSelector:@selector(server) withObject:nil];
                }
            }
        };
        
        self.businessLayer_requestProgressBlock = ^(long long receivedSize, long long expectedSize){
            NSLog(@"在业务层完成了请求成功的回调");
        };
    }
    return self;
    
}
- (void)ask
{
    for (NSString *serviceName in self.servicesArray) {
        SEL xx = NSSelectorFromString(serviceName);
        [self performSelector:xx];
    }
    
}

@end
