//
//  WWMapViewController.m
//  WhereWeWere
//
//  Created by Than Dang on 5/25/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import "WWMapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "HHTouchView.h"
#import "HHAnnotaionView.h"
#import "MBProgressHUD.h"
#import "HHAnnotation.h"
#import "HHShopInfoView.h"
#import "AFNetworking.h"
#import "HHRouteItem.h"
#import "AppDelegate.h"
#import "BFPaperButton.h"
#import "FAKFontAwesome.h"
#import "HHAnnotaionView.h"
#import "SDMDataManager.h"
#import "SDMQueryOperation.h"
#import "WWPhoto.h"

@interface WWMapViewController () <MKMapViewDelegate, HHShopInfoDelegate, SDMQueryOperationDelegate> {
    NSMutableArray  *_places;
    
    MKMapView   *_mapView;
    __weak HHTouchView *_touchView;
    CLLocationCoordinate2D  _currentLocation;
    CLLocationCoordinate2D  _annotationSeleted;
    int _countPin;
    MBProgressHUD *_myHUD;
    
    HHShopInfoView  *_inforShopView;
    HHAnnotaionView *_annotationViewSelected;
    MKPolyline  *_polyline;
    CGFloat _distance;
    CGFloat _duration;
    BOOL                      _isShowing;
    __weak UISegmentedControl   *_segmentedControl;
    
    CLLocationManager   *_locationManager;
    
    UIView *_viewInfo;
    __weak  UIButton    *_btnInfo;
    BOOL    _getLocationOneTime;
    NSTimer *_timeAnimation;
    BOOL    _alreadyDone;
    
    __weak UIView *_viewImage;
    __weak UIImageView *_photoViewer;
    
    UIView  *_mainView;
    UILabel *_lblDescription;
    __weak BFPaperButton *_btnClose;
}

- (void) showAnnotation:(HHAnnotation *)annotation;
- (void) hideAnnotation;
- (void) customDidSelectAnnotation:(HHAnnotaionView *)annotationView;

@end

@implementation WWMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) loadView {
    [super loadView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"Map View";
    [self buildView];
}

- (void) buildView {
    [self showHUD];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestDataFromStorage) name:kNotificationReload object:nil];
    
    [kAppDelegate retrieveLocationWith:self callback:@selector(resultLocation:) andCallbackError:@selector(resultLocationError:)];
    
    CGRect mainRect = [WWUtils getMainScreenBounds];
    
    if (!_touchView) {
        HHTouchView *touch = [[HHTouchView alloc] initWithFrame:CGRectMake(0.0, 0.0, mainRect.size.width, mainRect.size.height)];
        [touch setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:touch];
        _touchView = touch;
    }
    _touchView.caller = self;
    _touchView.hitTouch = @selector(dismissLocation);
    
    if (!_mapView) {
        _mapView  = [[MKMapView alloc] init];
        [_mapView setDelegate:self];
    }
    [_mapView setHidden:NO];
    [_mapView setFrame:CGRectMake(0.0, 0.0, _touchView.frame.size.width, _touchView.frame.size.height)];
    [_touchView addSubview:_mapView];
    
    
    
    if (!_inforShopView) {
        _inforShopView = [[HHShopInfoView alloc] initWithFrame:CGRectMake(10.0, mainRect.size.height + 50, mainRect.size.width - 20, 60.0)];
        [_inforShopView setDelegate:self];
    }
    
    [self.view addSubview:_inforShopView];
    
    _mainView = [WWUtils getMainView];
    if (!_viewImage) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _mainView.frame.size.width, _mainView.frame.size.height)];
        [view setBackgroundColor:[UIColor whiteColor]];
        [_mainView addSubview:view];
        _viewImage = view;
    }
    
    if (!_photoViewer) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, _viewImage.frame.size.width, _viewImage.frame.size.height)];
        [img setBackgroundColor:[UIColor clearColor]];
        [_viewImage addSubview:img];
        _photoViewer = img;
    }
    if (!_lblDescription) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 20.0, _viewImage.frame.size.width - 20, 100.0)];
        lbl.font = kTimeFont;
        lbl.textColor = kCOLOR_BACKGROUND;
        [_viewImage addSubview:lbl];
        _lblDescription = lbl;
    }
    
    if (!_btnClose) {
        BFPaperButton *btnClose = [[BFPaperButton alloc] initFlatWithFrame:CGRectMake(_viewImage.frame.size.width - 70.0, 20.0, 60.0, 30.0)];
        [btnClose setTitle:@"Close" forState:UIControlStateNormal];
        btnClose.layer.cornerRadius = 5.0;
        btnClose.layer.borderColor = kCOLOR_BACKGROUND.CGColor;
        btnClose.layer.borderWidth = 1.0;
        [btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_viewImage addSubview:btnClose];
        [btnClose addTarget:self action:@selector(hideImage) forControlEvents:UIControlEventTouchUpInside];
        _btnClose = btnClose;
    }
    
    [_viewImage bringSubviewToFront:_btnClose];
    
    [_viewImage setHidden:YES];
    
    [self requestDataFromStorage];
}


