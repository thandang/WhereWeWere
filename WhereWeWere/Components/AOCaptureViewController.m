//
//  AOCaptureViewController.m
//  AlphaOmega
//
//  Created by Dang Thanh Than on 4/1/15.
//  Copyright (c) 2015 Apide Inc. All rights reserved.
//

#import "AOCaptureViewController.h"
#import "BFPaperButton.h"
#import "AOCaptureManager.h"
#import "UIImage+Util.h"
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>
#import "FontAwesomeKit.h"
#import "AppDelegate.h"

#define kSizeCrop   320.0
#define kTargetImageSize    320.0
#define kSizeButton 30.0
#define kSizeCamera 100.0

//@interface UIImagePickerController(Nonrotating)
//- (BOOL)shouldAutorotate;
//- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation;
//@end
//
//@implementation UIImagePickerController(Nonrotating)
//
//- (BOOL)shouldAutorotate {
//    return NO;
//}
//
//- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}
//
//@end


@interface AOCaptureViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, AOCaptureDelegate> {
    __weak  BFPaperButton *btnCamera;
    __weak  UILabel *lblClose;
    __weak  UILabel *lblChangeCamera;
    __weak  UILabel *lblCamera;
    __weak  UIButton *btnChangeCamera;
    __weak  UIButton *btnBack;
    
    UIView              *viewMainCamera;
    
    UIView              *previewView;
    AVCaptureVideoPreviewLayer *previewLayer;
    CALayer             *focusBox;
    CALayer             *exposeBox;
    
    UIImagePickerController *imagePickerController;
    BOOL    processingTakePhoto;
}

@property (nonatomic, strong) AOCaptureManager  *captureManager;


@end

@implementation AOCaptureViewController


- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self setupView];
}


- (void) loadView {
    [super loadView];

}

- (void) setupView {
#if !TARGET_IPHONE_SIMULATOR
    NSError *error;
    AOCaptureManager *capTemp = [[AOCaptureManager alloc] init];
    self.captureManager = capTemp;
    
    
    self.captureManager.delegate = self;
    if ([self.captureManager setupSessionWithPreset:AVCaptureSessionPresetPhoto error:&error]) {
        viewMainCamera = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
        
        [viewMainCamera setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:viewMainCamera];
        
        previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                               viewMainCamera.frame.size.width, viewMainCamera.frame.size.height)];
        previewView.backgroundColor = [UIColor blackColor];
        [viewMainCamera addSubview:previewView];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(tapToFocus:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [previewView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(tapToExpose:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 1;
        [previewView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureManager.session];
        previewLayer.hidden = YES;
        
        
        CGSize landscapeSize;
        landscapeSize.width = self.view.bounds.size.width;
        landscapeSize.height = self.view.bounds.size.height;
        
        CGRect landscapeRect;
        landscapeRect.size = landscapeSize;
        landscapeRect.origin = self.view.bounds.origin;
        previewLayer.frame = landscapeRect;
        
        
        if(previewLayer.connection.supportsVideoOrientation) {
            previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
        
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        NSDictionary *unanimatedActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"bounds", [NSNull null], @"frame", [NSNull null], @"position", nil];
        
        focusBox = [CALayer layer];
        focusBox.actions = unanimatedActions;
        focusBox.borderWidth = 2.0f;
        focusBox.borderColor = [[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.8f] CGColor];
        focusBox.opacity = 0.0f;
        [previewLayer addSublayer:focusBox];
        
        exposeBox = [CALayer layer];
        exposeBox.actions = unanimatedActions;
        exposeBox.borderWidth = 2.0f;
        exposeBox.borderColor = [[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.8f] CGColor];
        exposeBox.opacity = 0.0f;
        [previewLayer addSublayer:exposeBox];
        
        
        [previewView.layer addSublayer:previewLayer];
    }
#endif
    
    
    CGRect mainFrame = [WWUtils getMainScreenBounds];
    
    if (!lblChangeCamera) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(mainFrame.size.width - 40.0, 20.0, kSizeButton, kSizeButton)];
        lbl.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:lbl];
        lblChangeCamera = lbl;
    }
    
    if (!lblClose) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 20.0, kSizeButton, kSizeButton)];
        lbl.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:lbl];
        lblClose = lbl;
    }
    
    if (!lblCamera) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake((mainFrame.size.width - kSizeCamera)/2, (mainFrame.size.height - kSizeCamera)/2, kSizeCamera, kSizeCamera)];
        lbl.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:lbl];
        lblCamera = lbl;
    }
    
    if (!btnCamera) {
        BFPaperButton *btn = [[BFPaperButton alloc] initWithFrame:lblCamera.frame];
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn addTarget:self action:@selector(cameraClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        btnCamera = btn;
    }
    
    if (!btnChangeCamera) {
        BFPaperButton *btn = [[BFPaperButton alloc] initWithFrame:lblChangeCamera.frame];
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn addTarget:self action:@selector(changedCameraClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        btnChangeCamera = btn;
    }
    
    if (!btnBack) {
        BFPaperButton *btn = [[BFPaperButton alloc] initWithFrame:lblClose.frame];
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        btnBack = btn;
    }
    FAKFontAwesome *fontClose = [FAKFontAwesome timesIconWithSize:40.0];
    lblClose.textColor = kCOLOR_BACKGROUND;
    lblClose.attributedText = [fontClose attributedString];
    
    FAKFontAwesome *fontChange = [FAKFontAwesome refreshIconWithSize:37.0];
    lblChangeCamera.textColor = kCOLOR_BACKGROUND;
    lblChangeCamera.attributedText = [fontChange attributedString];
    
    FAKFontAwesome *fontCamera = [FAKFontAwesome cameraIconWithSize:90.0];
    lblCamera.textColor = kCOLOR_BACKGROUND;
    lblCamera.attributedText = [fontCamera attributedString];
    
    
    [self.view bringSubviewToFront:lblCamera];
    [self.view bringSubviewToFront:lblChangeCamera];
    [self.view bringSubviewToFront:lblClose];
    [self.view bringSubviewToFront:btnCamera];
    [self.view bringSubviewToFront:btnChangeCamera];
    [self.view bringSubviewToFront:btnBack];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self dismissViewControllerAnimated:NO completion:NULL];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#if !TARGET_IPHONE_SIMULATOR
//    [self.captureManager startRunning];
    [self.captureManager performSelector:@selector(startRunning) withObject:nil afterDelay:0.5];
#endif
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.captureManager stopRunning];
}

