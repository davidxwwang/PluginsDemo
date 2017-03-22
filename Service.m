//
//  service.m
//  PluginsDemo
//
//  Created by alisports on 2017/3/4.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "Service.h"

@implementation Service

- (instancetype)init:(ServiceType)serviceType serviceName:(NSString *)serviceName serviceAction:(ServiceAction)serviceAction{
    if (self = [super init]) {
        _serviceType = serviceType;
        _serviceName = serviceName;
        _serviceAction = serviceAction;
    }
    return self;
}

+ (ServiceType)convertServiceTypeFromString:(NSString *)yy{
    if ([yy isEqualToString:@"http"] || [yy isEqualToString:@"https"]) {
        return HTTP;
    }
    return HTTP;
}
    
+ (ServiceAction)convertServiceActionFromString:(NSString *)yy{
    if ([yy isEqualToString:@"resume"]) {
        return Resume;
    }else if ([yy isEqualToString:@"cancel"]) {
        return Cancel;
    }
    
    return Resume;
}


- (instancetype)copyWithZone:(NSZone *)zone{
    Service *copy = [[[self class] allocWithZone:zone] init:_serviceType serviceName:_serviceName serviceAction:_serviceAction];
    return copy;

}


@end
