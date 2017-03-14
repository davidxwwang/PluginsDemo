//
//  AlisRequestManager.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "AlisRequestManager.h"
#import "AlisRequestContext.h"
#import "AlisRequestConfig.h"
#import "AlisPluginManager.h"
#import "AlisRequestConst.h"


@interface AlisRequestManager ()

@property(weak,nonatomic) id<AlisRequestProtocol>requestModel;

@property(strong,nonatomic)AlisPluginManager *pluginManager;

@property(strong,nonatomic)dispatch_semaphore_t semaphore;

@end

@implementation AlisRequestManager

+ (AlisRequestManager *)manager
{
    static id _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    
    return _manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.requestContext = [AlisRequestContext shareContext];
        self.pluginManager = [AlisPluginManager manager];
        _semaphore = dispatch_semaphore_create(0);

    }
    return self;
}

#pragma mark -- config
- (void)setupConfig:(void (^)(AlisRequestConfig *config))block
{
    AlisRequestConfig *__config = [[AlisRequestConfig alloc]init];
    block(__config);
    self.config = __config;
    
}

- (void)startRequest:(AlisRequest *)request
{
    id<AlisPluginProtocol> plugin = [self.pluginManager plugin:@"AFNetwoking"];
    
    //在这里解析两部分，一部分是公共的--AlisRequestConfig，一部分是自己的,
    [plugin perseRequest:request config:_config];
    //设置请求的MD5值。注：可以有其他方式
    request.identifier = [self md5WithString:request.url];
    NSString *requestIdentifer = request.bindRequestModel.currentService.serviceName;
    if (requestIdentifer) {
        (self.requestSet)[requestIdentifer] = request;
    }
    else{
        NSLog(@"warning: 请求资源的名称不能为空");
    }
}

- (void)startRequestModel:(id<AlisRequestProtocol>)requestModel{
   // if (![self canRequest:requestModel]) return;
    //request 请求的回调都在该类中
    ServiceAction serviceAction = requestModel.currentService.serviceAction;
    if (serviceAction == Resume) {
        [self start_Request:^(AlisRequest *request) {
            request.bindRequestModel = requestModel; //绑定业务层对应的requestModel
            request.serviceName = requestModel.currentService.serviceName;
            [self prepareRequest:request requestModel:requestModel];
            //如果是同步请求
            if (self.config.enableSync) {
                dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
            }
            
        }];
    }
    else if (serviceAction == Cancel){
        [self cancelRequestByIdentifier:requestModel.currentService.serviceName];
    }
}

- (void)start_Request:(AlisRequestConfigBlock)requestConfigBlock{
    AlisRequest *request = [[AlisRequest alloc]init];
    requestConfigBlock(request);
    [self startRequest:request];
}

- (NSMutableDictionary *)requestSet{
    if (_requestSet == nil) {
        _requestSet = [NSMutableDictionary dictionary];
    }
    return _requestSet;
}

- (void)cancelRequest:(AlisRequest *)request{
    if (request == nil)  return;
    if(request.bindRequest){
        [request.bindRequest cancel];
        //sleep(2);
        // [request.bindRequest resume];
       //  [request.bindRequest suspend];
        
        [self.requestSet removeObjectForKey:request.bindRequestModel.currentService.serviceName];
    }    
}

- (void)cancelRequestByIdentifier:(NSString *)requestIdentifier{
    if (requestIdentifier == nil)  return;
    AlisRequest *request = _requestSet[requestIdentifier];
    [self cancelRequest:request];

}

