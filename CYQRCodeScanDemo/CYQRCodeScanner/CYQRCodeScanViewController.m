//
//  CYQRCodeScanViewController.m
//  CYQRCodeScanDemo
//
//  Created by DeepAI on 2017/10/16.
//  Copyright © 2017年 DeepAI. All rights reserved.
//

#import "CYQRCodeScanViewController.h"
#import "CYQRCodeScanContentView.h"

@interface CYQRCodeScanViewController ()<CYQRCodeScanContentViewDelegate>

@property (nonatomic,strong) CYQRCodeScanManager *scanManager;

@property (nonatomic,strong) CYQRCodeScanContentView *contentView;

@property (nonatomic,assign) CGRect scanRect;

@end

@implementation CYQRCodeScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.navigationController setNavigationBarHidden:YES];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"扫码二维码";
    
    // default configuration
    
    CGFloat scanAreaWH = self.view.bounds.size.width * 0.7;
    CGFloat scanAreaX = (self.view.bounds.size.width - scanAreaWH) / 2;
    CGFloat scanAreaY = (self.view.bounds.size.height - scanAreaWH) / 2;
    self.scanRect = CGRectMake(scanAreaX, scanAreaY, scanAreaWH, scanAreaWH);
    
    CGFloat rectOfInterestX = scanAreaX / self.view.bounds.size.width;
    CGFloat rectOfInterestY = scanAreaY / self.view.bounds.size.height;
    CGFloat rectOfInterestW = scanAreaWH / self.view.bounds.size.width;
    CGFloat rectOfInterestH = scanAreaWH / self.view.bounds.size.height;
    CGRect rectOfInterest = CGRectMake(rectOfInterestY, rectOfInterestX, rectOfInterestH, rectOfInterestW);
    
    // setup QRScanner
    self.scanManager = [CYQRCodeScanManager sharedManager];
    self.scanManager.delegate = self;
    [self.scanManager setupSessionWithParentView:self.view rectOfInterest:rectOfInterest];
    
    self.contentView = [[CYQRCodeScanContentView alloc] initWithScanRect:self.scanRect];
    self.contentView.delegate = self;
    [self.view addSubview:self.contentView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.contentView.frame = self.view.bounds;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.scanManager startSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.scanManager stopSession];
    [self.contentView stopScanAnimating];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)dealloc {
    
//    NSLog(@"QRCode scan VC dealloc and this is a dead line ------------------------------------------------");
}


#pragma mark - contentView delegate

- (void)CYQRCodeScanContentView:(UIView *)contentView didClickedFlashlightBtn:(UIButton *)sender {
    
    self.scanManager.flashlightOn = sender.isSelected;
}

#pragma mark - QRCodeScanManagerDelegate

- (void)CYQRCodeScanManager:(CYQRCodeScanManager *)scanManager didOutputMetadataString:(NSString *)metadataString {

    
    [self.contentView stopScanAnimating];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(CYQRCodeScanViewController:didOutputMetadataString:)]) {
        [self.delegate CYQRCodeScanViewController:self didOutputMetadataString:metadataString];
    }
}

- (void)CYQRCodeScanManager:(CYQRCodeScanManager *)scanManager brightnessValueDidUpdated:(CGFloat)brightness {
    
    if (brightness < - 1) {
        
        //打开手电筒
        self.contentView.flashlightBtnHidden = NO;
    } else {
        
        if (self.scanManager.isFlashlightOn) {
            return;
        }
        self.contentView.flashlightBtnHidden = YES;
    }
}


@end
