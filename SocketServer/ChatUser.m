//
//  ChatUser.m
//  Xscoket
//
//  Created by 刘庆 on 2017/9/18.
//  Copyright © 2017年 刘庆. All rights reserved.
//

#import "ChatUser.h"

@implementation ChatUser
-(instancetype)initWithName:(NSString *)name{
    self = [super init];
    if (self) {
        self.name = name;
    }
    return self;
}
@end
