//
//  ALQRCodeScanController.h
//  QRCode-Demo
//
//  Created by yaowan on 16/7/5.
//  Copyright © 2016年 yaowan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALQRCodeScanController : UIViewController

//
//  init follow property before viewDidLoad(), in init() is good
//
@property (nonatomic, copy) NSString *tipMessage;   // default is nil

@property (nonatomic, strong) UIColor *conertTintColor; // default is #08B8F7

/**
 *  overide this method to solve capture message, this is an empty method
 *  must call reset() after
*/
- (void)solveCaptureMessage:(NSString *)message;

- (void)flashflash; // i dont know how to name it - -

- (void)chooseQRCodeFromAlbum;

- (void)doMore:(UIButton *)button;  // default action is album, flash

- (void)reset;

@end
