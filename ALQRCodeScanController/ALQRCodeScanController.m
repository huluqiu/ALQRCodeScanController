//
//  ALQRCodeScanController.m
//  QRCode-Demo
//
//  Created by yaowan on 16/7/5.
//  Copyright © 2016年 yaowan. All rights reserved.
//

#import "ALQRCodeScanController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

static const CGFloat kMargin = 30;
static const NSInteger kTag = 614;

@interface ALQRCodeScanController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) UIView *scanView;
@property (nonatomic, strong) UIImageView *scannetView;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, assign) BOOL flash;
@property (nonatomic, assign) BOOL captured;

@end

@implementation ALQRCodeScanController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationBarHidden = self.navigationController.navigationBar.hidden;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self reset];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:self.navigationBarHidden animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startAnimation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view.layer addSublayer:self.previewLayer];
    [self.view.layer addSublayer:self.maskLayer];
    [self.view addSubview:self.navView];
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.tipLabel];
    [self.session startRunning];
}

#pragma mark - Action
- (void)solveCaptureMessage:(NSString *)message {
    
}

- (void)flashflash {
    AVCaptureDeviceInput *input = self.session.inputs.firstObject;
    AVCaptureDevice *device = input.device;
    if ([device hasTorch] && [device hasFlash]){
        
        [device lockForConfiguration:nil];
        if (!self.flash) {
            self.flash = YES;
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setFlashMode:AVCaptureFlashModeOn];
            
        } else {
            self.flash = NO;
            [device setTorchMode:AVCaptureTorchModeOff];
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    }
}

- (void)chooseQRCodeFromAlbum {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusNotDetermined) {
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"应用不支持访问相册,请到设置->隐私->照片中设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
        }];
        [alert addAction:okAction];
        [alert addAction:setAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)startAnimation {
    CAAnimation *anim = [self.scannetView.layer animationForKey:@"translationAnimation"];
    if(anim){
        CFTimeInterval pauseTime = self.scannetView.layer.timeOffset;
        CFTimeInterval beginTime = CACurrentMediaTime() - pauseTime;
        [self.scannetView.layer setTimeOffset:0.0];
        [self.scannetView.layer setBeginTime:beginTime];
        [self.scannetView.layer setSpeed:1.0];
        
    }else{
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @(CGRectGetHeight(self.scanView.bounds));
        scanNetAnimation.duration = 2.0;
        scanNetAnimation.repeatCount = MAXFLOAT;
        [self.scannetView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
    }
}

- (void)doBack:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doMore:(UIButton *)button {
    NSString *flashTitle = self.flash ? @"关闭闪光灯" : @"打开闪光灯";
    UIAlertAction *flashAction = [UIAlertAction actionWithTitle:flashTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self flashflash];
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册选取二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self chooseQRCodeFromAlbum];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:flashAction];
    [alert addAction:albumAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)reset {
    self.captured = NO;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (self.captured) {
        return;
    }
    if (metadataObjects.count > 0) {
        self.captured = YES;
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        [self solveCaptureMessage:metadataObject.stringValue];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *chooseImage = info[UIImagePickerControllerOriginalImage];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh }];
        CIImage *image = [CIImage imageWithCGImage:chooseImage.CGImage];
        NSArray *features = [detector featuresInImage:image];
        if (features.count > 0) {
            CIQRCodeFeature *feature = features.firstObject;
            [self solveCaptureMessage:feature.messageString];
        }else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"该图片没有包含一个二维码" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

#pragma mark - Getters and Setters
- (AVCaptureSession *)session {
    if (!_session) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        if (!input) { return nil;}
        AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        output.rectOfInterest = CGRectMake(self.scanView.frame.origin.y / self.view.frame.size.height, self.scanView.frame.origin.x / self.view.frame.size.width, self.scanView.frame.size.height / self.view.frame.size.height, self.scanView.frame.size.width / self.view.frame.size.width);
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
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) * 0.2, 0, CGRectGetWidth(self.view.bounds) * 0.6, 44)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = self.title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.tag = kTag;
        [_navView addSubview:titleLabel];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        backButton.tintColor = [UIColor whiteColor];
        backButton.titleLabel.font = [UIFont systemFontOfSize:30];
        backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [backButton setTitle:[NSString stringWithFormat:@"%C", 0x003C] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
        backButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) * 0.2, 44);
        [backButton setContentMode:UIViewContentModeCenter];
        [_navView addSubview:backButton];
        
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
        moreButton.tintColor = [UIColor whiteColor];
        [moreButton setTitle:@"···" forState:UIControlStateNormal];
        moreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        moreButton.titleLabel.font = [UIFont systemFontOfSize:30];
        [moreButton addTarget:self action:@selector(doMore:) forControlEvents:UIControlEventTouchUpInside];
        moreButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds) * 0.8, 0, CGRectGetWidth(self.view.bounds) * 0.2, 44);
        [moreButton setContentMode:UIViewContentModeCenter];
        [_navView addSubview:moreButton];
    }
    return _navView;
}

