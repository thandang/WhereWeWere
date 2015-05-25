//
//  AOCaptureManager.m
//  AlphaOmega
//
//  Created by Dang Thanh Than on 4/1/15.
//  Copyright (c) 2015 Apide Inc. All rights reserved.
//

#import "AOCaptureManager.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVCaptureInput.h>
#import <AVFoundation/AVCaptureSession.h>


@interface AOCaptureManager(AVCaptureFileOutputRecordingDelegate)<AVCaptureFileOutputRecordingDelegate>
@end

@interface AOCaptureManager (Internal)
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *)frontFacingCamera;
- (AVCaptureDevice *)backFacingCamera;

@end

@interface AOCaptureManager () {
}

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation AOCaptureManager
@synthesize session, videoInput, delegate, stillImageOutput;
@dynamic flashMode, torchMode, whiteBalanceMode, focusMode, exposureMode;

- (instancetype) init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(captureSessionDidStartRunning:)
                                                     name:AVCaptureSessionDidStartRunningNotification object:session];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [session stopRunning];
    self.session = nil;
    self.videoInput = nil;
    self.stillImageOutput = nil;
}



#pragma mark - Public method
- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error {
    videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:error];
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    stillImageOutput.outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    
    session = [[AVCaptureSession alloc] init];
    if ([session canAddInput:videoInput]) {
        [session addInput:videoInput];
    }
    
    if ([session canAddOutput:stillImageOutput]) {
        [session addOutput:stillImageOutput];
    }
    [session setSessionPreset:sessionPreset];
    
    return YES;
}

- (void) startRunning {
    [session startRunning];
}

- (void) stopRunning {
    if ([session isRunning]) {
        [session stopRunning];
    }
}

- (BOOL) cameraToggle {
    BOOL success = NO;
    
    if ([self hasMultiCamera]) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = videoInput.device.position;
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
        } else if (position == AVCaptureDevicePositionFront) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
        } else {
            goto bail;
        }
        
        if (newVideoInput != nil) {
            [session beginConfiguration];
            [session removeInput:videoInput];
            if ([session canAddInput:newVideoInput]) {
                [session addInput:newVideoInput];
                self.videoInput = newVideoInput;
            } else {
                [session addInput:videoInput];
            }
            [session commitConfiguration];
            success = YES;
        } else if (error) {
            if ([delegate respondsToSelector:@selector(someOtherError:)]) {
                [delegate someOtherError:error];
            }
        }
    }
    
bail:
    return success;
}

- (void) captureStillImage {
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:self.connection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         [session stopRunning];
         
         if (imageDataSampleBuffer != NULL) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             
             if ([delegate respondsToSelector:@selector(captureStillImageDidFinished:)]) {
                 [delegate captureStillImageDidFinished:image];
             }
             
         } else if (error) {
             if ([delegate respondsToSelector:@selector(captureStillImageFailedWithError:)]) {
                 [delegate captureStillImageFailedWithError:error];
             }
         }
     }];
}

- (AVCaptureConnection *) connection {
    AVCaptureConnection *videoConnection = [AOCaptureManager connectionWithMediaType:AVMediaTypeVideo fromConnections:stillImageOutput.connections];
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    return videoConnection;
}

- (BOOL) hasFlash {
    return videoInput.device.hasFlash;
}

- (AVCaptureFlashMode) flashMode {
    return videoInput.device.flashMode;
}

- (void) setFlashMode:(AVCaptureFlashMode)flashMode {
    AVCaptureDevice *device = videoInput.device;
    if ([device isFlashModeSupported:flashMode] && device.flashMode != flashMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }
}



- (BOOL) hasTorch {
    return NO;
}

- (AVCaptureTorchMode) torchMode {
    return videoInput.device.torchMode;
}

- (void) setTorchMode:(AVCaptureTorchMode)torchMode {
    AVCaptureDevice *device = videoInput.device;
    if ([device isTorchModeSupported:torchMode] && device.torchMode != torchMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else {
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }
}

- (BOOL) hasFocus {
    AVCaptureDevice *device = videoInput.device;
    
    return  [device isFocusModeSupported:AVCaptureFocusModeLocked] ||
    [device isFocusModeSupported:AVCaptureFocusModeAutoFocus] ||
    [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
}

- (AVCaptureFocusMode) focusMode {
    return videoInput.device.focusMode;
}

- (void)setFocusMode:(AVCaptureFocusMode)focusMode {
    AVCaptureDevice *device = videoInput.device;
    if ([device isFocusModeSupported:focusMode] && device.focusMode != focusMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusMode = focusMode;
            [device unlockForConfiguration];
        } else {
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }
}

- (BOOL)hasExposure {
    AVCaptureDevice *device = videoInput.device;
    
    return  [device isExposureModeSupported:AVCaptureExposureModeLocked] ||
    [device isExposureModeSupported:AVCaptureExposureModeAutoExpose] ||
    [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure];
}

- (AVCaptureExposureMode)exposureMode {
    return videoInput.device.exposureMode;
}

- (void)setExposureMode:(AVCaptureExposureMode)exposureMode {
    if (exposureMode == AVCaptureExposureModeAutoExpose) {
        exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    }
    AVCaptureDevice *device = videoInput.device;
    if ([device isExposureModeSupported:exposureMode] && device.exposureMode != exposureMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposureMode = exposureMode;
            [device unlockForConfiguration];
        } else {
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }
}

- (BOOL)hasWhiteBalance {
    AVCaptureDevice *device = videoInput.device;
    
    return  [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked] ||
    [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance];
}

- (AVCaptureWhiteBalanceMode)whiteBalanceMode {
    return videoInput.device.whiteBalanceMode;
}

- (void)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode {
    if (whiteBalanceMode == AVCaptureWhiteBalanceModeAutoWhiteBalance) {
        whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
    }
    AVCaptureDevice *device = videoInput.device;
    if ([device isWhiteBalanceModeSupported:whiteBalanceMode] && device.whiteBalanceMode != whiteBalanceMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.whiteBalanceMode = whiteBalanceMode;
            [device unlockForConfiguration];
        } else {
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }
}

- (NSInteger) cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (BOOL) hasMultiCamera {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1 ? YES : NO;
}

- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = videoInput.device;
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }
}

- (void)exposureAtPoint:(CGPoint)point {
    AVCaptureDevice *device = videoInput.device;
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            [device unlockForConfiguration];
        } else {
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections {
    for (AVCaptureConnection *connection in connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([port.mediaType isEqual:mediaType] ) {
                return connection;
            }
        }
    }
    return nil;
}



#pragma mark - Notification
- (void) captureSessionDidStartRunning:(NSNotification *)notification {
    if ([delegate respondsToSelector:@selector(captureSessionDidStartRunning)]) {
        [delegate captureSessionDidStartRunning];
    }
}

@end

@implementation AOCaptureManager(Internal)

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)frontFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}



@end
