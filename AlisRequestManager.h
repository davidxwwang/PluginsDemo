//
//  AlisRequestManager.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  把网络请求的每一个接口都看为一个资源
#import "AlisRequestConfig.h"
#import "AlisRequest.h"
#import "AlisPluginProtocol.h"
#import "AlisRequestProtocol.h"
#import "AlisRequestContext.h"
#import <Foundation/Foundation.h>

@interface AlisRequestManager : NSObject

+ (AlisRequestManager *)manager;

//所有请求的数组，请求发出，加入数组；请求结束，取消从数组中删掉；请求暂停不删除
@property(strong,nonatomic,nullable)NSMutableArray *requestArray;

@property(strong,nonatomic,nullable)AlisRequestContext *requestContext;

- (void)startRequest:(AlisRequest *)request;
- (void)startRequestModel:(id<AlisRequestProtocol>)requestModel;

- (void)cancelRequest:(AlisRequest *)request;

//注意：
- (void)cancel_Request:( id<AlisRequestProtocol>)request;
- (void)cancelRequestByIdentifier:(NSString *)requestIdentifier;
- (void)cancelRequestwithServiceName:(NSString *)requestIdentifier;

//设置请求的公有属性，server，head等
@property(strong,nonatomic,nullable)AlisRequestConfig *config;
- (void)setupConfig:(void(^)(AlisRequestConfig *config)) block;

/*
 在这里提供了两个请求的方法，建议用第二个，因为这样使得用户层和网络协议层隔离了，用户层完全感觉不到
 网络层的存在，而网络请求所需要的参数可以在用户层找到。
 - (void)startRequest:(AlisRequest *)request;
 - (void)startRequestModel:(id<AlisRequestProtocol>)requestModel;

 所有AlisRequest的回调（成功）都在AlisRequestManager中，再在AlisRequestManager中向用户层发回调。
 
 */


@end
