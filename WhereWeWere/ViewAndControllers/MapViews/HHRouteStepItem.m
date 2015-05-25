//
//  HHRouteStepItem.m
//  hayhat
//
//  Created by Than Dang on 7/26/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import "HHRouteStepItem.h"

@implementation HHRouteStepItem
@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;

@synthesize stepDistance = _stepDistance;
@synthesize stepDistanceValue = _stepDistanceValue;

@synthesize htmlDescription = _htmlDescription;
@synthesize travelMode = _travelMode;

@synthesize duration = _duration;
@synthesize durationValue = _durationValue;

@synthesize stepPolyline = _stepPolyline;

- (NSMutableArray *) polyLineArray {
    if (_stepPolyline) {
        NSMutableString *encodedStr = [[NSMutableString alloc] initWithCapacity:[_stepPolyline length]];
        [encodedStr appendString:_stepPolyline];
        NSInteger len = [_stepPolyline length];
        NSInteger index = 0;
        NSMutableArray *array = [[NSMutableArray alloc] init];
        NSInteger lat=0;
        NSInteger lng=0;
        while (index < len) {
            NSInteger b;
            NSInteger shift = 0;
            NSInteger result = 0;
            do {
                b = [_stepPolyline characterAtIndex:index++] - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
            lat += dlat;
            shift = 0;
            result = 0;
            do {
                b = [_stepPolyline characterAtIndex:index++] - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
            lng += dlng;
            NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
            NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
            [array addObject:loc];
        }
        return array;
    }
    
    return nil;
}

@end
