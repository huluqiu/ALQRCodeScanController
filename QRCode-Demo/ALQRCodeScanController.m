//
//  ALQRCodeScanController.m
//  QRCode-Demo
//
//  Created by yaowan on 16/7/5.
//  Copyright © 2016年 yaowan. All rights reserved.
//

#import "ALQRCodeScanController.h"
#import <AVFoundation/AVFoundation.h>

static const CGFloat kMargin = 30;

@interface ALQRCodeScanController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) UIView *scanView;
@property (nonatomic, strong) UIImageView *scannetView;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) BOOL navigationBarHidden;

@end

@implementation ALQRCodeScanController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationBarHidden = self.navigationController.navigationBar.hidden;
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = self.navigationBarHidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view.layer addSublayer:self.previewLayer];
    [self.view.layer addSublayer:self.maskLayer];
    [self.view addSubview:self.navView];
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.tipLabel];
    [self.session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        NSLog(@"%@", metadataObject.stringValue);
    }
}

#pragma mark - Getters
- (AVCaptureSession *)session {
    if (!_session) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        if (!input) { return nil;}
        AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        output.rectOfInterest = self.scanView.frame;
        _session = [AVCaptureSession new];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        [_session addInput:input];
        [_session addOutput:output];
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = self.view.frame;
    }
    return _previewLayer;
}

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
        [overlayPath setUsesEvenOddFillRule:YES];
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:self.scanView.frame];
        [overlayPath appendPath:rectPath];
        _maskLayer.path = overlayPath.CGPath;
        _maskLayer.fillRule = kCAFillRuleEvenOdd;
        _maskLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    }
    return _maskLayer;
}

- (UIView *)navView {
    if (!_navView) {
        _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), 44)];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) * 0.125, 0, CGRectGetWidth(self.view.bounds) * 0.75, 44)];
        titleLabel.text = @"二维码";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_navView addSubview:titleLabel];
    }
    return _navView;
}

- (UIView *)scanView {
    if (!_scanView) {
        CGFloat width = CGRectGetWidth(self.view.bounds) - 2 * kMargin;
        _scanView = [[UIView alloc] initWithFrame:CGRectMake(kMargin, CGRectGetMaxY(self.navView.bounds) + 40, width, width)];
        self.scannetView.frame = CGRectMake(0, -width, width, width);
        [_scanView addSubview:self.scannetView];
    }
    return _scanView;
}

- (UIImageView *)scannetView {
    if (!_scannetView) {
        _scannetView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        _scannetView.contentMode = UIViewContentModeScaleToFill;
    }
    return _scannetView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
    }
    return _tipLabel;
}

@end
