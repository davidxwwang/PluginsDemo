//
//  AlisRequestContext.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/24.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisRequestConst.h"
#import <Foundation/Foundation.h>

//网络请求的环境
@interface AlisRequestContext : NSObject

+ (AlisRequestContext *)shareContext;

@property(assign,nonatomic)AlisNetworkReachabilityStatus networkReachabilityStatus;

@end
