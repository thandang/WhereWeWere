//
//  HHAnnotaionView.m
//  hayhat
//
//  Created by Than Dang on 3/9/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import "HHAnnotaionView.h"
#import "HHAnnotation.h"

@implementation HHAnnotaionView

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation: annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        //custom annotaion view here
        HHAnnotation *anno = (HHAnnotation *)annotation;
        UIImage *img = nil;
        if (anno.locatinType == SHOP) {
            img = [UIImage imageNamed:@"pin"];
        }
        self.image = img;
        CGPoint notNear = CGPointMake(10000, 10000);
        self.calloutOffset = notNear;
    }
    return self;
}



@end
