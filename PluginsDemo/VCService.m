//
//  VCService.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  首先查找订阅的服务（网络接口）
#import <objc/runtime.h>
#import "VCService.h"
#import "AlisPluginsManager.h"

void requestContainer(id self, SEL _cmd) {
   
    //如果该类的服务项目不包括_cmd ,就不请求
    if (![((id<AlisRequestProtocol>)self).servicesArray containsObject:NSStringFromSelector(_cmd)])
        return;
    //之后的AlisRequest唯一绑定一个serviceName，表示请求为这个网络请求的service服务
    ((id<AlisRequestProtocol>)self).serviceName = NSStringFromSelector(_cmd);
    
    [[AlisPluginsManager manager]startRequestModel:self];
    NSLog(@"my %@ car starts the engine", self);
}

@interface VCService ()
@end

@implementation VCService

@synthesize serviceName,servicesArray,businessLayer_requestFinishBlock,businessLayer_requestProgressBlock;

- (instancetype)init{
    if (self = [super init]) {
        [self fetchServices];
        __weak typeof (self)weakself = self;
        self.businessLayer_requestFinishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
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

//- (NSDictionary *)constructRequestParam
//{
//   // return @{@"xxx":_age, @"yyy":_name};
//    return @{@"xxx":@"", @"yyy":@""};
//}
//
//- (NSDictionary *)requestHead
//{
//    // return @{@"xxx":_age, @"yyy":_name};
//    return @{@"xxx":@"", @"yyy":@""};
//}
//
//
//- (NSString *)url
//{
//    return @"taobao.com";
//}

- (NSString *)api{
    if ([self.serviceName isEqualToString:@""]) {
        return @"";
    }
    return @"/1442142801331138639111.mp4";
}

- (void)askNetwork
{
    SEL s2 = NSSelectorFromString(self.servicesArray[0]);
    [self performSelector:s2]; //代表了请求服务

}

//- (id)forwardingTargetForSelector:(SEL)aSelector
//}
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    class_addMethod([self class], sel, (IMP)requestContainer, "@:");
    return YES;
}

- (void)fetchServices{
    NSString *plistPath = @"/Users/david/Desktop/FrameWorkDavid/PluginsDemo/PluginsDemo/RequestConfig.plist";
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        return;
    }
    
    NSArray *availableRequestList = [[NSArray alloc] initWithContentsOfFile
                                     :plistPath];
    NSArray *services = availableRequestList[0];
    self.servicesArray = [NSArray arrayWithArray:services];
}


@end
