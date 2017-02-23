//
//  VCService.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import "AlisRequestProtocol.h"
#import <Foundation/Foundation.h>

//VC 的service层
// 用户层指明自己遵守的协议<AlisRequestProtocol>，之后请求所需要的数据，参数都在用户层这里查找
// 网络请求成功的结果返回裸数据，用户层根据业务的不同做相应的处理
@interface VCService : NSObject<AlisRequestProtocol>

@property(strong, nonatomic)NSString *name;
@property(strong, nonatomic)NSString *age;
@property(strong, nonatomic)NSString *location;

- (void)askNetwork;
@end
