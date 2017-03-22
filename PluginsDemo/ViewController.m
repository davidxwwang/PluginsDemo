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
    
    [[AlisRequestManager sharedManager] setupConfig:^(AlisRequestConfig *config) {
        config.generalServer = testServer;
        config.callBackQueue = dispatch_queue_create("david", DISPATCH_QUEUE_CONCURRENT);
        config.enableSync = NO;
       // config.generalHeader = @{@"xx":@"yy"};
        
    }];
    
    [[AlisPluginManager manager]registerALLPlugins];
    VCService2 *service2 = [[VCService2 alloc]init];
    [service2 customAsk];
    
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
    resumeService1(@"ddss");
}

@end
