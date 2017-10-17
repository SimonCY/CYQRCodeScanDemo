//
//  ViewController.m
//  CYQRCodeScanDemo
//
//  Created by DeepAI on 2017/10/16.
//  Copyright © 2017年 DeepAI. All rights reserved.
//

#import "ViewController.h"
#import "CYQRCodeScanViewController.h"

@interface ViewController ()<CYQRCodeScanViewControllerDelegate>
- (IBAction)ScanBtnClicked:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}




- (IBAction)ScanBtnClicked:(id)sender {
    
    CYQRCodeScanViewController *scanVC = [[CYQRCodeScanViewController alloc] init];
    scanVC.delegate = self;
    [self.navigationController pushViewController:scanVC animated:YES];
}

#pragma mark - CYQRCodeScanViewControllerDelegate

- (void)CYQRCodeScanViewController:(CYQRCodeScanViewController *)vc didOutputMetadataString:(NSString *)metadataString {
    
    NSLog(@"metadataString is %@",metadataString);
}
@end
