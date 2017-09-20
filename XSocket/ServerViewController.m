//
//  ServerViewController.m
//  Xscoket
//
//  Created by 刘庆 on 2017/9/16.
//  Copyright © 2017年 刘庆. All rights reserved.
//

#import "ServerViewController.h"
#import "GCDAsyncSocket.h"
#import "AppDelegate.h"
#import "ChatUser.h"

static ServerViewController *_shareServerViewController;

@interface ServerViewController ()<GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITextField *protTextF;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (nonatomic, strong) NSArray<ChatUser *> *chatUserArray;
@property (nonatomic, strong) NSMutableString *logStr;
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
@property (nonatomic, strong) NSMutableArray *clientSocketArray,*clientAllowArray;

@end

@implementation ServerViewController

//设置类属性
+(ServerViewController *)shareServerViewController {
    return _shareServerViewController;
}
+(void)setShareServerViewController:(ServerViewController *)shareServerViewController {
    _shareServerViewController = shareServerViewController;
}

-(NSMutableArray *)clientSocketArray
{
    if (!_clientSocketArray) {
        _clientSocketArray = [NSMutableArray array];
    }
    return _clientSocketArray;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.clientSocketArray = @[].mutableCopy;
    self.clientAllowArray = @[].mutableCopy;
    self.clientAllowArray = @[].mutableCopy;
    _logStr = @"".mutableCopy;
    _chatUserArray = @[
                       [[ChatUser alloc] initWithName:@"1001"],
                       [[ChatUser alloc] initWithName:@"1002"],
                       [[ChatUser alloc] initWithName:@"1003"],
                       [[ChatUser alloc] initWithName:@"1004"],
                       ];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ServerViewController.shareServerViewController = nil;
}
- (IBAction)clickStartButton:(UIButton *)sender {
    if (sender.tag == 99) {
        [self startListener];
        _startButton.userInteractionEnabled = NO;
    }else {
        [self stopListener];
        _startButton.userInteractionEnabled = NO;
    }
}

- (IBAction)hiddenServer:(id)sender {
    ServerViewController.shareServerViewController = self;
    [self.navigationController popViewControllerAnimated:YES];
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
        _startButton.userInteractionEnabled = YES;
        [_startButton setTitle:@"停止服务器" forState:UIControlStateNormal];
    } else {
        log = @"服务端开启失败\n";
        _startButton.userInteractionEnabled = YES;
    }
    [_logStr appendString:log];
    [self showLog];
    self.serverSocket = serverSocket;
    
}

#pragma mark - 开启服务端监听
-(void) stopListener
{
    [self.serverSocket disconnect];
    self.serverSocket = nil;
    [_logStr appendString:@"服务器停止成功"];
}

#pragma mark -  有客户端链接
-(void)socket:(GCDAsyncSocket *)serverceSocket didAcceptNewSocket:(GCDAsyncSocket *)clientSocket
{
    NSString * log = [NSString stringWithFormat:@"有客服端连接服务器 ip:%@\n",clientSocket.connectedHost];
    
    [self.clientSocketArray addObject:clientSocket];//将客户端的socket保存到数组,这样才能保证newSocket持续存在
    
    [self.clientAllowArray addObject:@"0"];//当客户端一连接成功就发送数据给它
    
    NSString *serverceStr = @"欢迎来到聊天室";
    
    //向客户端socket发送数据
    [clientSocket writeData:[serverceStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [clientSocket readDataWithTimeout:-1 tag:0];
    
    NSLog(@"当前有%ld客户端链接到服务器",self.clientSocketArray.count);
    [_logStr appendString:log];

}

#pragma mark - 读取客户端发送的数据
-(void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag
{
    @synchronized (self) {
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
