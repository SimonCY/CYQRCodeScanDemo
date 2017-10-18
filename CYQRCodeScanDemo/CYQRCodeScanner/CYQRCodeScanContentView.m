//
//  CYQRCodeScanContentView.m
//  CYQRCodeScanDemo
//
//  Created by DeepAI on 2017/10/16.
//  Copyright © 2017年 DeepAI. All rights reserved.
//

#import "CYQRCodeScanContentView.h"

@interface CYQRCodeScanContentView ()

@property (nonatomic,strong) UILabel *promptLabel;

@property (nonatomic,strong) UIImageView *lineImageView;

@property (nonatomic,strong) UIButton *flashlightBtn;

@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic,strong) NSTimer *timer;

/** clearColor area frame */
@property (nonatomic,assign) CGRect scanRect;




/*!
  once alloc, change these value ,the scannerView won`t update itself now.
 */

/** default is whiteColor */
@property (nonatomic,strong) UIColor *borderColor;

/** default is wechat-green */
@property (nonatomic,strong) UIColor *cornerColor;

/** default is 6.0f */
@property (nonatomic,assign) CGFloat cornerWidth;

/** default is 0.6f */
@property (nonatomic,assign) CGFloat backgroundAlpha;



@end

@implementation CYQRCodeScanContentView

#pragma mark - drawRect

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
 
    // background area
    UIBezierPath *backgroundAreaPath = [UIBezierPath bezierPathWithRect:rect];
    [[[UIColor blackColor] colorWithAlphaComponent:self.backgroundAlpha] setFill];
    [backgroundAreaPath fill];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeClear);
    
    // scan area
    CGFloat scanAreaW = self.scanRect.size.width;
    CGFloat scanAreaH = self.scanRect.size.height;
    CGFloat scanAreaX = self.scanRect.origin.x;
    CGFloat scanAreaY = self.scanRect.origin.y;
    
    UIBezierPath *scanAreaPath = [UIBezierPath bezierPathWithRect:CGRectMake(scanAreaX, scanAreaY, scanAreaW, scanAreaH)];
    [[UIColor clearColor] setFill];
    [scanAreaPath fill];
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    // scan area border
    CGFloat borderLineWidth = 1;
    CGFloat borderW = scanAreaW + borderLineWidth * 2;
    CGFloat borderH = scanAreaH + borderLineWidth * 2;
    CGFloat borderX = (self.bounds.size.width - borderW) / 2;
    CGFloat borderY = (self.bounds.size.height - borderH) / 2;
    UIBezierPath *scanBorderPath = [UIBezierPath bezierPathWithRect:CGRectMake(borderX, borderY, borderW, borderH)];
    scanBorderPath.lineWidth = borderLineWidth;
    scanBorderPath.lineCapStyle = kCGLineCapButt;
    [self.borderColor setStroke];
    [scanBorderPath stroke];
    
    // corners
    CGFloat cornerLineWidth = self.cornerWidth;
    CGFloat cornerLenght = cornerLineWidth * 6;
    for (int i = 0; i < 2; i++) {               //是左还是右
        
        for (int j = 0; j < 2; j++) {           //是上还是下
            
            for (int k = 0; k < 2; k++) {       //是横还是竖
                
                CGFloat cornerW = k ? cornerLenght : cornerLineWidth;
                CGFloat cornerH = k ? cornerLineWidth : cornerLenght;
                CGFloat cornerX = (borderX - cornerLineWidth) + (borderW + cornerLineWidth * 2 - cornerW) * i;
                CGFloat cornerY = (borderY - cornerLineWidth) + (borderH + cornerLineWidth * 2 - cornerH) * j;
                UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRect:CGRectMake(cornerX, cornerY, cornerW, cornerH)];
                cornerPath.lineWidth = cornerLineWidth;
                [self.cornerColor setFill];
                [cornerPath fill];
            }
        }
    }
}

#pragma mark - init

- (instancetype)initWithScanRect:(CGRect)scanRect {
    if (self = [super init]) {
        
        self.scanRect = scanRect;
    }
    return self;
}