#pragma mark - Private method
- (void) requestDataFromStorage {
    [self showHUD];
    [[SDMDataManager sharedInstance] setController:self];
    [[SDMDataManager sharedInstance] getPhotos];
}

- (void) dismissLocation {
    HHAnnotation *anno;
    for (anno in _mapView.selectedAnnotations) {
        [_mapView deselectAnnotation:anno animated:NO];
        if (anno) {
            [_mapView removeAnnotation:anno];
            [_mapView addAnnotation:anno];
        }
    }
    [self hideAnnotation];
}


- (void) showAnnotation:(HHAnnotation *)annotation {
    [UIView beginAnimations:@"moveCallout" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [_inforShopView configShopInfo:annotation.photo];
    _inforShopView.frame = CGRectMake(10.0, self.view.frame.size.height - 160.0,
                                      _inforShopView.frame.size.width,
                                      _inforShopView.frame.size.height);
    [UIView commitAnimations];
}

- (void) hideAnnotation {
    [UIView beginAnimations:@"moveCalloutOff" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [_inforShopView configShopInfo:nil];
    _inforShopView.frame = CGRectMake(10.0, self.view.frame.size.height + 50.0,
                                      _inforShopView.frame.size.width,
                                      _inforShopView.frame.size.height);
    [UIView commitAnimations];
    
}

- (void) customDidSelectAnnotation:(HHAnnotaionView *)annotationView {
    HHAnnotation *annotation = (HHAnnotation *)annotationView.annotation;
    _annotationSeleted = annotation.coordinate;
    [self showAnnotation:annotation];
    [self showHUD];
    //call google direction api
    NSString *sAddress = [NSString stringWithFormat:@"%f,%f", _currentLocation.latitude, _currentLocation.longitude];
    NSString *dAddress = [NSString stringWithFormat:@"%f,%f", annotationView.annotation.coordinate.latitude, annotationView.annotation.coordinate.longitude];
    NSString *finalUrl = [NSString stringWithFormat:kURL_GOOGLE_DIRECTION, sAddress, dAddress];
    NSURL *urlRequest = [NSURL URLWithString:finalUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlRequest];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *realResponse = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        NSArray *arrayRoutes = [realResponse objectForKey:@"routes"];
        if (arrayRoutes) {
            HHRouteItem *routeItem = [[HHRouteItem alloc] initWithJSONData:arrayRoutes];
            if (routeItem && routeItem.steps) {
                NSMutableArray  *polyLineArray = [[NSMutableArray alloc] init];
                for (NSInteger i = 0; i < [routeItem.steps count]; i++) {
                    HHRouteStepItem *stepRoutes = [routeItem.steps objectAtIndex:i];
                    [polyLineArray addObjectsFromArray:[stepRoutes polyLineArray]];
                }
                _distance = routeItem.destinationLenthValue;
                _duration = routeItem.durationValue / 60;
                NSLog(@"distance: %f and duration: %f", routeItem.destinationLenthValue, routeItem.durationValue);
                if (polyLineArray) {
                    NSInteger itemCount = [polyLineArray count];
                    CLLocationCoordinate2D pointsToUse[itemCount];
                    for (NSInteger i = 0; i < itemCount; i++) {
                        CLLocation *location = [polyLineArray objectAtIndex:i];
                        pointsToUse[i] = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
                    }
                    
                    if (_polyline) {
                        [_mapView removeOverlay:_polyline];
                        _polyline = nil;
                    }
                    _polyline = [MKPolyline polylineWithCoordinates:pointsToUse count:itemCount];
                    [_mapView addOverlay:_polyline];
                    
                    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, kMapZoomSize, kMapZoomSize);
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                        region = [_mapView regionThatFits:region];
                        [_mapView regionThatFits:region];
                    }
                    [_mapView setRegion:region animated:YES];
                } else {
                    NSLog(@"init polyle error");
                }
            } else {
                NSLog(@"No route responds");
            }
        }
        [self hideHUD];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_mapView setRegion:MKCoordinateRegionMakeWithDistance(_annotationSeleted, kMapZoomSize, kMapZoomSize)
                   animated:YES];
        [self hideHUD];
        UIAlertView *alr = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Load direction error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alr show];
    }];
    [operation start];
}

- (void) hideImage {
    if (_viewImage) {
        [UIView animateWithDuration:0.5 animations:^{
            _viewImage.transform = CGAffineTransformMakeScale(0.000001, 0.000001);
        }completion:^(BOOL finished){
            _viewImage.transform = CGAffineTransformIdentity;
            [_viewImage setHidden:YES];
        }];
    }
}

