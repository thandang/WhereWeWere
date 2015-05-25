//
//  HHAnnotation.h
//  hayhat
//
//  Created by Than Dang on 3/9/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class WWPhoto;
typedef enum {
    CURRENT_USER,
    SHOP
}LOCATION_TYPE;

@interface HHAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D  coordinate;
    NSString *title;
    LOCATION_TYPE   locationType;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) LOCATION_TYPE locatinType;
@property (nonatomic, strong) WWPhoto    *photo;



- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate_ title:(NSString *)title_ locationType:(LOCATION_TYPE)locationType_;
- (id) initWithShop:(WWPhoto *)photo title:(NSString *)title_ locaionType:(LOCATION_TYPE)locationType_;


@end
