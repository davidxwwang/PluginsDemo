//
//  VCService.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  首先查找订阅的服务（网络接口）
#import <objc/runtime.h>
#import "VCService.h"
#import "AlisRequestManager.h"

static NSDictionary *candidateRequestServices;

void fetchCandidateRequestServices()
{
    if (candidateRequestServices != nil) return;
    NSString *plistPath = @"/Users/david/Desktop/FrameWorkDavid/PluginsDemo/PluginsDemo/RequestConfig.plist";
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) return;
    
    NSDictionary *availableRequestServices = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
    candidateRequestServices = [NSDictionary dictionaryWithDictionary:availableRequestServices];
}


void requestContainer(id self, SEL _cmd) {
   
    NSDictionary *requestServices = ((id<AlisRequestProtocol>)self).candidateServices;
    //如果该类的服务项目不包括该项服务,就终止请求
    if (![[requestServices allKeys] containsObject:NSStringFromSelector(_cmd)]) return;
    
    //之后的AlisRequest唯一绑定一个serviceName，表示请求为这个网络请求的service服务
    ((id<AlisRequestProtocol>)self).serviceName = NSStringFromSelector(_cmd);
    [[AlisRequestManager manager]startRequestModel:self];
}

@interface VCService ()
@end

@implementation VCService

@synthesize serviceName,candidateServices,businessLayer_requestFinishBlock,businessLayer_requestProgressBlock;

- (instancetype)init{
    if (self = [super init]) {
       // [self fetchServices];
        fetchCandidateRequestServices();
        NSString *classString = NSStringFromClass([self class]);
        self.candidateServices = candidateRequestServices[classString];

        __weak typeof (self) weakSelf = self;
        self.businessLayer_requestFinishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
            NSLog(@"在业务层完成了请求成功的回调");
            if (error) {
            }else
            {
                [weakSelf handlerServiceResponse:request response:response];
            }
        };
        
        self.businessLayer_requestProgressBlock = ^(long long receivedSize, long long expectedSize){
            float progress = (float)(receivedSize)/expectedSize;
            NSLog(@"下载／上传进度---->%f",progress);
        };
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    NSLog(@"转发了");
    return nil;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    class_addMethod([self class], sel, (IMP)requestContainer, "@:");
    return YES;
}

//- (void)fetchServices{
//    NSString *plistPath = @"/Users/david/Desktop/FrameWorkDavid/PluginsDemo/PluginsDemo/RequestConfig.plist";
//    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) return;
//    
//    NSDictionary *availableRequestServices = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
//    self.requestServices = availableRequestServices;
//}

#pragma mark -- request parameters
- (NSString *)api{
    NSDictionary *keys = self.candidateServices[self.serviceName];
    NSString *api = keys[@"api"];
    return api;
}

- (AlisRequestType)requestType{
    NSDictionary *keys = self.candidateServices[self.serviceName];
    NSString *httpMethod = keys[@"httpMethod"];
    return httpMethod;
}

@end
