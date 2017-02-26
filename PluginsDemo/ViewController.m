//
//  ViewController.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisPluginsManager.h"
#import "ViewController.h"
#import "VCService.h"
#import "VCService2.h"

static NSString *testServer = @"http://baobab.wdjcdn.com";
static NSString *testApi = @"/1442142801331138639111.mp4";
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
      // NSString * cc = NSStringFromClass(typeof(self)) ;
    // Do any additional setup after loading the view, typically from a nib.
    
    [[AlisPluginsManager manager] setupConfig:^(AlisRequestConfig *config) {
        config.generalServer = testServer;
        config.callBackQueue = dispatch_queue_create("david", DISPATCH_QUEUE_CONCURRENT);
       // config.generalHeader = @{@"xx":@"yy"};
        
    }];
    [[AlisPluginsManager manager]registerALLPlugins];
//    AlisRequest *request = [[AlisRequest alloc]init];
//   // char *cc =  object_getClassName(request)
//    request.url = @"www.baidu.com";
//    [[AlisPluginsManager manager]startRequest:request];
    
    //requestModel1 *requestModel = [[requestModel1 alloc]init];
//    VCService *service = [[VCService alloc]init];
//    [service askNetwork];
    
    VCService2 *service2 = [[VCService2 alloc]init];
    [service2 ask];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