#pragma mark - system

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        //default configuration
        self.backgroundAlpha = 0.6f;
        self.borderColor = [UIColor whiteColor];
        self.cornerColor = [UIColor colorWithRed:240/255.0f green:102/255.0 blue:77/255.0 alpha:1.0];
        self.cornerWidth = 6.0f;
        
        //subViews
        self.promptLabel = [[UILabel alloc] init];
        self.promptLabel.textAlignment = NSTextAlignmentCenter;
        self.promptLabel.font = [UIFont systemFontOfSize:12];
        self.promptLabel.textColor = [UIColor lightGrayColor];
        self.promptLabel.text = @"将云台上的二维码放入框内，即可进行认证";
        [self addSubview:self.promptLabel];
        
        self.lineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CYQRCode.bundle/qrcode_line"]];
        self.lineImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.lineImageView.hidden = YES;
        [self addSubview:self.lineImageView];
        
        self.flashlightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.flashlightBtn setImage:[UIImage imageNamed:@"CYQRCode.bundle/qrcode_flashlight"] forState:UIControlStateNormal];
        [self.flashlightBtn setImage:[UIImage imageNamed:@"CYQRCode.bundle/qrcode_flashlight_selected"] forState:UIControlStateSelected];
        self.flashlightBtn.alpha = 0;
        [self.flashlightBtn addTarget:self action:@selector(flashlightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.flashlightBtn];
        
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:self.indicatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat margin = 30;
    
    CGFloat promptX = 0;
    CGFloat promptY = CGRectGetMaxY(self.scanRect) + margin;
    CGFloat promptW = self.bounds.size.width;
    CGFloat promptH = self.promptLabel.font.pointSize;
    self.promptLabel.frame = CGRectMake(promptX, promptY, promptW, promptH);
    
    CGFloat flashlightWH = 40;
    CGFloat flashlightX = (self.bounds.size.width - flashlightWH) / 2;
    CGFloat flashlightY = CGRectGetMaxY(self.scanRect) - flashlightWH - margin / 3;
    self.flashlightBtn.frame = CGRectMake(flashlightX, flashlightY, flashlightWH, flashlightWH);
    
    self.indicatorView.center = self.center;
}

#pragma mark - setter

- (void)setScanRect:(CGRect)scanRect {
    
    if (CGRectEqualToRect(scanRect, CGRectZero)) {
        
        CGFloat scanAreaWH = self.bounds.size.width * 0.7;
        CGFloat scanAreaX = (self.bounds.size.width - scanAreaWH) / 2;
        CGFloat scanAreaY = (self.bounds.size.height - scanAreaWH) / 2;
        _scanRect = CGRectMake(scanAreaX, scanAreaY, scanAreaWH, scanAreaWH);
    } else {
        
        _scanRect = scanRect;
    }
    [self setNeedsDisplay];
}

- (void)setFlashlightBtnHidden:(BOOL)flashlightBtnHidden {
    
    _flashlightBtnHidden = flashlightBtnHidden;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.flashlightBtn.alpha = flashlightBtnHidden?0:1;
    }];
    
    if (flashlightBtnHidden == NO) {
        
        [self stopScanAnimating];
    } else {
        
        [self startScanAnimating];
    }
}

#pragma mark - timer

- (void)startTimer {
    
    if (self.timer) {
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.6 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    //等不及了，先调用一次
    [self timerEvent];
}

- (void)stopTimer {
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerEvent {
    
    CGFloat lineH = 20;
    CGFloat lineX = self.scanRect.origin.x;
    CGFloat lineY = self.scanRect.origin.y - lineH / 2;
    CGFloat lineW = self.scanRect.size.width;
    self.lineImageView.frame = CGRectMake(lineX, lineY, lineW, lineH);
    self.lineImageView.hidden = NO;
    
    [UIView animateWithDuration:2.5 animations:^{
        
        self.lineImageView.frame = CGRectMake(lineX, lineY + self.scanRect.size.height - 2, lineW, lineH);
    } completion:^(BOOL finished) {
        
         self.lineImageView.hidden = YES;
    }];
}

#pragma mark - btnClicked events

- (void)flashlightBtnClicked:(UIButton *)sender {
    
    sender.selected = !sender.isSelected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(CYQRCodeScanContentView:didClickedFlashlightBtn:)]) {
        [self.delegate CYQRCodeScanContentView:self didClickedFlashlightBtn:sender];
    }
}

#pragma mark - public

- (void)startScanAnimating {
    
    if (self.flashlightBtnHidden == NO) {
        return;
    }
    
    [self startTimer];
}

- (void)stopScanAnimating {
    
    self.lineImageView.hidden = YES;
    [self.lineImageView.layer removeAllAnimations];
    [self stopTimer];
}

- (void)startLoadingAnimating {
    
    [self.indicatorView startAnimating];
}

- (void)stopLoadingAnimation {
    
    [self.indicatorView stopAnimating];
}

@end
