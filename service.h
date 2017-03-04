//
//  service.h
//  PluginsDemo
//
//  Created by alisports on 2017/3/4.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 定义了一种服务，表示此时此刻 需要服务的名称，一个类中很可能有好几个不同值。使用“类名／服务名” 区别不同类中有相同的服务
 */
@interface service : NSObject<NSCopying>

- (instancetype)init:(NSString *)serviceType serviceName:(NSString *)serviceName serviceAction:(NSString *)serviceAction;

/**
 服务的名称
 */
@property(copy,nonatomic,readonly)NSString *serviceName;

/**
 服务的类型，例如http等，后期改为枚举类型
 */
@property(copy,nonatomic,readonly)NSString *serviceType;

/**
 服务的行为，例如resume开始，cancel取消等
 */
@property(copy,nonatomic,readonly)NSString *serviceAction;




@end
