//
//  ViewController.m
//  SocketServer
//
//  Created by 刘庆 on 2017/9/18.
//  Copyright © 2017年 刘庆. All rights reserved.
//

#import "ViewController.h"
#import "ChatUser.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clientSocketArray = @[].mutableCopy;
    _logStr = @"".mutableCopy;
    _chatUserArray = @[
                       [[ChatUser alloc] initWithName:@"1001"],
                       [[ChatUser alloc] initWithName:@"1002"],
                       [[ChatUser alloc] initWithName:@"1003"],
                       [[ChatUser alloc] initWithName:@"1004"],
                       ];
    [self startListener];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

// 开启监听 监听端口 8888
-(void) startListener
{
    GCDAsyncSocket *serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    NSError *error = nil;
    [serverSocket acceptOnPort:8888 error:&error];
    NSString *log;
    if (!error) {
        log = @"服务器启动成功\n";
        NSLog(@"服务器启动成功");
    } else {
        log = @"服务端开启失败\n";
        NSLog(@"服务端开启失败");
    }
    [_logTextView insertText:log];
    self.serverSocket = serverSocket;
}

#pragma mark -  有客户端链接
-(void)socket:(GCDAsyncSocket *)serverceSocket didAcceptNewSocket:(GCDAsyncSocket *)clientSocket
{
    NSString * log = [NSString stringWithFormat:@"有客服端连接服务器 ip:%@\n",clientSocket.connectedHost];
    
    [self.clientSocketArray addObject:clientSocket];//将客户端的socket保存到数组,这样才能保证newSocket持续存在
    [self.clientAllowArray addObject:@"0"];
    //当客户端一连接成功就发送数据给它
    NSString *serverceStr = @"欢迎来到聊天室";
    
    //向客户端socket发送数据
    [clientSocket writeData:[serverceStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    
    //监听客户端发送数据
    [clientSocket readDataWithTimeout:-1 tag:0];
    NSLog(@"当前有%ld客户端链接到服务器",self.clientSocketArray.count);
    [_logStr appendString:log];
    
}

#pragma mark - 读取客户端请求的数据
//接收消息
-(void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSInteger mode = [dict[@"messageMode"] integerValue];
    switch (mode) {
        case 0:     //login
            for (int i = 0; i < _chatUserArray.count; i++) {
                if ([dict[@"name"] isEqualToString:_chatUserArray[i].name] && [dict[@"pwd"]isEqualToString: _chatUserArray[i].name]) {
                    if (_chatUserArray[i].isLogin) {
                        [clientSocket writeData:[@"该用户已登录" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                        [clientSocket readDataWithTimeout:-1 tag:0];
                    }else {
                        for (int i = 0; i < _chatUserArray.count; i++) {
                            if (_chatUserArray[i].isLogin) {
                                [_chatUserArray[i].scoket writeData:[[NSString stringWithFormat:@"%@:加入聊天室",dict[@"name"]] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                                [clientSocket readDataWithTimeout:-1 tag:0];
                            }
                        }
                        [clientSocket writeData:[@"登陆成功" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                        [clientSocket readDataWithTimeout:-1 tag:0];
                        _chatUserArray[i].isLogin = YES;
                        _chatUserArray[i].scoket = clientSocket;
                        _clientAllowArray[[_clientSocketArray indexOfObject:clientSocket]] = @"1";
                        
                    }
                }
            }
            break;
        case 1:     //messageALL
            if ([_clientAllowArray[[_clientSocketArray indexOfObject:clientSocket]] isEqualToString:@"0"]) {
                [clientSocket writeData:[@"当前未登录" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                [clientSocket readDataWithTimeout:-1 tag:0];
            }else {
                int x = -1;
                for (int i = 0; i < _chatUserArray.count; i++) {
                    if (_chatUserArray[i].scoket == clientSocket) x = i;
                }
                for (int i = 0; i < _chatUserArray.count; i++) {
                    if (_chatUserArray[i].isLogin) {
                        if (x == i) {
                            [_chatUserArray[i].scoket writeData:[[NSString stringWithFormat:@"%@:%@",@"我",dict[@"message"]] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                            [clientSocket readDataWithTimeout:-1 tag:0];
                        }else {
                            [_chatUserArray[i].scoket writeData:[[NSString stringWithFormat:@"%@:%@",_chatUserArray[x].name,dict[@"message"]] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                            [clientSocket readDataWithTimeout:-1 tag:0];
                        }
                    }
                }
            }
            break;
        default:
            break;
    }
}

//断开链接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    int x = -1;
    for (int i = 0; i < _chatUserArray.count; i++) {
        if (_chatUserArray[i].scoket == sock) {
            x = i;
            [sock writeData:[@"退出成功" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            _chatUserArray[i].isLogin = NO;
            _chatUserArray[i].scoket = nil;
        }
    }
    for (int i = 0; i < _chatUserArray.count; i++) {
        if (_chatUserArray[i].isLogin) {
            if (x >-1 && x != i) {
                [_chatUserArray[i].scoket writeData:[[NSString stringWithFormat:@"%@ 退出聊天室",_chatUserArray[x].name] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                [_chatUserArray[i].scoket readDataWithTimeout:-1 tag:0];
            }
        }
    }
}
@end
