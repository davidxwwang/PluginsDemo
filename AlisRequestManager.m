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
#import "Service.h"
#import "AlisRequestManager+AlisRequest.h"

@interface AlisRequestManager ()

@property(weak,nonatomic) id<AlisRequestProtocol>requestModel;

@property(strong,nonatomic)AlisPluginManager *pluginManager;

@end

@implementation AlisRequestManager

+ (AlisRequestManager *)sharedManager
{
    static id _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    
    return _manager;
}

+ (AlisRequestManager *)manager{
    return [[[self class]alloc] init];
}

- (instancetype)init{
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
    if (plugin == nil) {
        NSLog(@"对应的插件不存在！");
        return;
    }
    
    //在这里解析两部分，一部分是公共的--AlisRequestConfig，一部分是自己的,
    [plugin perseRequest:request config:_config];
    //设置请求的MD5值。注：可以有其他方式
    request.identifier = [self md5WithString:request.url];
    NSString *requestIdentifer = request.context.serviceName;
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

- (void)startRequestModel:(id<AlisRequestProtocol>)requestModel service:(Service *)service{
    // if (![self canRequest:requestModel]) return;
    //request 请求的回调都在该类中
    ServiceAction serviceAction = service.serviceAction;
    if (serviceAction == Resume) {
        [self start_Request:^(AlisRequest *request) {
            request.bindRequestModel = requestModel; //绑定业务层对应的requestModel
            request.serviceName = service.serviceName;
            [self prepareRequest:request requestModel:requestModel service:service];
            //如果是同步请求
            if (self.config.enableSync) {
                dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
            }
        }];
    }
    else if (serviceAction == Cancel){
        [self cancelRequestByIdentifier:service.serviceName];
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
- (void)prepareRequest:(AlisRequest *)request requestModel:(id<AlisRequestProtocol>)requestModel service:(Service *)service{
    
    [self adapteAlisRequest:request requestModel:requestModel service:service];
//    //设置请求的上下文
//    request.context.makeRequestClass = service.serviceAgent;
//    request.context.serviceName = service.serviceName;
//    
//    // NSAssert([requestModel respondsToSelector:@selector(api)], @"request API should not nil");
//    
//    if ([service.serviceAgent respondsToSelector:@selector(requestType)]) {
//        request.requestType = [service.serviceAgent requestType];
//    }else if ([requestModel respondsToSelector:@selector(requestType)]) {
//        request.requestType = [requestModel requestType];
//    }else{
//        NSLog(@"'requestType' 没有设置，默认在AlisRequest中设置");
//    }
//    
//    if (request.requestType == AlisRequestDownload) {
//        if ([service.serviceAgent respondsToSelector:@selector(fileURL)]) {
//            request.downloadPath = [service.serviceAgent fileURL];
//        }else if ([requestModel respondsToSelector:@selector(fileURL)]) {
//            request.downloadPath = [requestModel fileURL];
//        }
//        
//        if(request.downloadPath == nil){
//            NSLog(@"下载任务，没有设置下载的路径!!!");
//        }
//    }else if (request.requestType == AlisRequestUpload) {
//        if ([service.serviceAgent respondsToSelector:@selector(fileURL)]) {
//           [request addFormDataWithName:@"test1" fileURL:[service.serviceAgent fileURL]];
//        }
//            
//        if ([service.serviceAgent respondsToSelector:@selector(uploadData)]) {
//            [request addFormDataWithName:@"test2" fileData:[service.serviceAgent uploadData]];
//        }
//            
//        if(request.downloadPath == nil){
//            NSLog(@"下载任务，没有设置下载的路径!!!");
//        }
//    }
//
//    
//    if ([service.serviceAgent respondsToSelector:@selector(httpMethod)]) {
//        request.httpMethod = [service.serviceAgent httpMethod];
//    }else if ([requestModel respondsToSelector:@selector(httpMethod)]) {
//        request.httpMethod = [requestModel httpMethod];
//    }else{
//        NSLog(@"'httpMethod' 没有设置，默认在AlisRequest中设置");
//    }
//    
//    if ([service.serviceAgent respondsToSelector:@selector(api)]) {
//        request.api = [service.serviceAgent api];
//    }else if ([requestModel respondsToSelector:@selector(api)]) {
//        request.api = [requestModel api];
//    }else{
//        NSLog(@"'api' 没有设置，这个必须手动设置");
//    }
//    
//    if ([service.serviceAgent respondsToSelector:@selector(server)]) {
//        request.server = [service.serviceAgent server];
//    }else if ([requestModel respondsToSelector:@selector(server)]) {
//        request.server = [requestModel server];
//    }else if (request.useGeneralServer == YES){
//        request.server = _config.generalServer;
//    }else{
//        NSLog(@"'server' 没有设置，这个必须手动设置");
//    }
//    
//    NSString *urlString = [NSString stringWithFormat:@"%@%@",request.server,request.api];
//    NSAssert(urlString, @"url should not nil");
//    request.url = urlString;//[requestModel url];
//    
//    NSMutableDictionary *header = [NSMutableDictionary dictionary];
//    if ([service.serviceAgent respondsToSelector:@selector(requestHead)]) {
//        [header addEntriesFromDictionary:[requestModel requestHead]];
//    }
//    if ([requestModel respondsToSelector:@selector(requestHead)]) {
//        [header addEntriesFromDictionary:[requestModel requestHead]];
//    }
//    if (request.useGeneralHeaders) {
//        [header addEntriesFromDictionary:self.config.generalHeader];
//    }
//    if (header == nil || header.count == 0){
//        NSLog(@"'head' 一无所有");
//    }
//    request.header = header;
//    
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    if ([service.serviceAgent respondsToSelector:@selector(requestParams)]) {
//        [header addEntriesFromDictionary:[requestModel requestParams]];
//    }
//    if ([requestModel respondsToSelector:@selector(requestParams)]) {
//        [header addEntriesFromDictionary:[requestModel requestParams]];
//    }
//    if (request.useGeneralParameters) {
//        [header addEntriesFromDictionary:self.config.generalParamters];
//    }
//    if (parameters == nil || parameters.count == 0) {
//        NSLog(@"'head' 一无所有");
//    }
//    request.parameters = parameters;
//    
//    //请求的回调
//    request.finishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
//        if(self.config.enableSync){
//            dispatch_semaphore_signal(_semaphore);
//        }
//        //各个业务层的回调
//        if (error) {
//            [self failureWithError:error withRequest:request];
//        }
//        else{
//            [self successWithResponse:response withRequest:request];
//        }
//    };
//    
//    __weak typeof (request) weakRequest = request;
//    request.progressBlock = ^(AlisRequest *request,long long receivedSize, long long expectedSize){
//        //各个业务层的回调
//        weakRequest.bindRequestModel.businessLayer_requestProgressBlock(request,receivedSize,expectedSize);
//    };
}

//访问网络前的最后准备，准备好请求地址，头head，参数parameters，body，url，回调方法等等
- (void)prepareRequest:(AlisRequest *)request requestModel:(id<AlisRequestProtocol>)requestModel{
    
    // NSAssert([requestModel respondsToSelector:@selector(api)], @"request API should not nil");
    
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
        }
        else{
            [self successWithResponse:response withRequest:request];
        }
    };
    
    __weak typeof (request) weakRequest = request;
    request.progressBlock = ^(AlisRequest *request,long long receivedSize, long long expectedSize){
        //各个业务层的回调
        weakRequest.bindRequestModel.businessLayer_requestProgressBlock(request,receivedSize,expectedSize);
    };
}


- (void)failureWithError:(AlisError *)error withRequest:(AlisRequest *)request{
    __weak typeof (request) weakRequest = request;
    if (self.config.callBackQueue) {
        dispatch_async(self.config.callBackQueue, ^{
            weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,nil,error);
        });
    } 
    else {
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

#pragma mark -- chainRequest
- (void)sendChainRequest:(AlisChainRConfigBlock )chainRequestConfigBlock success:(AlisChainRSucessBlock)success failure:(AlisChainRFailBlock)failure finish:(AlisChainRFinishedBlock)finish{
    
    AlisChainRequestmanager *chainRequestmanager = [[AlisChainRequestmanager alloc]init];
    if (chainRequestConfigBlock) {
        //设置chainRequestmanager
        chainRequestConfigBlock(chainRequestmanager);
    }
    
    [self sendChainRequest:chainRequestmanager];
    
    //设置请求的MD5值。注：可以有其他方式
    //  request.identifier = [self md5WithString:request.url];
    //        NSString *requestIdentifer = request.bindRequestModel.currentService.serviceName;
    //        if (requestIdentifer) {
    //            (self.requestSet)[requestIdentifer] = request;
    //        }
    //        else{
    //            NSLog(@"warning: 请求资源的名称不能为空");
    //        }
}

- (void)sendChainRequest:(AlisChainRequestmanager *)chainRequestmanager{
    if (chainRequestmanager.runningRequest) {
        id<AlisPluginProtocol> plugin = [self.pluginManager plugin:@"AFNetwoking"];
        
        //在这里解析两部分，一部分是公共的--AlisRequestConfig，一部分是自己的,
        [self prepareRequest:chainRequestmanager.runningRequest onProgress:^(AlisRequest *request, long long receivedSize, long long expectedSize) {
            
        } onSuccess:^(AlisRequest *request, AlisResponse *response, AlisError *error) {
            
        } onFailure:^(AlisRequest *request, AlisResponse *response, AlisError *error) {
            
        } onFinished:^(AlisRequest *request, AlisResponse *response, AlisError *error) {
            if([chainRequestmanager onFinishedOneRequest:request response:response error:error]){
                //请求全部完成
            }
            else{
                //请求还没有完全完成
                if(chainRequestmanager.runningRequest){
                    [self sendChainRequest:chainRequestmanager];
                }
            }
        }];
    }
}


- (void)prepareRequest:(AlisRequest *)request
            onProgress:(AlisRequestProgressRequest)progressBlock
             onSuccess:(AlisRequestFinishRequest)successBlock
             onFailure:(AlisRequestFinishRequest)failureBlock
            onFinished:(AlisRequestFinishRequest)finishedBlock {
    
    // set callback blocks for the request object.
    //    if (successBlock) {
    //        [request setValue:successBlock forKey:@"_successBlock"];
    //    }
    //    if (failureBlock) {
    //        request.finishBlock
    //    }
    if (finishedBlock) {
        request.finishBlock = finishedBlock;
    }
    //    if (progressBlock && request.requestType != kXMRequestNormal) {
    //        [request setValue:progressBlock forKey:@"_progressBlock"];
    //    }
    
    //    // add general user info to the request object.
    //    if (!request.userInfo && self.generalUserInfo) {
    //        request.userInfo = self.generalUserInfo;
    //    }
    //    
    //    // add general parameters to the request object.
    //    if (request.useGeneralParameters && self.generalParameters.count > 0) {
    //        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    //        [parameters addEntriesFromDictionary:self.generalParameters];
    //        if (request.parameters.count > 0) {
    //            [parameters addEntriesFromDictionary:request.parameters];
    //        }
    //        request.parameters = parameters;
    //    }
    //    
    //    // add general headers to the request object.
    //    if (request.useGeneralHeaders && self.generalHeaders.count > 0) {
    //        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    //        [headers addEntriesFromDictionary:self.generalHeaders];
    //        if (request.headers) {
    //            [headers addEntriesFromDictionary:request.headers];
    //        }
    //        request.headers = headers;
    //    }
    //    
    //    // process url for the request object.
    //    if (request.url.length == 0) {
    //        if (request.server.length == 0 && request.useGeneralServer && self.generalServer.length > 0) {
    //            request.server = self.generalServer;
    //        }
    //        if (request.api.length > 0) {
    //            NSURL *baseURL = [NSURL URLWithString:request.server];
    //            // ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected.
    //            if ([[baseURL path] length] > 0 && ![[baseURL absoluteString] hasSuffix:@"/"]) {
    //                baseURL = [baseURL URLByAppendingPathComponent:@""];
    //            }
    //            request.url = [[NSURL URLWithString:request.api relativeToURL:baseURL] absoluteString];
    //        } else {
    //            request.url = request.server;
    //        }
    //    }
    //    NSAssert(request.url.length > 0, @"The request url can't be null.");
}

@end



#pragma mark -- AlisChainRequestmanager

@interface AlisChainRequestmanager()
{
    //当前请求的 index
    NSInteger _chainIndex;
}

/**
 得到的response数组
 */
@property(strong,nonatomic)NSMutableArray *responseArray;

/**
 保存下次请求的block，以便前一次请求完成后，设置第二次请求。
 */
@property(strong,nonatomic)NSMutableArray *nextRequestArray;

@property(strong,nonatomic)AlisRequest *runningRequest;


/**
 finish 表示整个请求都结束，success 表示部分成功
 */
@property (nonatomic, copy) AlisChainRSucessBlock chainSuccessBlock;
@property (nonatomic, copy) AlisChainRFailBlock chainFailureBlock;
@property (nonatomic, copy) AlisChainRFinishedBlock chainFinishedBlock;

@end

@implementation AlisChainRequestmanager

- (instancetype)init {
    self = [super init];
    if (self) {
        _chainIndex = 0;
        _responseArray = [NSMutableArray array];
        _nextRequestArray = [NSMutableArray array];
    }
    return self;
}

- (AlisChainRequestmanager *)onFirst:(AlisRequestConfigBlock)firstBlock{
    NSAssert(firstBlock != nil, @"firstBlock cannot be nil");
    NSAssert(self.nextRequestArray == nil, @"");
    [_responseArray addObject:[NSNull null]];
    _runningRequest = [[AlisRequest alloc]init];
    firstBlock(_runningRequest);
    
    return nil;
}

- (AlisChainRequestmanager *)onNext:(AlisChainNextRBlock)nextBlock{
    NSAssert(nextBlock != nil, @"firstBlock cannot be nil");
    NSAssert(self.nextRequestArray == nil, @"");
    [_responseArray addObject:[NSNull null]];
    [_nextRequestArray addObject:nextBlock];
    
    return nil;
}
/**
 chainRequest每项请求完成都回调
 
 @param request 完成的AlisRequest
 @param responseObject  收到的数据
 @param error error description
 @return YES:表示chain请求全部完成请求， NO:表示还没有都完成
 */
- (BOOL)onFinishedOneRequest:(AlisRequest *)request response:(nullable id)responseObject error:(nullable NSError *)error{
    BOOL isFinished = NO;
    if (responseObject) {
        //得到第_chainIndex个请求的结果
        [_responseArray replaceObjectAtIndex:_chainIndex withObject:responseObject];
        
        if (_chainIndex < _nextRequestArray.count) {
            _runningRequest = [AlisRequest request];
            AlisChainNextRBlock nextBlock = _nextRequestArray[_chainIndex];
            //设置下一个请求参数
            nextBlock(_runningRequest,responseObject,error);
            if (_chainSuccessBlock) {
                _chainSuccessBlock(nil);
            }
            
            if (_chainFailureBlock) {
                _chainFailureBlock(nil);
            }
            
            isFinished = NO;
            
        }
        else{
            if (_chainSuccessBlock) {
                _chainSuccessBlock(nil);
            }
            
            if (_chainFailureBlock) {
                _chainFailureBlock(nil);
            }
            
            isFinished = YES;
        }
    }
    else{
        if(error){
            [_responseArray replaceObjectAtIndex:_chainIndex withObject:error];
        }
        if (_chainSuccessBlock) {
            _chainSuccessBlock(nil);
        }
        
        if (_chainFailureBlock) {
            _chainFailureBlock(nil);
        }
        
    }
    
    _chainIndex++;
    return isFinished;
}

@end