- (void)applicationDidEnterBackground:(NSNotification *)note {
    [self dismissViewControllerAnimated:NO completion:NULL];
}


#pragma mark - Handle Capture Error
- (void)captureStillImageFailedWithError:(NSError *)error {
    DEBUG_LOG(@"%@", [error localizedDescription]);
}
- (void)acquiringDeviceLockFailedWithError:(NSError *)error {
    DEBUG_LOG(@"%@", [error localizedDescription]);
}
- (void)assetLibraryError:(NSError *)error forURL:(NSURL *)assetURL {
    DEBUG_LOG(@"%@", [error localizedDescription]);
}
- (void)someOtherError:(NSError *)error {
    DEBUG_LOG(@"%@", [error localizedDescription]);
}

#pragma mark -
- (void)tapToFocus:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:previewView];
    if (self.captureManager.videoInput.device.isFocusPointOfInterestSupported) {
        CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:point];
        [self.captureManager focusAtPoint:convertedFocusPoint];
        [self drawFocusBoxAtPointOfInterest:point];
    }
}

- (void)tapToExpose:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:previewView];
    if (self.captureManager.videoInput.device.isExposurePointOfInterestSupported) {
        CGPoint convertedExposurePoint = [self convertToPointOfInterestFromViewCoordinates:point];
        [self.captureManager exposureAtPoint:convertedExposurePoint];
        [self drawExposeBoxAtPointOfInterest:point];
    }
}

- (void)resetFocusAndExpose:(UIGestureRecognizer *)recognizer {
    CGPoint pointOfInterest = CGPointMake(0.5f, 0.5f);
    [self.captureManager focusAtPoint:pointOfInterest];
    [self.captureManager exposureAtPoint:pointOfInterest];
    
    CGRect bounds = previewView.bounds;
    CGPoint screenCenter = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
    
    [self drawFocusBoxAtPointOfInterest:screenCenter];
    [self drawExposeBoxAtPointOfInterest:screenCenter];
    
    [self.captureManager setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
}

#pragma mark - Tap Gesture

+ (void)addAdjustingAnimationToLayer:(CALayer *)layer removeAnimation:(BOOL)remove {
    if (remove) {
        [layer removeAnimationForKey:@"animateOpacity"];
    }
    if ([layer animationForKey:@"animateOpacity"] == nil) {
        [layer setHidden:NO];
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacityAnimation setDuration:0.3f];
        [opacityAnimation setRepeatCount:1.0f];
        [opacityAnimation setAutoreverses:YES];
        [opacityAnimation setFromValue:[NSNumber numberWithFloat:1.0f]];
        [opacityAnimation setToValue:[NSNumber numberWithFloat:0.0f]];
        [layer addAnimation:opacityAnimation forKey:@"animateOpacity"];
    }
}

