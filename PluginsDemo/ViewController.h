//
//  ViewController.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<AlisRequestProtocol>

@property(copy,nonatomic)NSString *currentRequest;

@end

