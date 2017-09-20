//
//  ViewController.m
//  Xscoket
//
//  Created by 刘庆 on 2017/7/10.
//  Copyright © 2017年 刘庆. All rights reserved.
//

#import "ChatViewController.h"

#import "GCDAsyncSocket.h"

@interface ChatViewController ()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_mysoket;
    NSMutableString *_logStr;
}
@property (nonatomic, strong) NSMutableArray<NSString *> *chatListArray;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UITextField *hostTextField;
@property (weak, nonatomic) IBOutlet UITextField *proTextField;
@property (weak, nonatomic) IBOutlet UITextField *sendText;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextF;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mysoket disconnect];
}
-(void)initAll{
    _mysoket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    _chatListArray = @[].mutableCopy;
    _logStr = @"".mutableCopy;
}

-(void)showLog{
    dispatch_async(dispatch_get_main_queue(), ^{
        _logTextView.text = _logStr;
    });
}
-(void)connectToHost {
    [_mysoket connectToHost:_hostTextField.text onPort:[_proTextField.text intValue] error:nil];
    [_mysoket readDataWithTimeout:-1 tag:999];
}
- (IBAction)sendInfo:(id)sender {
    if (!_mysoket.isConnected) {
        [self connectToHost];
    }
    NSString *str = [NSString stringWithFormat:@"{\"messageMode\":\"1\",\"message\":\"%@\"}",_sendText.text];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [_mysoket writeData:data withTimeout:8 tag:666];
    [_mysoket readDataWithTimeout:8 tag:666];
}
- (IBAction)login:(id)sender {
    [self connectToHost];
    _loginButton.userInteractionEnabled = NO;
    if (_loginButton.tag == 10) {
        NSString *str = [NSString stringWithFormat:@"{\"messageMode\":\"0\",\"name\":\"%@\",\"pwd\":\"%@\"}",_nameTextF.text,_pwdTextF.text];
        [_mysoket writeData:[str  dataUsingEncoding:NSUTF8StringEncoding] withTimeout:8 tag:888];
        [_mysoket readDataWithTimeout:8 tag:888];
    }
    else {
        [_mysoket disconnect];
    }
    
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"did connect to host Host:%@ Port:%u",host,port);
    [_logStr appendString:@"链接成功\n"];
    [self showLog];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"读取数据");
    NSString* message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    switch (tag) {
        case 888://登录请求
            if([message isEqualToString:@"登陆成功"]) {
                [_loginButton setTitle:@"退出" forState:UIControlStateNormal];
                _loginButton.tag = 11;
            }
            _loginButton.userInteractionEnabled = YES;
            break;
            
        default:
            break;
    }
    [_logStr appendString:[NSString stringWithFormat:@"%@\n",message]];
    [self showLog];
    [_mysoket readDataWithTimeout:-1 tag:tag];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [sock readDataWithTimeout:-1 tag:tag];
}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"链接断开");
    [_logStr appendString:@"退出成功\n"];
    [self showLog];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    _loginButton.tag = 10;
    _loginButton.userInteractionEnabled = YES;
}



@end
