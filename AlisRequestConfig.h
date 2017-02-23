//
//  AlisRequestConfig.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/23.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlisRequestConfig : NSObject

//公共的server地址,有可能是测试的
@property(copy,nonatomic,nullable)NSString *generalServer;

//公共的header
@property(copy,nonatomic,nullable)NSDictionary<NSString *,NSString *> *generalHeader;

//公共的paramters
@property(copy,nonatomic,nullable)NSDictionary<NSString *,id> *generalParamters;

//回调的queue
@property(strong,nonatomic,nullable)dispatch_queue_t callBackQueue;


@end
