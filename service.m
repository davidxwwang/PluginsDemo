//
//  service.m
//  PluginsDemo
//
//  Created by alisports on 2017/3/4.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "service.h"

@implementation service

- (instancetype)init:(NSString *)serviceType serviceName:(NSString *)serviceName serviceAction:(NSString *)serviceAction{
    if (self = [super init]) {
        _serviceType = serviceType;
        _serviceName = serviceName;
        _serviceAction = serviceAction;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone{
    service *copy = [[[self class] allocWithZone:zone] init:_serviceType serviceName:_serviceName serviceAction:_serviceAction];
    return copy;

}


@end
