//
//  HHDetailKaraView.m
//  hayhat
//
//  Created by Than Dang on 8/22/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import "HHDetailKaraView.h"
#import "WWPhoto.h"
#define kShadowRadius 1.0
#define kShadowOpacity 0.7

@implementation HHDetailKaraView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) loadViewFromNib {
    NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"HHDetailKaraView" owner:self options:nil];
    for( id obj in nibViews ) {
        if( [obj isMemberOfClass:[HHDetailKaraView class]] ) {
            return obj;
        }
    }
    
    for( id obj in nibViews ) {
        if( [obj isKindOfClass:[HHDetailKaraView class]] ) {
            return obj;
        }
    }
    return nil;
}

- (void) configViewWith:(WWPhoto *)photo distance:(float)distance duration:(float)duration {
    self.layer.cornerRadius = 15.0f;

    if (photo.name && [photo.name length]) {
        _lblAddress.text =  photo.name;
    } else {
        _lblAddress.text = @"";
    }
    [_lblAddress sizeToFit];

    _lblPhone.text = [NSString stringWithFormat:@"%@", photo.notes];
    
//    _lblDistance.text = [NSString stringWithFormat:@"%0.f m", distance];
//    
//    _lblDuration.text = [NSString stringWithFormat:@"%0.f mins", duration];
//
//    if (shop.sPromotion && [shop.sPromotion length]) {
//        _lblPromotion.hidden = NO;
//        _txtPromotion.hidden = NO;
//
//        CGRect lblProRect = _lblPromotion.frame;
//        lblProRect.origin.y = _lblDuration.frame.origin.y + _lblDuration.frame.size.height + 3;
//        _lblPromotion.frame = lblProRect;
//        
//        CGRect txtProRect = _txtPromotion.frame;
//        txtProRect.origin.y = _lblPromotion.frame.origin.y + _lblPromotion.frame.size.height + 3;
//        _txtPromotion.frame = txtProRect;
//        
//    } else {
//        _lblPromotion.hidden = YES;
//        _txtPromotion.hidden = YES;
//    }
//    
//    [self shadowBackground];
//    [self setNeedsDisplay];
}

- (void) shadowBackground {
    CALayer *cellLayer = self.layer;
    cellLayer.shadowColor = [UIColor blackColor].CGColor;
    cellLayer.shadowOffset = CGSizeMake(0.0, 0.0);
    cellLayer.shadowRadius = kShadowRadius;
    cellLayer.shadowOpacity = kShadowOpacity;
    
    CGSize size = self.bounds.size;
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    
    //Draw top
    [shadowPath moveToPoint:CGPointMake(8.0, 0.0)];
    [shadowPath addLineToPoint:CGPointMake(8.0, -kShadowRadius)];
    [shadowPath addLineToPoint:CGPointMake(size.width - 14, -kShadowRadius)];
    [shadowPath addLineToPoint:CGPointMake(size.width - 14, 0.0)];
    
    //Draw left
    [shadowPath moveToPoint:CGPointMake(-kShadowRadius, 10.0)];
    [shadowPath addLineToPoint:CGPointMake(0.0, 10.0)];
    [shadowPath addLineToPoint:CGPointMake(8.0, size.height - 16)];
    [shadowPath addLineToPoint:CGPointMake(-kShadowRadius, size.height - 16)];
    
    //Draw right
    [shadowPath moveToPoint:CGPointMake(size.width, 10.0)];
    [shadowPath addLineToPoint:CGPointMake(size.width + kShadowRadius, 10.0)];
    [shadowPath addLineToPoint:CGPointMake(size.width + kShadowRadius, size.height - 16)];
    [shadowPath addLineToPoint:CGPointMake(size.width, size.height - 16)];
    
    //Draw bottom
    [shadowPath moveToPoint:CGPointMake(10.0, size.height)];
    [shadowPath addLineToPoint:CGPointMake(10, size.height + kShadowRadius)];
    [shadowPath addLineToPoint:CGPointMake(size.width - 16, size.height + kShadowRadius)];
    [shadowPath addLineToPoint:CGPointMake(size.width - 16, size.height)];
    
    cellLayer.shadowPath = shadowPath.CGPath;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
