//
//  ServerViewController.m
//  Xscoket
//
//  Created by 刘庆 on 2017/9/16.
//  Copyright © 2017年 刘庆. All rights reserved.
//

#import "ServerViewController.h"
#import "GCDAsyncSocket.h"

@interface ServerViewController ()<GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *protTextF;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (nonatomic, strong) NSMutableString *logStr;
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
@property (nonatomic, strong) NSMutableArray *clientSocketArray;
@end

@implementation ServerViewController

-(NSMutableArray *)clientSocketArray
{
    if (!_clientSocketArray) {
        _clientSocketArray = [NSMutableArray array];
    }
    return _clientSocketArray;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    _logStr = @"".mutableCopy;
}

- (IBAction)clickStartButton:(UIButton *)sender {
    [self startListener];
}

-(void)showLog{
    dispatch_async(dispatch_get_main_queue(), ^{
        _logTextView.text = _logStr;
    });
}

#pragma mark - 开启服务端监听
-(void) startListener
{
    GCDAsyncSocket *serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    NSError *error = nil;
    [serverSocket acceptOnPort:[_protTextF.text intValue] error:&error];
    NSString *log;
    if (!error) {
        log = @"服务器启动成功\n";
    } else {
        log = @"服务端开启失败\n";
    }
    [_logStr appendString:log];
    [self showLog];
    
    self.serverSocket = serverSocket;
}



#pragma mark -  有客户端链接
-(void)socket:(GCDAsyncSocket *)serverceSocket didAcceptNewSocket:(GCDAsyncSocket *)clientSocket
{
    
}

#pragma mark - 读取客户端发送的数据
-(void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag
{
}

@end
