//
//  AlisRequestProtocol.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  在每个请求中个性化的东西

#import <Foundation/Foundation.h>

@class AlisRequest,AlisResponse,AlisError;

typedef void(^AlisRequestFinishRequest) (AlisRequest *request ,AlisResponse *response ,AlisError *error);
typedef void(^AlisRequestProgressRequest)(long long receivedSize, long long expectedSize);

@protocol AlisRequestProtocol <NSObject>

- (NSDictionary *)constructRequestParam;
- (NSDictionary *)requestHead;
//相对路径
- (NSString *)api;

//表示此时此刻 需要服务的名称，一个类中很可能有好几个不同值。
@property(copy,nonatomic)NSString *serviceName;

//可以提供服务的项目
@property(copy,nonatomic)NSArray *servicesArray;

//或者可以改为代理
@property(copy,nonatomic)AlisRequestFinishRequest businessLayer_requestFinishBlock;
@property(copy,nonatomic)AlisRequestProgressRequest businessLayer_requestProgressBlock;


@end
