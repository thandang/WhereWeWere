//
//  WWMainViewController.m
//  WhereWeWere
//
//  Created by Dang Thanh Than on 5/25/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import "WWMainViewController.h"
#import "AOCaptureManager.h"
#import <iAd/iAd.h>
#import "AOCaptureViewController.h"
#import "BFPaperButton.h"
#import "SDMDataManager.h"
#import "SDMQueryOperation.h"
#import "FAKFontAwesome.h"
#import "AppDelegate.h"
#import "WWPhoto.h"
#import <CoreLocation/CoreLocation.h>
#import "SDMDataManager.h"
#import "SDMQueryOperation.h"
#import "NSString+Util.h"
#import "WWMapViewController.h"
#import "WWHistoryViewController.h"


#define kButtonSize 200.0
#define kButtonSmall    80.0
#define kHistorySize    40.0

@interface UIImageView (screenshot)

@end

@implementation UIImageView (screenshot)

- (UIImage *)screenshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

@end

@interface WWMainViewController () <ADBannerViewDelegate, SDMQueryOperationDelegate, UIAlertViewDelegate> {
    ADBannerView    *_banner;
    BOOL            _bannerVisible;
    BOOL            _alreadyLoad;
    
    __weak UIView *_viewInfo;
    __weak UIButton *_btnInfo;
    
    __weak UILabel  *_lblRecord;
    __weak BFPaperButton    *_btnRecord;
    
    
    __weak UILabel  *_lblDescription;
    __weak UILabel  *_lblHistory;
    __weak BFPaperButton *_btnHistory;
    
    NSDate    *_nameStored;
    BOOL    _beingStore;
    
    __weak  BFPaperButton   *_btnGallery;
    __weak  UILabel         *_lblGallery;
    
    __weak BFPaperButton    *_btnMap;
    __weak UILabel     *_lblMap;
    
    __weak BFPaperButton *_btnClose;
    __weak UILabel  *_lblClose;
    __weak BFPaperButton    *_btnCheck;
    __weak UILabel  *_lblCheck;
    __weak UIView   *_viewPhotoResult;
    __weak UIImageView  *_imvResult;
    
    WWPhoto *_curentPhoto;
    CLLocationCoordinate2D  _currentLocation;
}

@end

@implementation WWMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    _banner = [[ADBannerView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 50.0)];
    [_banner setDelegate:self];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([kAppDelegate isSavedImage]) {
        [kAppDelegate setIsSavedImage:NO];
        [self processPhoto];
    }
}