- (UIView *)scanView {
    if (!_scanView) {
        CGFloat width = CGRectGetWidth(self.view.bounds) - 2 * kMargin;
        _scanView = [[UIView alloc] initWithFrame:CGRectMake(kMargin, CGRectGetMaxY(self.navView.bounds) + 60, width, width)];
        _scanView.clipsToBounds = YES;
        
        self.scannetView.frame = CGRectMake(0, -width, width, width);
        [_scanView addSubview:self.scannetView];
        
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[ALQRCodeScanController class]] pathForResource:@"ALQRCodeScanController" ofType:@"bundle"]];
        UIImageView *topleftCorner = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:[bundle pathForResource:@"scan_1@2x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        UIImageView *toprightCorner = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:[bundle pathForResource:@"scan_2@2x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        UIImageView *bottomleftCorner = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:[bundle pathForResource:@"scan_3@2x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        UIImageView *bottomrightCorner = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:[bundle pathForResource:@"scan_4@2x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        topleftCorner.tag = kTag + 1;
        toprightCorner.tag = kTag + 2;
        bottomleftCorner.tag = kTag + 3;
        bottomrightCorner.tag = kTag + 4;
        topleftCorner.tintColor = self.conertTintColor;
        toprightCorner.tintColor = self.conertTintColor;
        bottomleftCorner.tintColor = self.conertTintColor;
        bottomrightCorner.tintColor = self.conertTintColor;
        CGFloat cornerWidth = 19;
        topleftCorner.frame = CGRectMake(0, 0, cornerWidth, cornerWidth);
        toprightCorner.frame = CGRectMake(width - cornerWidth, 0, cornerWidth, cornerWidth);
        bottomleftCorner.frame = CGRectMake(0, width - cornerWidth, cornerWidth, cornerWidth);
        bottomrightCorner.frame = CGRectMake(width - cornerWidth, width - cornerWidth, cornerWidth, cornerWidth);
        [_scanView addSubview:topleftCorner];
        [_scanView addSubview:toprightCorner];
        [_scanView addSubview:bottomleftCorner];
        [_scanView addSubview:bottomrightCorner];
    }
    return _scanView;
}

- (UIImageView *)scannetView {
    if (!_scannetView) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[ALQRCodeScanController class]] pathForResource:@"ALQRCodeScanController" ofType:@"bundle"]];
        _scannetView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[bundle pathForResource:@"scan_net@2x" ofType:@"png"]]];
        _scannetView.contentMode = UIViewContentModeScaleToFill;
    }
    return _scannetView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMargin, CGRectGetMaxY(self.scanView.frame) + 30, CGRectGetWidth(self.scanView.frame), 20)];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.text = self.tipMessage;
    }
    return _tipLabel;
}

- (void)setConertTintColor:(UIColor *)conertTintColor {
    _conertTintColor = conertTintColor;
    UIImageView *imageView = [self.scanView viewWithTag:kTag + 1];
    imageView.tintColor = _conertTintColor;
    imageView = [self.scanView viewWithTag:kTag + 2];
    imageView.tintColor = _conertTintColor;
    imageView = [self.scanView viewWithTag:kTag + 3];
    imageView.tintColor = _conertTintColor;
    imageView = [self.scanView viewWithTag:kTag + 4];
    imageView.tintColor = _conertTintColor;
}

- (void)setTipMessage:(NSString *)tipMessage {
    _tipMessage = tipMessage;
    self.tipLabel.text = _tipMessage;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    UILabel *label = [self.navView viewWithTag:kTag];
    label.text = title;
}

@end
