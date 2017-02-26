//
//  AlisRequest.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "AlisRequest.h"

@implementation AlisRequest

- (instancetype)init
{
    if (self = [super init]) {
        _timeoutInterval = 15;
        _useGeneralServer = YES;
        _useGeneralHeaders = YES;
        _useGeneralParameters = YES;
        
        _requestType = AlisRequestNormal;
        _httpMethod = AlisHTTPMethodPOST;
        _bindRequestModel = nil;
        
        _retryCount = 3;
        
    }
    
    return self;

}



@end