#pragma mark ---
//访问网络前的最后准备，准备好请求地址，头head，参数parameters，body，url，回调方法等等
- (void)prepareRequest:(AlisRequest *)request requestModel:(id<AlisRequestProtocol>)requestModel{
    
    NSAssert([requestModel respondsToSelector:@selector(api)], @"request API should not nil");
    
    if ([requestModel respondsToSelector:@selector(requestType)]) {
        request.requestType = [requestModel requestType];
    }
    
    if ([requestModel respondsToSelector:@selector(httpMethod)]) {
        request.httpMethod = [requestModel httpMethod];
    }
    
    NSString *urlString = nil;//[NSMutableString string];
    if (request.server) {
        if ([requestModel respondsToSelector:@selector(api)]) {
            urlString = [NSString stringWithFormat:@"%@%@",request.server,[requestModel api]];
        }
    }else if (request.useGeneralServer == YES){
        if ([requestModel respondsToSelector:@selector(api)]) {
            urlString = [NSString stringWithFormat:@"%@%@",_config.generalServer,[requestModel api]];
        }
    }else if(request.url){
        urlString = request.url;
    }
    
    NSAssert(urlString, @"url should not nil");
    request.url = urlString;//[requestModel url];
    
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
   
    
    if ([requestModel respondsToSelector:@selector(requestHead)]) {
        [header addEntriesFromDictionary:[requestModel requestHead]];
    }
    if (request.useGeneralHeaders) {
        [header addEntriesFromDictionary:self.config.generalHeader];
    }
    
    
    if ([requestModel respondsToSelector:@selector(requestParams)]) {
        [parameters addEntriesFromDictionary:[requestModel requestParams]];
    }
    if (request.useGeneralParameters) {
        [parameters addEntriesFromDictionary:self.config.generalParamters];
    }
    
    request.header = header;
    request.parameters = parameters;
    
    //请求的回调
    request.finishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
        if(self.config.enableSync){
            dispatch_semaphore_signal(_semaphore);
        }
        //各个业务层的回调
        if (error) {
            [self failureWithError:error withRequest:request];
        }else
        {
            [self successWithResponse:response withRequest:request];
        }
    };
    
    __weak typeof (request) weakRequest = request;
    request.progressBlock = ^(long long receivedSize, long long expectedSize){
        //各个业务层的回调
        weakRequest.bindRequestModel.businessLayer_requestProgressBlock(receivedSize,expectedSize);
    };
}


- (void)failureWithError:(AlisError *)error withRequest:(AlisRequest *)request{
    __weak typeof (request) weakRequest = request;
    if (self.config.callBackQueue) {
        dispatch_async(self.config.callBackQueue, ^{
            weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,nil,error);
        });
    } else {
        weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,nil,error);
    }
    
    if (request.retryCount > 0 ) {
        request.retryCount --;
        [self startRequest:request];
    }
    
}

- (void)successWithResponse:(AlisResponse *)response withRequest:(AlisRequest *)request
{
    __weak typeof (request) weakRequest = request;
    if (self.config.callBackQueue) {
        dispatch_async(self.config.callBackQueue, ^{
            weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,response,nil);
        });
    } 
    else{
        weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,response,nil);
    }
    
   // [self clearBlocks:request];
    //请求成功，删除请求
    [self.requestSet removeObjectForKey:request.bindRequestModel.currentService.serviceName];
}

- (void)clearBlocks:(AlisRequest *)request{
    request.finishBlock = nil;
    request.progressBlock = nil;
    request.cancelBlock = nil;
    request.startBlock = nil;
}
#pragma mark -- help
//如果网络出现问题，返回失败
- (BOOL)canRequest:(id<AlisRequestProtocol>)requestModel{
    
    if (self.requestContext.networkReachabilityStatus == AlisNetworkReachabilityStatusNotReachable) {
        AlisError *_error = [[AlisError alloc]init];
        _error.name = @"NO_Network";
        _error.detailInfo = @"无网络连接";
        requestModel.businessLayer_requestFinishBlock(nil,nil,_error);
        return NO;
    }
    
    return YES;
}

/**
 计算MD5

 @param string string description
 @return return value description
 */
- (NSString *)md5WithString:(NSString *)string {
     NSAssert(string, @"string should not nil");
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (unsigned int) strlen(cStr), result);
    
    NSString *md5String = [NSString stringWithFormat:
                           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    
    return md5String;
}

@end
