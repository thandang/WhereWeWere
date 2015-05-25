//
//  HHRouteItem.h
//  hayhat
//
//  Created by Than Dang on 7/26/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHRouteStepItem.h"

@class HHRouteItem;
@interface HHRouteItem : NSObject {
    CLLocationCoordinate2D      _northeast;
    CLLocationCoordinate2D      _southwest;
    
    NSString                    *_copyrights;
    
    NSMutableArray              *_steps;
    
    NSString                    *_startAdress;
    NSString                    *_endAddress;
    
    CLLocationCoordinate2D      _startPoint;
    CLLocationCoordinate2D      _endPoint;
    
    NSString                    *_duration;
    double                      _durationValue;
    
    NSString                    *_destinationLenth;
    double                      _destinationLenthValue;
}


@property (nonatomic, assign) CLLocationCoordinate2D      northeast;
@property (nonatomic, assign) CLLocationCoordinate2D      southwest;


@property (nonatomic, strong) NSString                    *copyrights;

@property (nonatomic, strong) NSString                    *startAdress;
@property (nonatomic, strong) NSString                    *endAddress;

@property (nonatomic, assign) CLLocationCoordinate2D      startPoint;
@property (nonatomic, assign) CLLocationCoordinate2D      endPoint;

@property (nonatomic, strong) NSString                    *duration;
@property (nonatomic, assign) double                      durationValue;

@property (nonatomic, strong) NSMutableArray              *steps;


@property (nonatomic, strong) NSString                    *destinationLenth;
@property (nonatomic, assign) double                      destinationLenthValue;


- (id) initWithJSONData:(NSArray *) routeArray;

@end
