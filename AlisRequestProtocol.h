//
//  AlisRequestProtocol.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  在每个请求中个性化的东西

#import <Foundation/Foundation.h>
#import "AlisRequestConst.h"
#import "service.h"

@class AlisRequest,AlisResponse,AlisError,service;

typedef void(^AlisRequestFinishRequest) (AlisRequest *request ,AlisResponse *response ,AlisError *error);
typedef void(^AlisRequestProgressRequest)(long long receivedSize, long long expectedSize);

@protocol AlisRequestProtocol <NSObject>

- (AlisRequestType)requestType;
//相对路径
- (NSString *)api;

- (NSDictionary *)requestParams;
    
/**
 设置HTTP的head，比如认证，cookie等
 @return 返回字典
 */
- (NSDictionary *)requestHead;
    
- (AlisHTTPMethodType)httpMethod;

//定义了一种服务
@property(copy,nonatomic)Service *currentService;

//可以提供服务的项目
@property(strong,nonatomic)NSDictionary *candidateServices;

//或者可以改为代理
@property(copy,nonatomic)AlisRequestFinishRequest businessLayer_requestFinishBlock;
@property(copy,nonatomic)AlisRequestProgressRequest businessLayer_requestProgressBlock;

    

#pragma mark -- 上传文件情况使用
//文件在沙盒里的位置,如果上传，就是源地址／如果下载任务，就是目的地址
- (NSString *)fileURL;
//上传情况下的data
- (NSData *)uploadData;
//附加消息
- (NSDictionary *)additionalInfo;

//处理访问资源后的结果
- (void)handlerServiceResponse:(AlisRequest *)request  response:(AlisResponse *)response;



@end
