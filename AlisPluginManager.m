//
//  AlisPluginManager.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/26.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisPluginManager.h"

@interface AlisPluginManager ()

//提供服务的plugin
@property(strong,nonatomic)NSMutableDictionary *pluginsServiceDictionary;

//real plugin
@property(strong,nonatomic)NSMutableDictionary *pluginsDictionary;

@end

@implementation AlisPluginManager

+ (AlisPluginManager *)manager{
    static id _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    
    return _manager;
}

- (instancetype)init{
    if (self = [super init]) {
        self.pluginsServiceDictionary = [NSMutableDictionary dictionary];
        self.pluginsDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark -- plugin
- (void)registerPlugin:(id<AlisPluginProtocol>)plugin key:(NSString *)key
{
}

- (void)registerPlugin:(NSString *)key
{
}

- (void)removePlugin:(NSString *)key{
    NSParameterAssert(key);
     //[self.pluginsDictionary removeObjectForKey:pluginList];
}

- (void)registerALLPlugins{
    NSString *plistPath = @"/Users/david/Desktop/FrameWorkDavid/PluginsDemo/PluginsDemo/plugins.plist";//[[NSBundle mainBundle] pathForResource:@"plugin" ofType:@"plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        return;
    }
    
    NSDictionary *pluginList = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    [self.pluginsServiceDictionary addEntriesFromDictionary:pluginList];
    
}

- (id<AlisPluginProtocol>)plugin:(NSString *)key{
    NSAssert(key, @"key should not nil");
    NSAssert(self.pluginsDictionary  || self.pluginsDictionary.count > 0, @"pluginsDictionary has problems");
    //这里应该判断是否有重复的key
    NSArray *keys = self.pluginsDictionary.allKeys;
    
    if ([keys containsObject:key]) {
        if (self.pluginsDictionary[key]) {
            return self.pluginsDictionary[key];
        }
    }
    else{
        NSArray *keys = self.pluginsServiceDictionary.allKeys;
        if (![keys containsObject:key]) {
            return nil;
        }
        
        NSString *pluginString = self.pluginsServiceDictionary[key];
        Class class = NSClassFromString(pluginString);
        id _object = [[class alloc] init];
        
        NSAssert([_object conformsToProtocol:@protocol(AlisPluginProtocol)], @"the plugin do not conform 'AlisPluginProtocol'");
        [self.pluginsDictionary setObject:_object forKey:key];

        return _object;
    }
   
    return nil;
}

@end
