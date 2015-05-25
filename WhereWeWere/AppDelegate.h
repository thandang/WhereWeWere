//
//  AppDelegate.h
//  WhereWeWere
//
//  Created by Dang Thanh Than on 5/25/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> {
    CLLocationManager   *_locationManager;
    id      _ownerLocation;
    SEL     _callbackLocation;
    SEL     _callbackLocationError;
    BOOL    _getLocationOneTime;
}

@property (strong, nonatomic) UIWindow *window;

- (void) retrieveLocationWith:(id)owner callback:(SEL)callback andCallbackError:(SEL)callbackError;

@end

