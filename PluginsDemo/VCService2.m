//
//  VCService2.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/25.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "VCService2.h"
#import "AlisRequest.h"
#import "AlisRequestConfig.h"
#import "AlisRequestManager.h"

#define resumeService(yy) ([self performSelector:NSSelectorFromString([@"resume_"  stringByAppendingFormat:@"%@", yy])])
#define cancelService(yy) ([self performSelector:NSSelectorFromString([@"cancel_"  stringByAppendingFormat:@"%@", yy])])

@implementation VCService2

@synthesize candidateServices;

- (NSDictionary *)requestParams{
    return nil;
}
- (NSDictionary *)requestHead{
    return nil;
}

- (NSString *)api{
    return @"/1442142801331138639111.mp4";
//    if([self.serviceName isEqualToString:@"AskName"]){
//        return @"/1442142801331138639111.mp4";
//    }else
//    {
//        return self.candidateServices[@"api"];
//    }
}

#pragma mark -- 服务区
- (void)customAsk{
    resumeService(@"AskName");
    sleep(1);
    cancelService(@"AskName");
   // [[AlisRequestManager manager] cancel_Request:self];
}

- (void)handlerServiceResponse:(AlisRequest *)request response:(AlisResponse *)response{
    NSLog(@"结果已经成功返回给了业务层了");
    //根据请求服务的不同，做对应的处理。
    if([request.serviceName isEqualToString:@"AskName"]){
    }
}


@end
