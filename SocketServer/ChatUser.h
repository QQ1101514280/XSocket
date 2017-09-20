//
//  ChatUser.h
//  Xscoket
//
//  Created by 刘庆 on 2017/9/18.
//  Copyright © 2017年 刘庆. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDAsyncSocket;

@interface ChatUser : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) GCDAsyncSocket *scoket;
@property (nonatomic, assign) BOOL isLogin;
-(instancetype)initWithName:(NSString *) name;
@end
