//
//  ViewController.m
//  QRCode-Demo
//
//  Created by yaowan on 16/7/5.
//  Copyright © 2016年 yaowan. All rights reserved.
//

#import "ViewController.h"
#import "ALQRCodeScanController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ALQRCodeScanController *scanVC = [ALQRCodeScanController new];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
