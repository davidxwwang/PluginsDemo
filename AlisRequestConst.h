//
//  AliRequestConst.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/23.
//  Copyright © 2017年 alisports. All rights reserved.
//

#ifndef AlisRequestConst_h
#define AlisRequestConst_h
#import <Foundation/Foundation.h>

@class AlisRequest,AlisChainRequestmanager,AlisRequestManager;
/**
 网络状况
 */
typedef NS_ENUM(NSInteger, AlisNetworkReachabilityStatus) {
    AlisNetworkReachabilityStatusUnknown          = -1,
    AlisNetworkReachabilityStatusNotReachable     = 0,
    AlisNetworkReachabilityStatusReachableViaWWAN = 1,
    AlisNetworkReachabilityStatusReachableViaWiFi = 2,
};
/**
 请求类型
 */
typedef NS_ENUM(NSInteger, AlisRequestType) {
    AlisRequestNormal    = 0,    //!< Normal HTTP request type, such as GET, POST, ...
    AlisRequestUpload    = 1,    //!< Upload request type
    AlisRequestDownload  = 2,    //!< Download request type
};

/**
 请求方法
 */
typedef NS_ENUM(NSInteger, AlisHTTPMethodType) {
    AlisHTTPMethodGET    = 0,    //!< GET
    AlisHTTPMethodPOST   = 1,    //!< POST
    AlisHTTPMethodHEAD   = 2,    //!< HEAD
    AlisHTTPMethodDELETE = 3,    //!< DELETE
    AlisHTTPMethodPUT    = 4,    //!< PUT
    AlisHTTPMethodPATCH  = 5,    //!< PATCH
};

typedef void(^AlisRequestConfigBlock)( AlisRequest *_Nonnull request);

typedef void (^AlisChainNextRBlock)(AlisRequest *_Nonnull request, id _Nullable responseObject, NSError * error);

typedef void (^AlisChainRConfigBlock)( AlisChainRequestmanager * _Nonnull request);

typedef void(^AlisChainRSucessBlock)(NSArray * _Nonnull responseArray);
typedef void(^AlisChainRFailBlock)(id _Nonnull data);
typedef void(^AlisChainRFinishedBlock)(id _Nonnull data);


#endif /* AliRequestConst_h */
