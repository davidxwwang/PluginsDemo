//
//  AlisRequestProtocol.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  在每个请求中个性化的东西

#import <Foundation/Foundation.h>
#import "AlisRequestConst.h"

@class AlisRequest,AlisResponse,AlisError;

typedef void(^AlisRequestFinishRequest) (AlisRequest *request ,AlisResponse *response ,AlisError *error);
typedef void(^AlisRequestProgressRequest)(long long receivedSize, long long expectedSize);

@protocol AlisRequestProtocol <NSObject>

- (AlisRequestType)requestType;
//相对路径
- (NSString *)api;

- (NSDictionary *)requestParams;
- (NSDictionary *)requestHead;

//表示此时此刻 需要服务的名称，一个类中很可能有好几个不同值。使用“类名／服务名” 区别不同类中有相同的服务
@property(copy,nonatomic)NSString *serviceName;

//可以提供服务的项目
@property(strong,nonatomic)NSDictionary *candidateServices;

//或者可以改为代理
@property(copy,nonatomic)AlisRequestFinishRequest businessLayer_requestFinishBlock;
@property(copy,nonatomic)AlisRequestProgressRequest businessLayer_requestProgressBlock;

#pragma mark -- 上传文件情况使用
//文件在沙盒里的位置
- (NSString *)fileURL;
//上传情况下的data
- (NSData *)uploadData;
//附加消息
- (NSDictionary *)additionalInfo;

//处理访问资源后的结果
- (void)handlerServiceResponse:(AlisRequest *)request  response:(AlisResponse *)response;



@end
