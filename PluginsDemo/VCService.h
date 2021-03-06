//
//  VCService.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import "AlisRequestProtocol.h"
#import <Foundation/Foundation.h>

#define resumeService(yy) ([self performSelector:NSSelectorFromString([@"resume_"  stringByAppendingFormat:@"%@", yy])])
#define cancelService(yy) ([self performSelector:NSSelectorFromString([@"cancel_"  stringByAppendingFormat:@"%@", yy])])
#define suspendService(yy) ([self performSelector:NSSelectorFromString([@"suspend_"  stringByAppendingFormat:@"%@", yy])])
#define ServiceIs(yy,xx) ([yy isEqualToString:xx])

// VC 的service层
// 用户层指明自己遵守的协议<AlisRequestProtocol>，之后请求所需要的数据，参数都在用户层这里查找
// 网络请求成功的结果返回裸数据，用户层根据业务的不同做相应的处理
// 发出资源请求的很有可能不是VCService或其子类，有可能是其他OC对象转发给VCService的，这个需要注意
// 支持消息转发和消息继承
@protocol VCServiceProtocol <NSObject>

/**
 对对象注册服务

 @param object object description
 */
- (void)injectService:(id<AlisRequestProtocol>)object;

@end

@interface VCService : NSObject<AlisRequestProtocol,VCServiceProtocol>

+ (VCService *)shareManager;
    
@property(copy,nonatomic)NSString *currentServiceName;
    
@end