- (void)drawFocusBoxAtPointOfInterest:(CGPoint)point {
    if ([self.captureManager hasFocus]) {
        [focusBox setFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
        [focusBox setPosition:point];
        [AOCaptureViewController addAdjustingAnimationToLayer:focusBox removeAnimation:YES];
    }
}

- (void)drawExposeBoxAtPointOfInterest:(CGPoint)point {
    if ([self.captureManager hasExposure]) {
        [exposeBox setFrame:CGRectMake(0.0f, 0.0f, 114.0f, 114.0f)];
        [exposeBox setPosition:point];
        [AOCaptureViewController addAdjustingAnimationToLayer:exposeBox removeAnimation:YES];
    }
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(0.5f, 0.5f);
    CGSize frameSize = previewView.frame.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = previewLayer;
    
    if ([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.0f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in self.captureManager.videoInput.ports) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = 0.5f;
                CGFloat yc = 0.5f;
                
                if ( [[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.0f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.0f - (point.x / x2);
                        }
                    }
                } else if ([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.0f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.0f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)showImagePicker {
    if (!imagePickerController) {
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
   
    [self presentViewController:imagePickerController animated:YES completion:^{
        processingTakePhoto = NO;
    }];
}

- (void) goToImageView:(UIImage *)image {
    UIImage *targetImage = [imgResult.image resizedImage:CGSizeMake(kTargetImageSize, kTargetImageSize)
                                        imageOrientation:imgResult.image.imageOrientation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_resultImage object:targetImage];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}


#pragma mark -
- (void)captureStillImageDidFinished:(UIImage *)image {
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGRect cropRect;
    if (height > width) {
        cropRect = CGRectMake((height - width) / 2.0f, 0.0f, width, width);
    } else {
        cropRect = CGRectMake((width - height) / 2.0f, 0.0f, height, height);
    }
    
    UIImage *croppedImage = [image croppedImage:cropRect];
    UIImage *resizedImage = [croppedImage resizedImage:CGSizeMake(kSizeCrop, kSizeCrop)
                                      imageOrientation:image.imageOrientation];
    
//    [self goToImageView:resizedImage];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_resultImage object:targetImage];
    [kAppDelegate setIsSavedImage:YES];
    [kAppDelegate setImageCaptured:resizedImage];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
    
    processingTakePhoto = NO;
    [btnCamera setEnabled:YES];
}

#pragma mark -

- (void)captureSessionDidStartRunning {
    previewLayer.hidden = NO;
    
    CGRect bounds = previewView.bounds;
    CGPoint screenCenter = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
    [self drawFocusBoxAtPointOfInterest:screenCenter];
    [self drawExposeBoxAtPointOfInterest:screenCenter];
}

#pragma mark - Action

- (void) cameraClicked:(id)sender {
    if (processingTakePhoto) {
        return;
    }
    
#if !TARGET_IPHONE_SIMULATOR
    [btnCamera setEnabled:NO];
    processingTakePhoto = YES;
    [self.captureManager captureStillImage];
#endif
}

- (void)changedCameraClicked:(id)sender {
    if (processingTakePhoto) {
        return;
    }
    
    [btnChangeCamera setEnabled:NO];
    [btnCamera setEnabled:NO];
    UIViewAnimationTransition typeAnimation = UIViewAnimationTransitionFlipFromLeft;
    
    AVCaptureDevicePosition position = self.captureManager.videoInput.device.position;
    if (position == AVCaptureDevicePositionFront) {
        typeAnimation = UIViewAnimationTransitionFlipFromRight;
    }
    
    [self.captureManager cameraToggle];
    
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationTransition:typeAnimation
                           forView:viewMainCamera
                             cache:YES];
    [UIView setAnimationDelegate:self];
    
    [previewView setHidden:YES];
    [UIView commitAnimations];
    
    [previewView setHidden:NO];
    [self.view bringSubviewToFront:btnBack];
}




-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    //do smth
    [btnChangeCamera setEnabled:YES];
    [btnCamera setEnabled:YES];
}

- (IBAction)albumClicked:(id)sender {
    if (processingTakePhoto) {
        return;
    }
    processingTakePhoto = YES;
    [btnCamera setEnabled:NO];
    previewLayer.hidden = YES;
    [self.captureManager stopRunning];
    [self showImagePicker];
}


- (IBAction)backClicked:(id)sender {
    [self.captureManager stopRunning];
    [kAppDelegate setIsSavedImage:NO];
    [self dismissViewControllerAnimated:NO completion:NULL];
}

- (BOOL) shouldAutorotate {
    return NO;
}

- (NSUInteger) supportedInterfaceOrientations {
    self.captureManager.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    return UIInterfaceOrientationMaskPortrait;
}


@end
