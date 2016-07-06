//
//  MyScanController.m
//  QRCode-Demo
//
//  Created by yaowan on 16/7/6.
//  Copyright © 2016年 yaowan. All rights reserved.
//

#import "MyScanController.h"

@implementation MyScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.conertTintColor = [UIColor colorWithRed:8/255.0 green:184/255.0 blue:247/255.0 alpha:1];
    self.tipMessage = @"扫描二维码";
    self.title = @"二维码";
}

- (void)solveCaptureMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self reset];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
