//
//  HHRouteItem.m
//  hayhat
//
//  Created by Than Dang on 7/26/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import "HHRouteItem.h"

@implementation HHRouteItem


@synthesize northeast = _northeast;
@synthesize southwest = _southwest;

@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize startAdress = _startAdress;
@synthesize endAddress = _endAddress;

@synthesize duration = _duration;
@synthesize durationValue = _durationValue;

@synthesize steps = _steps;

@synthesize copyrights = _copyrights;

@synthesize destinationLenth = _destinationLenth;
@synthesize destinationLenthValue = _destinationLenthValue;


- (id) initWithJSONData:(NSArray *)routeArray {
    self = [super init];
    if (self) {
        if (routeArray && [routeArray count]) {
            self.northeast = CLLocationCoordinate2DMake([[[[[routeArray objectAtIndex:0] objectForKey:@"bounds"] objectForKey:@"northeast"] objectForKey:@"lat"] doubleValue], [[[[[routeArray objectAtIndex:0] objectForKey:@"bounds"] objectForKey:@"northeast"] objectForKey:@"lng"] doubleValue]);
            self.southwest = CLLocationCoordinate2DMake([[[[[routeArray objectAtIndex:0] objectForKey:@"bounds"] objectForKey:@"southwest"] objectForKey:@"lat"] doubleValue], [[[[[routeArray objectAtIndex:0] objectForKey:@"bounds"] objectForKey:@"southwest"] objectForKey:@"lng"] doubleValue]);
            
            self.destinationLenth = [[[[[routeArray objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"distance"] objectForKey:@"text"];
            self.destinationLenthValue = [[[[[[routeArray objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"distance"] objectForKey:@"value"] doubleValue];
            
            self.duration = [[[[[routeArray objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"duration"] objectForKey:@"text"];
            self.durationValue = [[[[[[routeArray objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"duration"] objectForKey:@"value"] doubleValue];
            
            self.startAdress = [[[[routeArray objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"start_address"];
            self.startPoint = CLLocationCoordinate2DMake([[[[routeArray objectAtIndex:0] objectForKey:@"start_location"] objectForKey:@"lat"] doubleValue], [[[[routeArray objectAtIndex:0] objectForKey:@"start_location"] objectForKey:@"lng"] doubleValue]);
            
            self.endAddress = [[[[routeArray objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"end_address"];
            self.startPoint = CLLocationCoordinate2DMake([[[[routeArray objectAtIndex:0] objectForKey:@"end_location"] objectForKey:@"lat"] doubleValue], [[[[routeArray objectAtIndex:0] objectForKey:@"end_location"] objectForKey:@"lng"] doubleValue]);
            
            NSArray *stepArray = [[[[routeArray objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"steps"];
            if (stepArray && [stepArray count]) {
                for (NSInteger i = 0; i < [stepArray count]; i++) {
                    HHRouteStepItem *stepItem = [[HHRouteStepItem alloc] init];
                    NSDictionary *tempStep = [stepArray objectAtIndex:i];
                    stepItem.stepDistance = [[tempStep objectForKey:@"distance"] objectForKey:@"text"];
                    stepItem.stepDistanceValue = [[[tempStep objectForKey:@"distance"] objectForKey:@"value"] doubleValue];
                    
                    stepItem.duration = [[tempStep objectForKey:@"duration"] objectForKey:@"text"];
                    stepItem.durationValue = [[[tempStep objectForKey:@"duration"] objectForKey:@"value"] doubleValue];
                    
                    stepItem.startPoint = CLLocationCoordinate2DMake([[[tempStep objectForKey:@"start_location"] objectForKey:@"lat"] doubleValue], [[[tempStep objectForKey:@"start_location"] objectForKey:@"lng"] doubleValue]);
                    stepItem.endPoint = CLLocationCoordinate2DMake([[[tempStep objectForKey:@"end_location"] objectForKey:@"lat"] doubleValue], [[[tempStep objectForKey:@"end_location"] objectForKey:@"lng"] doubleValue]);
                    
                    stepItem.travelMode = [tempStep objectForKey:@"travel_mode"];
                    stepItem.htmlDescription = [tempStep objectForKey:@"html_instructions"];
                    stepItem.stepPolyline = [[tempStep objectForKey:@"polyline"] objectForKey:@"points"];
                    
                    [self addStepRouteItem:stepItem];
                }
            }
        }
    }
    
    
    return self;
}


- (void) addStepRouteItem:(HHRouteStepItem *)aStep {
    if (!aStep) return;
    if (_steps) {
        [_steps addObject:aStep];
    } else {
        _steps = [[NSMutableArray alloc] init];
        [_steps addObject:aStep];
    }
}

@end
