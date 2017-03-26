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
    _currentRequest = @"AskDemo";
    [[AlisRequestManager sharedManager] setupConfig:^(AlisRequestConfig *config) {
        config.generalServer = testServer;
        config.callBackQueue = dispatch_queue_create("david", DISPATCH_QUEUE_CONCURRENT);
        config.enableSync = NO;
       // config.generalHeader = @{@"xx":@"yy"};
        
    }];
    
    [[AlisPluginManager manager]registerALLPlugins];
//    VCService2 *service2 = [[VCService2 alloc]init];
//    [service2 customAsk];
    
//    [[AlisRequestManager sharedManager]sendChainRequest:^( AlisChainRequestmanager *manager){
//        [[manager onFirst:^(AlisRequest *request) {
//            
//        }] onNext:^(AlisRequest *request, id  _Nullable responseObject, NSError *error) {
//            //上一次的请求结果，在responseObject中
//        }];
//        
//    } success:^(NSArray *responseArray) {
//        
//    } failure:^(id data) {
//        
//    } finish:^(id data) {
//        
//    }]; 
    [[AlisServiceProxy shareManager] injectService:self];
    //resumeService1(@"AskDemo");
    resumeService1(@"uploadData");
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
        return realPath;
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
