//
//  ScanViewController.m
//  PDBotDemo
//
//  Created by wuyifan on 2018/2/22.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureSession* captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) UIView* scanRectView;

@end


@implementation ScanViewController

- (void)dealloc
{
    [self stopScanning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if TARGET_OS_SIMULATOR
    self.view.backgroundColor = [UIColor blackColor];
#else
    [self startScanning];
#endif
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(16, 16, 64, 44)];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelScan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.scanRectView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-128, self.view.frame.size.height/2-128, 256, 256)];
    self.scanRectView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.scanRectView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.25f];
    [self.view addSubview:self.scanRectView];
}

- (void)startScanning
{
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // add input
    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput* deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    [self.captureSession addInput:deviceInput];
    
    // add output
    AVCaptureMetadataOutput* metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:metadataOutput];
    
    // configure output
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // configure previewLayer
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.previewLayer setFrame:self.view.bounds];
    [self.view.layer addSublayer:self.previewLayer];
    
    // start scanning
    [self.captureSession startRunning];
}

- (void)stopScanning
{
    [self.captureSession stopRunning];
    self.captureSession = nil;
    
    [self.previewLayer removeFromSuperlayer];
}

- (void)cancelScan
{
    [self.delegate scanViewController:self captureResult:nil];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && metadataObjects.count > 0)
    {
        AVMetadataMachineReadableCodeObject* metadataObject = metadataObjects.firstObject;
        if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [self stopScanning];
            [self.delegate scanViewController:self captureResult:metadataObject.stringValue];
        }
    }
}

@end
