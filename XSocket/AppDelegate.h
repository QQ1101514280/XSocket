//
//  AppDelegate.h
//  XSocket
//
//  Created by 刘庆 on 2017/9/20.
//  Copyright © 2017年 刘庆. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GCDAsyncSocket;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GCDAsyncSocket *severtSocket;


@end

