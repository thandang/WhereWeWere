//
//  AOCaptureManager.h
//  AlphaOmega
//
//  Created by Dang Thanh Than on 4/1/15.
//  Copyright (c) 2015 Apide Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol AOCaptureDelegate;

@interface AOCaptureManager : NSObject {
    @private
    AVCaptureSession    *session;
    AVCaptureDeviceInput     *videoInput;
    AVCaptureStillImageOutput   *stillImageOutput;
}

@property (nonatomic, readonly, strong) AVCaptureSession    *session;
@property (nonatomic, readonly, strong) AVCaptureDeviceInput    *videoInput;
@property (nonatomic, weak) id<AOCaptureDelegate> delegate;

@property (nonatomic, assign) AVCaptureFlashMode    flashMode;
@property (nonatomic, assign) AVCaptureTorchMode    torchMode;
@property (nonatomic, assign) AVCaptureFocusMode    focusMode;
@property (nonatomic, assign) AVCaptureExposureMode exposureMode;
@property (nonatomic, assign) AVCaptureWhiteBalanceMode whiteBalanceMode;
@property (nonatomic, strong) AVCaptureConnection *connection;


- (BOOL) setupSessionWithPreset:(NSString *) sessionPreset error:(NSError **) error;
- (void) startRunning;
- (void) stopRunning;
- (NSInteger) cameraCount;
- (void) captureStillImage;
- (BOOL) cameraToggle;
- (BOOL) hasMultiCamera;
- (BOOL) hasFlash;
- (BOOL) hasTorch;
- (BOOL) hasFocus;
- (BOOL) hasExposure;
- (BOOL) hasWhiteBalance;
- (void)focusAtPoint:(CGPoint)point;
- (void)exposureAtPoint:(CGPoint)point;
+ (AVCaptureConnection *) connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

@end

@protocol AOCaptureDelegate <NSObject>
@optional
- (void) captureSessionDidStartRunning;
- (void) captureStillImageDidFinished:(UIImage *) image;
- (void) captureStillImageFailedWithError:(NSError *) error;
- (void) acquiringDeviceLockFailedWithError:(NSError *) error;
- (void) cannotWriteToAssetLibrary;
- (void) assetLibraryError:(NSError *) error forURL:(NSURL *) assetURL;
- (void) someOtherError:(NSError *)error;
@end
