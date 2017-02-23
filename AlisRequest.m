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
        
    }
    
    return self;

}


/**
 *  计算MD5.
 *
 *  @param string 原始字符串
 *
 *  @return MD5字符串
 */
- (NSString *)md5WithString:(NSString *)string {
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
