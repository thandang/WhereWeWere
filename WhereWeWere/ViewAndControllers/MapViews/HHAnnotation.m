//
//  HHAnnotation.m
//  hayhat
//
//  Created by Than Dang on 3/9/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import "HHAnnotation.h"
#import "WWPhoto.h"

@implementation HHAnnotation
@synthesize coordinate;
@synthesize title;
@synthesize locatinType = _locatinType;


- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate_ title:(NSString *)title_ locationType:(LOCATION_TYPE)locationType_{
    self = [super init];
    if (self) {
        coordinate = coordinate_;
        if (title_)
            title = title_;
        _locatinType = locationType_;
            
    }
    return self;
}

- (id) initWithShop:(WWPhoto *)photo title:(NSString *)title_ locaionType:(LOCATION_TYPE)locationType_ {
    self = [super init];
    if (self) {
        coordinate = CLLocationCoordinate2DMake(photo.latitude, photo.longitude);
        if (title_)
            title = title_;
        _locatinType = locationType_;

        self.photo = photo;
    }
    return self;
}
@end
