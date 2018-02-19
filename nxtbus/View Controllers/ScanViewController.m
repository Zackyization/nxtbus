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

@interface ScanViewController ()

@end

@implementation ScanViewController
@synthesize cameraView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

# pragma mark - QRCodeReaderViewControllerDelegate Methods
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
    [reader stopScanning];
    [self dismissViewControllerAnimated:YES completion: nil];
    [self showAlertWithTitle:@"Success!" message:@"You have successfully scanned the QR Code"];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader {
    [reader stopScanning];
    [self dismissViewControllerAnimated:YES completion: nil];
}

@end
