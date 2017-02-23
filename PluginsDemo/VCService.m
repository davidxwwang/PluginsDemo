//
//  VCService.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "VCService.h"
#import "AlisPluginsManager.h"

@implementation VCService

@synthesize businessLayer_requestFinishBlock,businessLayer_requestProgressBlock;

- (NSDictionary *)constructRequestParam
{
   // return @{@"xxx":_age, @"yyy":_name};
    return @{@"xxx":@"", @"yyy":@""};
}


- (NSString *)url
{
    return @"taobao.com";
}
 - (void)askNetwork
{
    self.businessLayer_requestFinishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
        NSLog(@"在业务层完成了请求成功的回调");
    };
    
    self.businessLayer_requestProgressBlock = ^(long long receivedSize, long long expectedSize){
        NSLog(@"在业务层完成了请求成功的回调");
    };
    [[AlisPluginsManager manager]startRequestModel:self];
}



@end
