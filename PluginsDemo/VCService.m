//
//  VCService.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  首先查找订阅的服务（网络接口）

//对资源的操作包括：
//   （1）对资源的操作。
//   （2）取消对资源的操作（资源目前的状态是操作过程中，例如：大文件的下载，上传）
//   （3）暂停对资源的操作
//
//
#import <objc/runtime.h>
#import "VCService.h"
#import "AlisRequestManager.h"
#import "service.h"

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
    
    NSArray *serviceArray = [NSStringFromSelector(_cmd) componentsSeparatedByString:@"_"];
    NSString *serviceAction = serviceArray[0];
    NSString *localServiceName = serviceArray[1];
    
    //如果该类的服务项目不包括该项服务,就终止请求
    if (![[requestServices allKeys] containsObject:localServiceName]) return;
    
    //之后的AlisRequest唯一绑定一个serviceName，表示请求为这个网络请求的service服务
    NSString *globalServiceName = [NSString stringWithFormat:@"%@_%@",NSStringFromClass([self class]),localServiceName];
    
    ((id<AlisRequestProtocol>)self).service = [[service alloc]init:@"http" serviceName:globalServiceName serviceAction:serviceAction];
    
    //注意：globalServiceName 为该服务的唯一全局的识别码
    [[AlisRequestManager manager]startRequestModel:self];
}

@interface VCService ()
@end

@implementation VCService

@synthesize service,candidateServices,businessLayer_requestFinishBlock,businessLayer_requestProgressBlock;

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
                NSLog(@"失败了:原因->");
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

- (void)handlerServiceResponse:(AlisRequest *)request response:(AlisResponse *)response{
}

#pragma mark -- request parameters
- (NSDictionary *)requestParams{
    return nil;
}


- (NSString *)api{
    NSDictionary *keys = self.candidateServices[((id<AlisRequestProtocol>)self).service.serviceName];
    NSString *api = keys[@"api"];
    return api;
}

- (AlisRequestType)requestType{
    NSDictionary *keys = self.candidateServices[((id<AlisRequestProtocol>)self).service.serviceName];
    NSString *httpMethod = keys[@"httpMethod"];
    return AlisRequestNormal;
}

@end
