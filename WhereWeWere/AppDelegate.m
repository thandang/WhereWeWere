//
//  AppDelegate.m
//  WhereWeWere
//
//  Created by Dang Thanh Than on 5/25/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import "AppDelegate.h"
#import "WWMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    WWMainViewController *mainVC = [[WWMainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    self.window.rootViewController = nav;
    
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Handle location manager
- (void) retrieveLocationWith:(id)owner callback:(SEL)callback andCallbackError:(SEL)callbackError {
    if (_ownerLocation)
        _ownerLocation = nil;
    _ownerLocation = owner;
    if (_callbackLocation)
        _callbackLocation = nil;
    _callbackLocation = callback;
    if (_callbackLocationError)
        _callbackLocationError = nil;
    _callbackLocationError = callbackError;

    if (!_locationManager)
        _locationManager = [[CLLocationManager alloc] init];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        // If the status is denied or only granted for when in use, display an alert
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
            UIAlertView *alr = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message", nil) message:NSLocalizedString(@"location_confirm", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"setting", nil), nil];
            [alr show];
        }
        // The user has not enabled any location services. Request background authorization.
        else if (status == kCLAuthorizationStatusNotDetermined) {
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_locationManager requestWhenInUseAuthorization];
            }
        }
    } else {
        if ([CLLocationManager locationServicesEnabled] == NO || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            UIAlertView *alr = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message", nil) message:NSLocalizedString(@"location_confirm", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"setting", nil), nil];
            [alr show];
            DEBUG_LOG(@"disable or permission denied");
        } else {
            if (_ownerLocation && [_ownerLocation respondsToSelector:_callbackLocationError]) {
                SuppressPerformSelectorLeakWarning([_ownerLocation performSelector:_callbackLocationError withObject:nil]);
            }
        }
    }



    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locationManager setDistanceFilter:10];
    [_locationManager startUpdatingLocation];
    _getLocationOneTime = YES;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [_locationManager stopUpdatingLocation];
    if (_getLocationOneTime) {
        _getLocationOneTime = NO;
        CLLocation *currentLocation = [locations lastObject];
        if ([_ownerLocation respondsToSelector:_callbackLocation]) {
            SuppressPerformSelectorLeakWarning([_ownerLocation performSelector:_callbackLocation withObject:currentLocation]);
        }

    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [_locationManager stopUpdatingLocation];
    if ([_ownerLocation respondsToSelector:_callbackLocationError]) {
        SuppressPerformSelectorLeakWarning([_ownerLocation performSelector:_callbackLocationError withObject:error]);
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs://"]];
        }
    }
}

@end
