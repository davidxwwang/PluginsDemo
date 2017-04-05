//
//  ViewController.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import "AlisPluginManager.h"
#import "AlisRequestManager.h"
#import "ViewController.h"
#import "VCService.h"
#import "VCService2.h"

#import "AlisServiceProxy.h"

static NSString *testServer = @"http://baobab.wdjcdn.com";
static NSString *testApi = @"/1442142801331138639111.mp4";
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AlisServiceProxy shareManager] injectService:self];
    _currentRequest = @"uploadData";
    [[AlisRequestManager sharedManager] setupConfig:^(AlisRequestConfig *config) {
        config.generalServer = testServer;
        config.callBackQueue = dispatch_queue_create("david", DISPATCH_QUEUE_CONCURRENT);
        config.enableSync = NO;
       // config.generalHeader = @{@"xx":@"yy"};
        
    }];
    
    [[AlisPluginManager manager]registerALLPlugins];
    
    [[AlisRequestManager sharedManager]sendChainRequest:^( AlisChainRequest *manager){
        [[[manager onFirst:^(AlisRequest *request) {
            request.url = @"https://httpbin.org/get";
            request.httpMethod = AlisHTTPMethodGET;
            request.parameters = @{@"method": @"get"};            
        }] onNext:^(AlisRequest *request, id  _Nullable responseObject, AlisError *error) {
            //上一次的请求结果，在responseObject中
            NSLog(@"此时第一个请求返回结果了，可以依据它，设置第二个请求");
            request.url = @"https://httpbin.org/post";
            request.httpMethod = AlisHTTPMethodGET;
            request.parameters = @{@"method": @"post"};
        }]onNext:^(AlisRequest *request, id  _Nullable responseObject, AlisError *error) {
            //上一次的请求结果，在responseObject中
            NSLog(@"此时第一个请求返回结果了，可以依据它，设置第二个请求");
            request.url = @"https://httpbin.org/put";
            request.httpMethod = AlisHTTPMethodPUT;
            request.parameters = @{@"method": @"put"};
        }];
        
    } success:^(NSArray *__nullable responseArray) {
        NSLog(@"success");
        
    } failure:^(NSArray * __nullable errorArray) {
        NSLog(@"failure");
        
    } finish:^(NSArray * _Nonnull responseArray ,NSArray * __nullable errorArray) {
        NSLog(@"链式请求结束了 不容易啊");
        
    }]; 
    
    //resumeService1(@"AskDemo");
    //resumeService1(@"uploadData");
}

#pragma mark -- http 
- (AlisRequestType)requestType{
    if (ServiceIs1(_currentRequest, @"AskDemo")) {
        return AlisRequestUpload;
    }
    return AlisRequestUpload;
}

- (NSString *)server{
    if (ServiceIs1(_currentRequest, @"AskDemo")) {
        return @"https://httpbin.org";
    }
    return nil;
}

- (NSString *)api{
    if (ServiceIs1(_currentRequest, @"AskDemo")) {
        return @"/get";
    }
    
    return nil;
}

- (NSDictionary *)requestParams{
    if (ServiceIs1(_currentRequest, @"AskDemo")) {
        return @{@"method": @"get"};
    }
    return nil;
}

- (NSData *)uploadData{
    NSData *data = [@"testdata" dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (NSString *)fileURL{
    if (ServiceIs1(_currentRequest, @"AskDemo")) {
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *realPath = [NSString stringWithFormat:@"%@%@",path,@"/demo.mp4"];
        return realPath;
    }else if (ServiceIs1(_currentRequest, @"uploadData")) {
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *realPath = [NSString stringWithFormat:@"%@%@",path,@"/demo.mp4"];
        NSString *__path = [NSString stringWithFormat:@"%@%@",@"file://localhost/",realPath];
        return __path;
    }
    return nil;
}

//附加消息
- (NSDictionary *)additionalInfo{
    return nil;
}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName response:(AlisResponse *)response{
    if (ServiceIs1(_currentRequest, @"AskDemo")) {
    }
    
    NSLog(@"%@ back",serviceName);
}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName progress:(float)progress{
    if (ServiceIs1(_currentRequest, @"AskDemo")) {
    }
    
    NSLog(@"%@ back",serviceName);
}

@end