- (void) loadView {
    [super loadView];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect mainRect = [WWUtils getMainScreenBounds];
    
//    if (!_lblDescription) {
//        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 70.0, mainRect.size.width - 20, 30.0)];
//        lbl.textAlignment = NSTextAlignmentCenter;
//        lbl.textColor = kCOLOR_BACKGROUND;
//        lbl.font = kBigFont;
//        lbl.text = @"Making some fun";
//        [self.view addSubview:lbl];
//        _lblDescription = lbl;
//    }
    
    if (!_lblRecord) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake((mainRect.size.width - kButtonSize)/2, (mainRect.size.height - kButtonSize)/2 - 50.0, kButtonSize, kButtonSize)];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        lbl.textColor = kCOLOR_BACKGROUND;
        
        FAKFontAwesome *font = [FAKFontAwesome cameraRetroIconWithSize:kButtonSize];
        lbl.attributedText = [font attributedString];
        [self.view addSubview:lbl];
        _lblRecord = lbl;
    }
    if (!_btnRecord) {
        BFPaperButton *btn = [[BFPaperButton alloc] initFlatWithFrame:_lblRecord.frame];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(startTakePhoto) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = kButtonSize/2;
        [self.view addSubview:btn];
        _btnRecord = btn;
    }
    
    if (!_lblGallery) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake((mainRect.size.width - kButtonSmall * 2 - 20)/2, _btnRecord.frame.origin.y + _btnRecord.frame.size.height + 10, kButtonSmall, kButtonSmall)];
        lbl.textColor = kCOLOR_BACKGROUND;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = kDefaultFontButton;
        FAKFontAwesome *font = [FAKFontAwesome fileImageOIconWithSize:kButtonSmall];
        lbl.attributedText = [font attributedString];
        [self.view addSubview:lbl];
        _lblGallery = lbl;
    }
    if (!_btnGallery) {
        BFPaperButton *btn = [[BFPaperButton alloc] initFlatWithFrame:_lblGallery.frame];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(showGallery) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 5.0;
        [self.view addSubview:btn];
        _btnGallery = btn;
    }
    
    if (!_lblMap) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(_btnGallery.frame.size.width + _btnGallery.frame.origin.x + 20, _btnRecord.frame.origin.y + _btnRecord.frame.size.height + 10, kButtonSmall, kButtonSmall)];
        lbl.textColor = kCOLOR_BACKGROUND;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = kDefaultFontButton;
        FAKFontAwesome *font = [FAKFontAwesome mapMarkerIconWithSize:kButtonSmall];
        lbl.attributedText = [font attributedString];
        [self.view addSubview:lbl];
        _lblMap = lbl;
    }
    
    if (!_btnMap) {
        BFPaperButton *btn = [[BFPaperButton alloc] initFlatWithFrame:_lblMap.frame];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(showMap) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 5.0;
        [self.view addSubview:btn];
        _btnMap = btn;
    }
    
    if (!_viewPhotoResult) {
        UIView *vResult = [[UIView alloc] initWithFrame:self.view.bounds];
        [vResult setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:vResult];
        vResult.hidden = YES;
        _viewPhotoResult = vResult;
    }
    
    if (!_imvResult) {
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, _viewPhotoResult.frame.size.width, _viewPhotoResult.frame.size.height)];
        [_viewPhotoResult addSubview:imv];
        _imvResult = imv;
    }
    
    if (!_lblClose) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0,  10, kHistorySize, kHistorySize)];
        lbl.textColor = kCOLOR_BACKGROUND;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = kDefaultFontButton;
        FAKFontAwesome *font = [FAKFontAwesome timesIconWithSize:kHistorySize];
        lbl.attributedText = [font attributedString];
        [_viewPhotoResult addSubview:lbl];
        _lblClose = lbl;
    }
    
    if (!_btnClose) {
        BFPaperButton *btn = [[BFPaperButton alloc] initFlatWithFrame:_lblClose.frame];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancelResult) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 5.0;
        [_viewPhotoResult addSubview:btn];
        _btnClose = btn;
    }
    
    
    if (!_lblCheck) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(_viewPhotoResult.frame.size.width - kHistorySize - 10,  10, kHistorySize, kHistorySize)];
        lbl.textColor = kCOLOR_BACKGROUND;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = kDefaultFontButton;
        FAKFontAwesome *font = [FAKFontAwesome checkIconWithSize:kHistorySize];
        lbl.attributedText = [font attributedString];
        [_viewPhotoResult addSubview:lbl];
        _lblCheck = lbl;
    }
    
    if (!_btnCheck) {
        BFPaperButton *btn = [[BFPaperButton alloc] initFlatWithFrame:_lblCheck.frame];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(applyResult) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 5.0;
        [_viewPhotoResult addSubview:btn];
        _btnCheck = btn;
    }
}

#pragma mark - Action
- (void) startTakePhoto {
    AOCaptureViewController *captureVC = [[AOCaptureViewController alloc] init];
    [self showHUD];
    [self presentViewController:captureVC animated:NO completion:^{
        [self hideHUD];
    }];
}

- (void) showMap {
    WWMapViewController *map = [[WWMapViewController alloc] init];
    [self.navigationController pushViewController:map animated:NO];
}

- (void) showGallery {
    WWHistoryViewController *history = [[WWHistoryViewController alloc] init];
    [self.navigationController pushViewController:history animated:NO];
}

