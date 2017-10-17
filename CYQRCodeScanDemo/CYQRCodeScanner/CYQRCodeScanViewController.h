//
//  CYQRCodeScanViewController.h
//  CYQRCodeScanDemo
//
//  Created by DeepAI on 2017/10/16.
//  Copyright © 2017年 DeepAI. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CYQRCodeScanViewController;

@protocol CYQRCodeScanViewControllerDelegate <NSObject>

@optional
- (void)CYQRCodeScanViewController:(CYQRCodeScanViewController *)vc didOutputMetadataString:(NSString *)metadataString;

@end

@interface CYQRCodeScanViewController : UIViewController

@property (nonatomic,weak) id<CYQRCodeScanViewControllerDelegate> delegate;

@end
