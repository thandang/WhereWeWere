//
//  HHMapView.m
//  hayhat
//
//  Created by Than Dang on 3/9/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import "HHMapView.h"

@implementation HHMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Mapview Delegate
- (MKAnnotationView *)viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    //using default
    static NSString *identifier = @"userPin";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *) [self dequeueReusableAnnotationViewWithIdentifier:identifier];
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


//For route view
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
}

@end
