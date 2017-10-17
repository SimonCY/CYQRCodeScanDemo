//
//  CYQRCodeScanContentView.h
//  CYQRCodeScanDemo
//
//  Created by DeepAI on 2017/10/16.
//  Copyright © 2017年 DeepAI. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CYQRCodeScanContentView;

@protocol CYQRCodeScanContentViewDelegate <NSObject>

@optional
- (void)CYQRCodeScanContentView:(CYQRCodeScanContentView *)contentView didClickedFlashlightBtn:(UIButton *)sender;

@end

@interface CYQRCodeScanContentView : UIView

@property (nonatomic,weak) id<CYQRCodeScanContentViewDelegate> delegate;

@property (nonatomic,assign,getter=isFlashlightBtnHidden) BOOL flashlightBtnHidden;

- (instancetype)initWithScanRect:(CGRect)scanRect;

- (void)startScanAnimating;

- (void)stopScanAnimating;

- (void)startLoadingAnimating;

- (void)stopLoadingAnimation;

@end
