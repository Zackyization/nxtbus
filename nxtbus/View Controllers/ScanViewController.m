//
//  ScanViewController.m
//  nxtbus
//
//  Created by Sean Nicholas on 19/2/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import "ScanViewController.h"
@import MasterpassQRScanSDK;
@import AVFoundation;

@interface ScanViewController () <QRCodeReaderDelegate>

@property (nonatomic, strong) QRCodeReaderViewController *qrVC;

@end

@implementation ScanViewController

AVCaptureSession *session;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    QRCodeReaderViewControllerBuilder *builder = [[QRCodeReaderViewControllerBuilder alloc] init];
    QRCodeReaderView *readerView = (QRCodeReaderView *)builder.readerView;
    
    // Setup overlay view
    QRCodeReaderViewOverlay *overlayView = (QRCodeReaderViewOverlay *)[readerView getOverlay];
    overlayView.cornerColor = UIColor.redColor;
    overlayView.cornerWidth = 6;
    overlayView.cornerLength = 75;
    overlayView.indicatorSize = CGSizeMake(250, 250);
    
    // Setup scanning region
    builder.scanRegionSize = CGSizeMake(250, 250);
    
    // Hide torch button provided by default view
    builder.showTorchButton = true;
    
    // Hide cancel button provided by default view
    builder.showCancelButton = false;
    
    // Don't start scanning when this view is loaded i.e initialized
    builder.startScanningAtLoad = false;
    
    builder.showSwitchCameraButton = false;
    
    self.qrVC = [[QRCodeReaderViewController alloc] initWithBuilder:builder];
    self.qrVC.delegate = self;
    
    // Add the reader as child view controller
    [self addChildViewController:self.qrVC];
    
    // Add reader view to the bottom
    [self.view insertSubview:self.qrVC.view atIndex:0];
    
    NSDictionary *dictionary = @{@"qrVC": self.qrVC.view};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[qrVC]|" options:0 metrics:nil views:dictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[qrVC]|" options:0 metrics:nil views:dictionary]];
    
    [self.qrVC didMoveToParentViewController:self];
                          
//    session = [[AVCaptureSession alloc]init];
//    [session setSessionPreset:AVCaptureSessionPresetPhoto];
//
//    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    NSError *error;
//    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
//
//    if ([session canAddInput:deviceInput]) {
//        [session addInput:deviceInput];
//    }
//
//    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
//    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
//    CALayer *rootLayer = [[self view] layer];
//    [rootLayer setMasksToBounds:YES];
//    CGRect frame = cameraView.frame;
//
//    [previewLayer setFrame:frame];
//
//    [rootLayer insertSublayer:previewLayer atIndex:0];
//
//    [session startRunning];
    // Do any additional setup after loading the view.
    /*
    if (![QRCodeReader isAvailable] || ![QRCodeReader supportsQRCode]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self checkCameraPermission: ^{
        
        __block __weak QRCodeReader* reader;
        QRCodeReaderViewController* qrVC = [QRCodeReaderViewController readerWithBuilderBlock:^(QRCodeReaderViewControllerBuilder *builder){
            reader = builder.reader;
        }];
        
        //block to read the result
        [reader setCompletionWithBlock:^(NSString *result) {
            [reader stopScanning];
            [self dismissViewControllerAnimated:YES completion: nil];
            [self showAlertWithTitle:@"Success!" message:@"You have successfully scanned the QR Code."];
        }];
        
        //block when cancel is pressed
        [qrVC setCompletionWithBlock:^(NSString *result) {
            [reader stopScanning];
            [self dismissViewControllerAnimated:YES completion: nil];
        }];
        
        // Retrieve the QRCode content via delegate
        qrVC.delegate = weakSelf;
        
        [weakSelf presentViewController:qrVC animated:true completion:nil];
    }];
    */
}

- (void)viewWillAppear:(BOOL)animated {
//    if (![QRCodeReader isAvailable] || ![QRCodeReader supportsQRCode]) {
//        return;
//    }
//    __weak typeof(self) weakSelf = self;
//    [self checkCameraPermission: ^{
//
//        __block __weak QRCodeReader* reader;
//        QRCodeReaderViewController* qrVC = [QRCodeReaderViewController readerWithBuilderBlock:^(QRCodeReaderViewControllerBuilder *builder){
//            reader = builder.reader;
//        }];
//
//        //block to read the result
//        [reader setCompletionWithBlock:^(NSString *result) {
//            [reader stopScanning];
//            [self dismissViewControllerAnimated:YES completion: nil];
//            [self showAlertWithTitle:@"Success!" message:@"You have successfully scanned the QR Code."];
//        }];
//
//        //block when cancel is pressed
//        [qrVC setCompletionWithBlock:^(NSString *result) {
//            [reader stopScanning];
//            [self dismissViewControllerAnimated:YES completion: nil];
//        }];
//
//        // Retrieve the QRCode content via delegate
//        qrVC.delegate = weakSelf;
//
//        [weakSelf presentViewController:qrVC animated:true completion:nil];
//    }];
    /*
    session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = self.cameraView.frame;
    
    [previewLayer setFrame:frame];
    
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    [session startRunning];
    */
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.qrVC startScanning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.qrVC stopScanning];
    [self showAlertWithTitle:@"Success!" message:@"You have successfully scanned the QR Code"];
}

#pragma mark - Actions
- (IBAction)torchButtonPressed:(id)sender {
    [self.qrVC.codeReader toggleTorch];
}

#pragma mark - QRCodeReaderViewControllerDelegate methods
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
    [reader stopScanning];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader {
    [reader stopScanning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanAction:(id)sender {
    
}

// Check camera permissions
- (void)checkCameraPermission:(void (^)(void))completion {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied) {
        [self showAlertWithTitle:@"Error" message: @"Camera permissions are required for scanning QR. Please turn on Settings -> MasterpassQR Demo -> Camera"];
        return;
    } else if (status == AVAuthorizationStatusRestricted) {
        [self showAlertWithTitle:@"Error" message: @"Camera permissions are restricted for scanning QR"];
        return;
    } else if (status == AVAuthorizationStatusAuthorized) {
        completion();
    } else if (status == AVAuthorizationStatusNotDetermined) {
        __weak __typeof(self) weakSelf = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    completion();
                } else {
                    [weakSelf showAlertWithTitle:@"Error" message: @"Camera permissions are required for scanning QR. Please turn on Settings -> MasterpassQR Demo -> Camera"];
                }
            });
        }];
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:true completion:nil];
}

//# pragma mark - QRCodeReaderViewControllerDelegate Methods
//- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
//    [reader stopScanning];
//    [self dismissViewControllerAnimated:YES completion: nil];
//    [self showAlertWithTitle:@"Success!" message:@"You have successfully scanned the QR Code"];
//}
//
//- (void)readerDidCancel:(QRCodeReaderViewController *)reader {
//    [reader stopScanning];
//    [self dismissViewControllerAnimated:YES completion: nil];
//}

@end
