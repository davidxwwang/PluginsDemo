//
//  AlisRequest.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//。 问题？不指定具体的请求插件，自动判断

#import <Foundation/Foundation.h>
#import "AlisRequestProtocol.h"
#import "AlisRequestConst.h"

@class AlisRequest,AlisResponse,AlisError;


typedef void(^AlisRequestStartRequest) (void);
typedef void(^AlisRequestCancelRequest) (void);
typedef void(^AlisRequestFinishRequest) (AlisRequest *request ,AlisResponse *response ,AlisError *error);
typedef void(^AlisRequestProgressRequest)(long long receivedSize, long long expectedSize);

@interface AlisRequest : NSObject

//请求所处的环境，先假定为发出请求的类，也可以新增属性：例如->网络环境，电量，内存状况等。
@property(strong,nonatomic) NSString *context;

//唯一的标示值
@property(copy,nonatomic,nullable) NSString *identifier;

//服务器地址
@property(copy,nonatomic,nullable) NSString *server;
//path
@property(copy,nonatomic,nullable) NSString *api;

//由server和api组成，
@property(copy,nonatomic,nullable) NSString *url;

//请求参数
@property(strong,nonatomic,nullable) NSDictionary<NSString *,id> *parameters;

//请求头
@property(strong,nonatomic,nullable) NSDictionary<NSString *,NSString *> *header;

//超时时间
@property(nonatomic,assign)NSInteger timeoutInterval;
/**
 请求类型: Normal, Upload or Download, `Normal` by default.
 */
@property (nonatomic, assign) AlisRequestType requestType;

/**
 请求的HTTP方法, 默认`AlisHTTPMethodPOST`
 */
@property (nonatomic, assign) AlisHTTPMethodType httpMethod;

//是否使用公共server，当request的server设置为nil情况，默认为yes
@property (nonatomic, assign) BOOL useGeneralServer;
//是否添加公共header，默认为yes
@property (nonatomic, assign) BOOL useGeneralHeaders;
//是否添加公共parameter，默认为yes
@property (nonatomic, assign) BOOL useGeneralParameters;


@property(strong,nonatomic,nullable) id<AlisRequestProtocol> requestModel;

@property(copy,nonatomic,nullable) AlisRequestStartRequest startBlock;
@property(copy,nonatomic,nullable) AlisRequestCancelRequest cancelBlock;
@property(copy,nonatomic,nullable) AlisRequestFinishRequest finishBlock;
@property(copy,nonatomic,nullable) AlisRequestProgressRequest progressBlock;


@end
