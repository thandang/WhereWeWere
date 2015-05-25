//
//  HHRouteStepItem.h
//  hayhat
//
//  Created by Than Dang on 7/26/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface HHRouteStepItem : NSObject {
    CLLocationCoordinate2D    _startPoint;
    CLLocationCoordinate2D    _endPoint;
    
    NSString                  *_stepDistance;
    double                    _stepDistanceValue;
    
    NSString                  *_htmlDescription;
    NSString                  *_travelMode;
    
    NSString                  *_duration;
    float                     _durationValue;
    
    NSMutableString           *_stepPolyline;
}


@property (nonatomic, assign) CLLocationCoordinate2D    startPoint;
@property (nonatomic, assign) CLLocationCoordinate2D    endPoint;

@property (nonatomic, strong) NSString                  *stepDistance;
@property (nonatomic, assign) double                    stepDistanceValue;

@property (nonatomic, strong) NSString                  *htmlDescription;
@property (nonatomic, strong) NSString                  *travelMode;

@property (nonatomic, strong) NSString                  *duration;
@property (nonatomic, assign) float                     durationValue;

@property (nonatomic, strong) NSMutableString           *stepPolyline;

- (NSMutableArray *) polyLineArray;

@end
