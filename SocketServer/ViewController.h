//
//  ViewController.h
//  SocketServer
//
//  Created by 刘庆 on 2017/9/18.
//  Copyright © 2017年 刘庆. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"
@class ChatUser;

@interface ViewController : NSViewController<GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
@property (nonatomic, strong) NSMutableArray *clientSocketArray,*clientAllowArray;
@property (nonatomic, strong) NSArray<ChatUser *> *chatUserArray;
@property (nonatomic, strong) NSMutableString *logStr;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;


@end

