//
//  AliRequestConst.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/23.
//  Copyright © 2017年 alisports. All rights reserved.
//

#ifndef AlisRequestConst_h
#define AlisRequestConst_h
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


#endif /* AliRequestConst_h */
