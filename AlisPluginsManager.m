//
//  AlisPluginsManager.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "AlisPluginsManager.h"
#import "AlisRequestContext.h"
#import "AlisRequestConfig.h"

@interface AlisPluginsManager ()

@property(strong,nonatomic)NSMutableDictionary *pluginsDictionary;
@property(weak,nonatomic) id<AlisRequestProtocol>requestModel;

@end

@implementation AlisPluginsManager

+ (AlisPluginsManager *)manager
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
        self.pluginsDictionary = [NSMutableDictionary dictionary];
        self.requestContext = [AlisRequestContext shareContext];
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

#pragma mark -- plugin
- (void)registerPlugin:(id<AlisPluginProtocol>)plugin key:(NSString *)key
{
}

- (void)registerPlugin:(NSString *)key
{
}

- (void)registerALLPlugins
{
    NSString *plistPath = @"/Users/david/Desktop/FrameWorkDavid/PluginsDemo/PluginsDemo/plugins.plist";//[[NSBundle mainBundle] pathForResource:@"plugin" ofType:@"plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        return;
    }
    
    NSDictionary *pluginList = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    [self.pluginsDictionary addEntriesFromDictionary:pluginList];
    
}

- (id<AlisPluginProtocol>)plugin:(NSString *)key
{
    NSAssert(key, @"key should not nil");
    NSAssert(self.pluginsDictionary  || self.pluginsDictionary.count > 0, @"pluginsDictionary has problems");
    //这里应该判断是否有重复的key
    NSArray *keys = self.pluginsDictionary.allKeys;
    
    if ([keys containsObject:key]) {
        NSString *pluginString = self.pluginsDictionary[key];
        Class class = NSClassFromString(pluginString);
        id _object = [[class alloc] init];
       // NSAssert(![_object conformsToProtocol:@protocol(AlisPluginProtocol)], @"the plugin do not conform 'AlisPluginProtocol'");
        return _object;
    }
    else{
        return nil;
    }
    return nil;
}

- (void)startRequest:(AlisRequest *)request
{
    id<AlisPluginProtocol> plugin = [self plugin:@"AFNetwoking"];
    
    //在这里解析两部分，一部分是公共的--AlisRequestConfig，一部分是自己的,
    [plugin perseRequest:request config:_config];
    //设置请求的MD5值。注：可以有其他方式
    request.identifier = [self md5WithString:request.url];
    [self.requestArray addObject:request];

}

- (void)startRequestModel:(id<AlisRequestProtocol>)requestModel
{
   // if (![self canRequest:requestModel]) return;
    self.requestModel = requestModel;
    
    //request 请求的回调都在该类中
    AlisRequest *request = [[AlisRequest alloc]init];
    [self prepareRequest:request requestModel:requestModel];
    [self startRequest:request];
    request.bindRequestModel = requestModel.serviceName; //绑定业务层对应的requestModel
}

- (NSMutableArray *)requestArray{
    if (_requestArray == nil) {
        _requestArray = [NSMutableArray array];
    }
    return _requestArray;
}

- (void)cancelRequest:(AlisRequest *)request{
    if (request == nil)  return;
    
//    if (request.cancelBlock) {
//        request.cancelBlock();
//        [self.requestArray removeObject:request];
//    }
    if(request.bindRequest){
        [request.bindRequest cancel];
        [self.requestArray removeObject:request];
    }    
}

- (void)cancelRequestByIdentifier:(NSString *)requestIdentifier{
    AlisRequest *request = [self getRequestByIdentifer:requestIdentifier];
    [self cancelRequest:request];
}

- (AlisRequest *)getRequestByIdentifer:(NSString *)requestIdentifier{
    AlisRequest *_request = nil;
    for (AlisRequest *request in self.requestArray) {
        if (request.identifier == requestIdentifier) {
            _request = request;
        }
    }
    return _request;
}
#pragma mark ---
//访问网络前的最后准备，准备好请求地址，头head，参数parameters，body，url，回调方法等等
- (void)prepareRequest:(AlisRequest *)request requestModel:(id<AlisRequestProtocol>)requestModel{
    
    NSAssert([requestModel respondsToSelector:@selector(api)], @"request API should not nil");
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
    
    
    if ([requestModel respondsToSelector:@selector(constructRequestParam)]) {
        [parameters addEntriesFromDictionary:[requestModel constructRequestParam]];
    }
    if (request.useGeneralParameters) {
        [parameters addEntriesFromDictionary:self.config.generalParamters];
    }
    
    request.header = header;
    request.parameters = parameters;
    
    
    //请求的回调
    request.finishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
        //各个业务层的回调
        if (error) {
            [self failureWithError:error withRequest:request];
        }else
        {
            [self successWithResponse:response withRequest:request];
        }
    };
    
    request.progressBlock = ^(long long receivedSize, long long expectedSize){
        //各个业务层的回调
        requestModel.businessLayer_requestProgressBlock(receivedSize,expectedSize);
    };
}


- (void)failureWithError:(AlisError *)error withRequest:(AlisRequest *)request
{
    if (self.config.callBackQueue) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(self.config.callBackQueue, ^{
            weakSelf.requestModel.businessLayer_requestFinishBlock(request,nil,error);
        });
    } else {
        _requestModel.businessLayer_requestFinishBlock(request,nil,error);
    }
    
    if (request.retryCount > 0 ) {
        request.retryCount --;
        [self startRequest:request];
    }
    
}

- (void)successWithResponse:(AlisResponse *)response withRequest:(AlisRequest *)request
{
    if (self.config.callBackQueue) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(self.config.callBackQueue, ^{
            weakSelf.requestModel.businessLayer_requestFinishBlock(request,response,nil);
        });
    } else {
        _requestModel.businessLayer_requestFinishBlock(request,response,nil);
    }
    
   // [self clearBlocks:request];
    //请求成功，删除请求
    [self.requestArray removeObject:request];
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
 *  计算MD5.
 *
 *  @param string 原始字符串
 *
 *  @return MD5字符串
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
