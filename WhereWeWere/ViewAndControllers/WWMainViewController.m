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


#define kButtonSize 200.0
#define kButtonSmall    80.0
#define kHistorySize    40.0



@interface WWMainViewController () <ADBannerViewDelegate> {
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

- (void) loadView {
    [super loadView];
    
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
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake((mainRect.size.width - kButtonSize)/2, (mainRect.size.height - kButtonSize)/2, kButtonSize, kButtonSize)];
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
        btn.layer.borderColor = kCOLOR_BACKGROUND.CGColor;
        btn.layer.borderWidth = 1.0;
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
        btn.layer.borderColor = kCOLOR_BACKGROUND.CGColor;
        btn.layer.borderWidth = 1.0;
        [self.view addSubview:btn];
        _btnMap = btn;
    }
    
    
}


- (void) startTakePhoto {
    AOCaptureViewController *captureVC = [[AOCaptureViewController alloc] init];
    [self showHUD];
    [self presentViewController:captureVC animated:NO completion:^{
        [self hideHUD];
    }];
}

- (void) showMap {
    
}

- (void) showGallery {
    
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
