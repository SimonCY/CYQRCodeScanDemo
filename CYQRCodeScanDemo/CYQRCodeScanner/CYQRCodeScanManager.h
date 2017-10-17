//
//  CYQRCodeScanManager.h
//  CYQRCodeScanDemo
//
//  Created by DeepAI on 2017/10/16.
//  Copyright © 2017年 DeepAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
@class CYQRCodeScanManager;

@protocol CYQRCodeScanManagerDelegate <NSObject>

@required
/** did get data in QRCode. MetadataString: final str in QRCode) */
- (void)CYQRCodeScanManager:(CYQRCodeScanManager *)scanManager didOutputMetadataString:(NSString *)metadataString;

@optional

/** current frame brightness update callback. Base on brightness, you can choose yes&no to show flashlight btn */
- (void)CYQRCodeScanManager:(CYQRCodeScanManager *)scanManager brightnessValueDidUpdated:(CGFloat)brightness;

@end

@interface CYQRCodeScanManager : NSObject

@property (nonatomic,weak) id<CYQRCodeScanManagerDelegate> delegate;

/** flashlight state ,default is no */
@property (nonatomic,assign,getter=isFlashlightOn) BOOL flashlightOn;

/**
 Specifies a rectangle of interest for limiting the search area for visual metadata.
 
 @discussion
 The value of this property is a CGRect that determines the receiver's rectangle of interest for each frame of video. The rectangle's origin is top left and is relative to the coordinate space of the device providing the metadata. Specifying a rectOfInterest may improve detection performance for certain types of metadata. The default value of this property is the value CGRectMake(0, 0, 1, 1). Metadata objects whose bounds do not intersect with the rectOfInterest will not be returned.
 */
@property (nonatomic,assign) CGRect rectOfInterest;

+ (instancetype)sharedManager;

/**
 setup session and preview layer. Session use default metadataObjectTypes as @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code] 
 */
- (void)setupSessionWithParentView:(UIView *)parentView;

/**
 setup session and preview layer. Session use default metadataObjectTypes as @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
 */
- (void)setupSessionWithParentView:(UIView *)parentView rectOfInterest:(CGRect)rect;

/** setup session and preview layer. */
- (void)setupSessionWithMetadataObjectTypes:(NSArray *)metadataObjectTypes parentView:(UIView *)parentView rectOfInterest:(CGRect)rect;


- (void)playSoundWithName:(NSString *)name;

- (void)startSession;

- (void)stopSession;


@end
