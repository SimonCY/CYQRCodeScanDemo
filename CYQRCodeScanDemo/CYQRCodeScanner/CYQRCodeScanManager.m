//
//  CYQRCodeScanManager.m
//  CYQRCodeScanDemo
//
//  Created by DeepAI on 2017/10/16.
//  Copyright © 2017年 DeepAI. All rights reserved.
//

#import "CYQRCodeScanManager.h"

@interface CYQRCodeScanManager ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

@property (nonatomic,strong) AVCaptureMetadataOutput *metadataOutput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

static id _instance;

@implementation CYQRCodeScanManager

#pragma mark - single

+ (instancetype)sharedManager {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

#pragma mark - system

- (instancetype)init {
    
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - setupSession

- (void)setupSessionWithParentView:(UIView *)parentView {
    
    [self setupSessionWithParentView:parentView rectOfInterest:CGRectZero];
}

- (void)setupSessionWithParentView:(UIView *)parentView rectOfInterest:(CGRect)rect {
    
    [self setupSessionWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,
                                                AVMetadataObjectTypeEAN13Code,
                                                AVMetadataObjectTypeEAN8Code,
                                                AVMetadataObjectTypeCode128Code
                                                ] parentView:parentView  rectOfInterest:rect];
}

- (void)setupSessionWithMetadataObjectTypes:(NSArray *)metadataObjectTypes parentView:(UIView *)parentView  rectOfInterest:(CGRect)rect {
    
    NSAssert(parentView != nil, @"parentView can`t be nil");
    NSAssert([parentView isKindOfClass:[UIView class]], @"parentView isn`t a UIView object");
    
    if (metadataObjectTypes.count < 1) {
        [self setupSessionWithParentView:parentView  rectOfInterest:rect];
        return;
    }
    
    // create session
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
    }
    
    // setup preview layer
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.videoPreviewLayer.frame = parentView.bounds;
    [parentView.layer addSublayer:self.videoPreviewLayer];
    
    // add input device
    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        
        NSLog(@"默认摄像头不可用");
        return;
    }
    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
    }
    
    // add videoData-output
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    [self.videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    if ([self.session canAddOutput:self.videoDataOutput]) {
        [self.session addOutput:self.videoDataOutput];
    }
    
    // add metadata-output
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // 设置扫描范围（每一个取值0～1，以屏幕右上角为坐标原点）
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if ([self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
    }
    self.metadataOutput.metadataObjectTypes = metadataObjectTypes;
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）; 如需限制扫描范围，打开下一句注释代码并进行相应调试
    self.rectOfInterest = rect;
}

#pragma mark - public

- (void)startSession {
    
    [self.session startRunning];
    self.rectOfInterest = _rectOfInterest;
}

- (void)stopSession {
    
    [self.session stopRunning];
    self.flashlightOn = NO;
}

void soundCompleteCallback(SystemSoundID soundID, void *clientData){
    
}

- (void)playSoundWithName:(NSString *)name {
    
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark - setter

- (void)setFlashlightOn:(BOOL)flashlightOn {
    
    if (_flashlightOn == flashlightOn) {
        return;
    }
    
    _flashlightOn = flashlightOn;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    if ([captureDevice hasTorch]) {
        [captureDevice lockForConfiguration:&error];
        captureDevice.torchMode = _flashlightOn?AVCaptureTorchModeOn:AVCaptureTorchModeOff;
        [captureDevice unlockForConfiguration];
    }
}

- (void)setRectOfInterest:(CGRect)rectOfInterest {
    
    _rectOfInterest = CGRectEqualToRect(rectOfInterest, CGRectZero)? CGRectMake(0, 0, 1, 1) :  rectOfInterest;
    
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）; 如需限制扫描范围，打开下一句注释代码并进行相应调试
    self.metadataOutput.rectOfInterest = _rectOfInterest;
}

#pragma mark - - - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects != nil && metadataObjects.count > 0) {
        
        [self stopSession];
        [self playSoundWithName:@"CYQRCode.bundle/sound.caf"];
        
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        if (self.delegate && [self.delegate respondsToSelector:@selector(CYQRCodeScanManager:didOutputMetadataString:)]) {
            
            [self.delegate CYQRCodeScanManager:self didOutputMetadataString:[metadataObject stringValue]];
        }
    } else {
        
        NSLog(@"暂未识别出扫描的二维码");
    }
    
}

#pragma mark - - - AVCaptureVideoDataOutputSampleBufferDelegate的方法

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
//    NSLog(@"%f",brightnessValue);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(CYQRCodeScanManager:brightnessValueDidUpdated:)]) {
        
        [self.delegate CYQRCodeScanManager:self brightnessValueDidUpdated:brightnessValue];
    }
}

@end