- (void) processPhoto {
    [self showHUD];
    [kAppDelegate retrieveLocationWith:self callback:@selector(resultLocation:) andCallbackError:@selector(resultLocationError:)];
    if ([kAppDelegate imageCaptured]) {
        if (!_curentPhoto) {
            _curentPhoto = [[WWPhoto alloc] init];
        }
        [_curentPhoto setDateSaved:[NSDate date]];
        [_curentPhoto setImage:[kAppDelegate imageCaptured]];
        [_curentPhoto setName:[WWUtils dateToString:[NSDate date] withFormat:kDateFormat]];
    }
}

- (void) showResult {
    _viewPhotoResult.transform = CGAffineTransformMakeScale(0.0, 0.0);
    [UIView animateWithDuration:0.5 animations:^{
        _viewPhotoResult.transform = CGAffineTransformIdentity;
        _imvResult.image = [kAppDelegate imageCaptured];
    } completion:^(BOOL finished) {
        [self hideHUD];
        _viewPhotoResult.hidden = NO;
    }];
}

- (void) hideResult {
    [UIView animateWithDuration:0.5 animations:^{
        _viewPhotoResult.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    } completion:^(BOOL finished) {
        _viewPhotoResult.hidden = YES;
    }];
}

- (void) cancelResult {
    [self hideResult];
}

- (void) applyResult {
    UIAlertView *alr = [[UIAlertView alloc] initWithTitle:@"Input" message:@"Please enter name and notes" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    alr.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    UITextField * alertTextField1 = [alr textFieldAtIndex:0];
    alertTextField1.keyboardType = UIKeyboardTypeDefault;
    alertTextField1.placeholder = @"Enter name";
    
    UITextField * alertTextField2 = [alr textFieldAtIndex:1];
    alertTextField2.keyboardType = UIKeyboardTypeDefault;
    alertTextField2.secureTextEntry = NO;
    alertTextField2.placeholder = @"Enter notes";

    [alr show];
}

#pragma mark - Retrieve current location
- (void) resultLocation:(CLLocation *)location {
    _currentLocation = location.coordinate;
    _curentPhoto.latitude = _currentLocation.latitude;
    _curentPhoto.longitude = _currentLocation.longitude;
    [self showResult];
}

- (void) resultLocationError:(NSError *)error {
    [self showResult];
}


#pragma mark - UIAlertView Deleate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *name = [alertView textFieldAtIndex:0];
        UITextField *notes = [alertView textFieldAtIndex:1];
        NSString *nameStr = name.text ? name.text : @"";
        NSString *notesStr = notes.text ? notes.text : @"";
        _curentPhoto.name = nameStr;
        _curentPhoto.notes = notesStr;
        [self showHUD];
        [[SDMDataManager sharedInstance] setController:self];
        [[SDMDataManager sharedInstance] savePhoto:_curentPhoto];
        
        NSString *pathToSave = [[[DOCUMENT_FOLDER stringByAppendingPathComponent:FOLDER_PHOTOS] stringByAppendingPathComponent:_curentPhoto.name] stringByAppendingPathExtension:@"png"];
        [[NSFileManager defaultManager] createDirectoryAtPath:[pathToSave stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSData *binaryImage = UIImagePNGRepresentation([_imvResult screenshot]);
        
        BOOL success = [binaryImage writeToFile:pathToSave atomically:YES];
        if (!success) {
            DEBUG_LOG(@"save image failed");
        }
    }
}

#pragma mark - QueryOperation
- (void) operation:(SDMQueryOperation *)op didFinishedWithResult:(NSArray *)result {
    
}

- (void) operation:(SDMQueryOperation *)op didInsertOrUpdateSuccess:(BOOL)success {
    [self hideResult];
    [self hideHUD];
}

#pragma mark - ADBanner Delegate
- (void) bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!_bannerVisible) {
        //If banner isn't part of view hierachy, add it
        if (_banner.superview == nil) {
            [self.view addSubview:_banner];
        }
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        _bannerVisible = YES;
    }
}

- (void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (_bannerVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        _bannerVisible = NO;
    }
}

@end
