//
//  AlisServiceProxy.m
//  PluginsDemo
//
//  Created by alisports on 2017/3/21.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisServiceProxy.h"

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
#import <objc/runtime.h>
#import "VCService.h"
#import "AlisRequestManager.h"
#import "service.h"

static NSDictionary *candidateRequestServices;

void fetchCandidateRequestServices1()
{
    if (candidateRequestServices != nil) return;
    NSString *plistPath = @"/Users/david/Desktop/FrameWorkDavid/PluginsDemo/PluginsDemo/RequestConfig.plist";
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) return;
    
    NSDictionary *availableRequestServices = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
    candidateRequestServices = [NSDictionary dictionaryWithDictionary:availableRequestServices];
}

void requestContainer1(id self, SEL _cmd) {
    NSString *classString = NSStringFromClass([self class]);
    ((id<AlisRequestProtocol>)self).candidateServices = candidateRequestServices[classString];
    

    NSDictionary *requestServices = ((id<AlisRequestProtocol>)self).candidateServices;
    
    NSArray *serviceArray = [NSStringFromSelector(_cmd) componentsSeparatedByString:@"_"];
    if(serviceArray.count < 2) return;
    
    NSString *serviceAction = serviceArray[0];
    NSString *localServiceName = serviceArray[1];
    
    //如果该类的服务项目不包括该项服务,就终止请求
    //消息转发过来,如果requestServices = nil，从注册的地方在查找
    if (requestServices == nil) {
        
    }
    else{
        if (![[requestServices allKeys] containsObject:localServiceName]) return;
    }
    
    //之后的AlisRequest唯一绑定一个serviceName，表示请求为这个网络请求的service服务
    NSString *globalServiceName = [NSString stringWithFormat:@"%@_%@",NSStringFromClass([self class]),localServiceName];
    
    // 这个好像做成属性不太好，因为是实时变化的
    NSDictionary* serviceType = requestServices[localServiceName];
    ServiceType ser= [Service convertServiceTypeFromString:serviceType[@"protocol"]];
    ServiceAction action= [Service convertServiceActionFromString:serviceAction];
    
    ((id<AlisRequestProtocol>)self).currentService = [[Service alloc]init:ser serviceName:globalServiceName serviceAction:action];
    ((VCService *)self).currentServiceName = localServiceName;
    
    //注意：globalServiceName 为该服务的唯一全局的识别码
    [[AlisRequestManager manager]startRequestModel:self];
}

@interface AlisServiceProxy ()
/**
 委托者
 */
@property(strong,nonatomic)NSMutableDictionary *serviceAgents;

@end

@implementation AlisServiceProxy

@synthesize currentService,candidateServices,businessLayer_requestFinishBlock,businessLayer_requestProgressBlock;

+ (AlisServiceProxy *)shareManager{
    static AlisServiceProxy *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[AlisServiceProxy alloc]init];
        
    });
    return _manager;
}

- (instancetype)init{
    if (self = [super init]) {
        fetchCandidateRequestServices1();
        self.serviceAgents = [NSMutableDictionary dictionary];
//        NSString *classString = NSStringFromClass([self class]);
//        self.candidateServices = candidateRequestServices[classString];
        __weak typeof (self) weakSelf = self;
        self.businessLayer_requestFinishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
            NSLog(@"在业务层完成了请求成功的回调");
            if (error) {
                NSLog(@"失败了:原因->");
            }else
            {
                [weakSelf handlerServiceResponse:request serviceName:[weakSelf toLocalServiceName:request.serviceName] response:response];
            }
        };
        
        self.businessLayer_requestProgressBlock = ^(AlisRequest *request ,long long receivedSize, long long expectedSize){
            float progress = (float)(receivedSize)/expectedSize;
            NSLog(@"下载／上传进度---->%f",progress);
            [weakSelf handlerServiceResponse:request serviceName:[weakSelf toLocalServiceName:request.serviceName] progress:progress];
        };
    }
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    NSString *selString = NSStringFromSelector(sel);
    if ([selString containsString:@"resume_"]) {
        class_addMethod([self class], sel, (IMP)requestContainer1, "@:");
        return YES;
    }
    else{
        return NO;//[super resolveInstanceMethod:sel];
    }
    return NO;//[super resolveInstanceMethod:sel];
}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName response:(AlisResponse *)response{
}

#pragma mark -- request parameters
- (NSData *)uploadData{
    return nil;
}

- (NSDictionary *)additionalInfo{
    return nil;
}

- (NSString *)fileURL{
    return nil;
}

//- (NSDictionary *)requestParams{
//    return nil;
//}

//- (NSString *)api{
//    NSDictionary *keys = self.candidateServices[_currentServiceName];
//    NSString *api = keys[@"api"];
//    return api;
//}

- (AlisRequestType)requestType{
    NSDictionary *keys = self.candidateServices[_currentServiceName];
    NSString *httpMethod = keys[@"httpMethod"];
    
    return AlisRequestNormal;
}

- (AlisHTTPMethodType)httpMethod{
    NSDictionary *keys = self.candidateServices[_currentServiceName];
    NSString *httpMethod = keys[@"httpMethod"];
    //if (httpMethod) return httpMethod;
    
    return AlisHTTPMethodGET;
}

#pragma mark -- help

/**
 全局serviceName变为local的serviceName 
 @param globalServiceName 全局serviceName
 @return local的serviceName
 */
- (NSString *)toLocalServiceName:(NSString *)globalServiceName{
    
    if (globalServiceName == nil) return nil;
    NSArray *serviceArray = [globalServiceName componentsSeparatedByString:@"_"];
    if (serviceArray.count == 2) {
        return serviceArray[1];
    }
    return nil;
}

- (void)injectService:(id<AlisRequestProtocol>)object{
    NSParameterAssert(object);
    NSAssert([object conformsToProtocol:@protocol(AlisRequestProtocol)], @"'object' 需要服从协议");
    
    NSString *classString = NSStringFromClass([object class]);
    _serviceAgents[classString] = object;
}

#pragma mark --
//- (id)forwardingTargetForSelector:(SEL)aSelector
//{
//    return nil;
//}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
//    NSString *selString = NSStringFromSelector(sel);
//    if ([selString containsString:@"resume_"]) {
//        class_addMethod([self class], sel, (IMP)requestContainer1, "@:");
//        
//    }
//
//    for (id object in self.agents) {
//        if ([object respondsToSelector:sel]) {
//            return [object methodSignatureForSelector:sel];
//        }
//    }
    return [super methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation{
//    for (id object in self.agents) {
//        if ([object respondsToSelector:invocation.selector]) {
//            [invocation invokeWithTarget:object];
//            return;
//        }
//    }
    [super forwardInvocation:invocation];
}


@end

