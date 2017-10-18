//
//  CYQRCodeScanViewController.h
//  CYQRCodeScanDemo
//
//  Created by DeepAI on 2017/10/16.
//  Copyright © 2017年 DeepAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYQRCodeScanManager.h"
@class CYQRCodeScanViewController;

@protocol CYQRCodeScanViewControllerDelegate <NSObject>

@optional
- (void)CYQRCodeScanViewController:(CYQRCodeScanViewController *)vc didOutputMetadataString:(NSString *)metadataString;

@end

@interface CYQRCodeScanViewController : UIViewController <CYQRCodeScanManagerDelegate>

@property (nonatomic,weak) id<CYQRCodeScanViewControllerDelegate> delegate;

/** cover it in subclass to get the dataStr in qrcode . super method must be called first.*/
- (void)CYQRCodeScanManager:(CYQRCodeScanManager *)scanManager didOutputMetadataString:(NSString *)metadataString;
 
@end