- (void) showImage:(WWPhoto *)photo {
    _viewImage.transform = CGAffineTransformMakeScale(0.0, 0.0);
    [_photoViewer setImage:photo.image];
    _lblDescription.text = photo.notes;
    [_lblDescription sizeToFit];
    [_viewImage setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        _viewImage.transform = CGAffineTransformIdentity;
        [_mainView bringSubviewToFront:_viewImage];
    }completion:^(BOOL finished) {
        
    }];
}

#pragma mark - MKMapview Delegate
- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[HHAnnotaionView class]]) {
        if (_polyline)
            [_mapView removeOverlay:_polyline];
        
        HHAnnotaionView *shopAnnotation = (HHAnnotaionView *)view;
        HHAnnotation *shopItem = (HHAnnotation *)shopAnnotation.annotation;
        NSLog(@"Shop selected %@",shopItem.title);
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            [self hideAnnotation];
        } else {
            _countPin--;
            if (_countPin == 0) {
                if (_isShowing) {
                    _isShowing = NO;
                    [self hideAnnotation];
                }
            }
        }
        
        [WWUtils setRegionByCenter:_mapView];
    }
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[HHAnnotaionView class]]) {
        HHAnnotaionView *shopAnnotation = (HHAnnotaionView *)view;
        if (_annotationViewSelected)
            _annotationViewSelected = nil;
        _annotationViewSelected = shopAnnotation;
        [self customDidSelectAnnotation:shopAnnotation];
    }
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation { //deprecate in iOS 7
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        NSLog(@"MKUserLocation");
        return nil;
    }
    
    MKAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:[HHAnnotation class]]) {
        HHAnnotation *customAnnotation = (HHAnnotation *)annotation;
        if (customAnnotation.locatinType == CURRENT_USER) {
            static NSString *identifier = @"userPin";
            MKPinAnnotationView *pinView = (MKPinAnnotationView *)
            [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            if (!pinView) {
                MKPinAnnotationView *defaultPin =
                [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                reuseIdentifier:identifier];
                defaultPin.pinColor = MKPinAnnotationColorPurple;
                defaultPin.canShowCallout = NO;
                
                return defaultPin;
            } else {
                pinView.annotation = annotation;
            }
            return pinView;
        }
        else {
            static NSString *identifier = @"Pin";
            HHAnnotaionView *annView = (HHAnnotaionView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            if (annView)
                annView = nil;
            
            annView = [[HHAnnotaionView alloc] initWithAnnotation:customAnnotation
                                                  reuseIdentifier:identifier];
            [annotationView setEnabled:YES];
            [annotationView setUserInteractionEnabled:YES];
            
            annotationView = annView;
            [annotationView setCanShowCallout:NO];
        }
    }
    
    return annotationView;
}

- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay { //for iOS 7 or higher
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *lineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        lineView.strokeColor = [UIColor redColor];
        return lineView;
    }
    return nil;
}

//polyline direction
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *lineView = [[MKPolylineView alloc] initWithOverlay:overlay];
        lineView.strokeColor = [UIColor redColor];
        return lineView;
    }
    return nil;
}

#pragma mark - Retrieve current location
- (void) resultLocation:(CLLocation *)location {
    _currentLocation = location.coordinate;

    [_mapView setRegion:MKCoordinateRegionMakeWithDistance(_currentLocation, kMapZoomSize, kMapZoomSize) animated:YES];
    
}

- (void) resultLocationError:(NSError *)error {
    
}

#pragma mark - CellClick
- (void) shopInfoDetailDidClick:(WWPhoto *)photo {
    [self showImage:photo];
}

#pragma mark - Operation
- (void) operation:(SDMQueryOperation *)op didFinishedWithResult:(NSArray *)result {
    if (_places) {
        [_places removeAllObjects];
    } else {
        _places = [[NSMutableArray alloc] init];
    }
    [_places addObjectsFromArray:result];
    
    if([[_mapView annotations] count]) //remove all first
        [_mapView removeAnnotations:[_mapView annotations]];
    
    HHAnnotation *annotation = [[HHAnnotation alloc] initWithCoordinate:_currentLocation title:@"Current Location" locationType:CURRENT_USER];
    [_mapView addAnnotation:annotation];
    
    if (_places && [_places count] > 0) {
        for (NSInteger i = 0; i < [_places count]; i++) {
            WWPhoto *place = [_places objectAtIndex:i];
            if (place.latitude > 0.0 || place.longitude > 0.0) {
                HHAnnotation *anno = [[HHAnnotation alloc] initWithShop:place title:place.name locaionType:SHOP];
                [_mapView addAnnotation:anno];
            }
        }
        
        [WWUtils setRegionByCenter:_mapView];
    }
}

- (void) operation:(SDMQueryOperation *)op didInsertOrUpdateSuccess:(BOOL)success {
    
}

@end
