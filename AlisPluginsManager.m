//
//  AlisPluginsManager.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisPluginsManager.h"

@interface AlisPluginsManager ()

@property(strong,nonatomic)NSMutableDictionary *pluginsDictionary;

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
    }
    return self;
}

#pragma mark -- config
- (void)setupConfig:(void (^)(AlisRequestConfig *config))block
{
    AlisRequestConfig *__config = [[AlisRequestConfig alloc]init];
    block(_config);
    self.config = __config;
    
}

#pragma mark -- plugin
- (void)registerPlugin:(id<AlisPluginProtocol>)plugin key:(NSString *)key
{
}

- (void)registerPlugin:(NSString *)key
{
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:self.modulesConfigFilename ofType:@"plist"];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
//        return;
//    }
//    
//    NSDictionary *moduleList = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
//    
//    NSArray *modulesArray = [moduleList objectForKey:kModuleArrayKey];
//    
//    [self.BHModules addObjectsFromArray:modulesArray];
  
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
    id<AlisPluginProtocol> plugin = [self plugin:@"ttt"];
    
    //在这里解析两部分，一部分是公共的--AlisRequestConfig，一部分是自己的,
    [plugin perseRequest:request config:_config];
    request.startBlock();
}

- (void)startRequestModel:(id<AlisRequestProtocol>)requestModel
{
    //requestModel.businessLayer_requestProgressBlock(0.1 ,4);
    
    //request 请求的回调都在该类中
    AlisRequest *request = [[AlisRequest alloc]init];
    request.parameters = [requestModel constructRequestParam];
    request.url = [requestModel url];
    //请求的回调
    request.finishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
        //各个业务层的回调
        requestModel.businessLayer_requestFinishBlock(request,response,error);
    };
    
    request.progressBlock = ^(long long receivedSize, long long expectedSize){
        //各个业务层的回调
        requestModel.businessLayer_requestProgressBlock(receivedSize,expectedSize);
    };

    [self startRequest:request];
}

@end
