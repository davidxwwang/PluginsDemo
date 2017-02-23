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
- (NSString *)url;

//或者可以改为代理
@property(copy,nonatomic)AlisRequestFinishRequest businessLayer_requestFinishBlock;
@property(copy,nonatomic)AlisRequestProgressRequest businessLayer_requestProgressBlock;


@end
