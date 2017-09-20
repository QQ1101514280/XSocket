//
//  MainViewController.m
//  Xscoket
//
//  Created by 刘庆 on 2017/9/16.
//  Copyright © 2017年 刘庆. All rights reserved.
//

#import "MainViewController.h"
#import "ServerViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)showServerVC:(id)sender {
    ServerViewController *svc = ServerViewController.shareServerViewController;
    if (!svc) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        svc = [storyBoard instantiateViewControllerWithIdentifier:@"ServerVC"];
    }
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];}

@end
