//
//  AlisPluginsManager.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import "AlisRequestConfig.h"
#import "AlisRequest.h"
#import "AlisPluginProtocol.h"
#import "AlisRequestProtocol.h"
#import <Foundation/Foundation.h>

@interface AlisPluginsManager : NSObject

+ (AlisPluginsManager *)manager;

- (void)registerPlugin:(id<AlisPluginProtocol>)plugin key:(NSString *)key;

//在plist文件中
- (void)registerPlugin:(NSString *)key;

- (void)registerALLPlugins;

//- (id<AlisPluginProtocol>)plugin:(NSString *)key;


- (void)startRequest:(AlisRequest *)request;

- (void)startRequestModel:(id<AlisRequestProtocol>)requestModel;

//设置请求的公有属性，server，head等
@property(strong,nonatomic,nullable)AlisRequestConfig *config;
- (void)setupConfig:(void(^)(AlisRequestConfig *config)) block;

/*
 在这里提供了两个请求的方法，建议用第二个，因为这样使得用户层和网络协议层隔离了，用户层完全感觉不到
 网络层的存在，而网络请求所需要的参数可以在用户层找到。
 - (void)startRequest:(AlisRequest *)request;
 - (void)startRequestModel:(id<AlisRequestProtocol>)requestModel;

 所有AlisRequest的回调（成功）都在AlisPluginsManager中，再在AlisPluginsManager中向用户层发回调。
 
 */


@end
