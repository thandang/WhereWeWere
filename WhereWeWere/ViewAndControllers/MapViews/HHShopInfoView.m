//
//  HHShopInfoView.m
//  hayhat
//
//  Created by Than Dang on 7/26/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import "HHShopInfoView.h"
#import "WWPhoto.h"

#define kShadowRadius 1.0
#define kShadowOpacity 0.7

@interface HHShopInfoView() {
    WWPhoto  *_photo;
}
@end

@implementation HHShopInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) loadViewFromNib {
    NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"HHShopInfoView" owner:self options:nil];
    for( id obj in nibViews ) {
        if( [obj isMemberOfClass:[HHShopInfoView class]] ) {
            return obj;
        }
    }
    
    for( id obj in nibViews ) {
        if( [obj isKindOfClass:[HHShopInfoView class]] ) {
            return obj;
        }
    }
    return nil;
}

- (void) configShopInfo:(WWPhoto *)photo {
    self.backgroundColor = kCOLOR_BACKGROUND;
    txtShopName.text = photo.name;
    txtShopName.numberOfLines = 0;
    [txtShopName sizeToFit];
    
    txtAddress.frame = CGRectMake(txtAddress.frame.origin.x, txtShopName.frame.size.height + txtShopName.frame.origin.y + 2, 275.0, txtAddress.frame.size.height);
    txtAddress.numberOfLines = 0;
    txtAddress.text = [NSString stringWithFormat:@"Notes: %@", photo.notes];
    [txtAddress sizeToFit];
    
    
    CGRect selfRect = self.frame;
    selfRect.size.height = txtAddress.frame.size.height + txtAddress.frame.origin.y + 5;
    self.frame = selfRect;
    
//    txtPhone.frame = CGRectMake(txtPhone.frame.origin.x, txtAddress.frame.origin.y + txtAddress.frame.size.height + 2, 275.0, txtPhone.frame.size.height);
//    txtPhone.text = [NSString stringWithFormat:@"Phone: %@", place.notes];
//    txtPhone.numberOfLines = 0;
//    [txtPhone sizeToFit];
    
    
//    CGRect selfRect = self.frame;
//    selfRect.size.height = txtPhone.frame.size.height + txtPhone.frame.origin.y + 5;
//    self.frame = selfRect;
    
    [btnArrow setFrame:CGRectMake(btnArrow.frame.origin.x, (selfRect.size.height - btnArrow.frame.size.height)/2, btnArrow.frame.size.width, btnArrow.frame.size.height)];
    _photo = photo;
    [self drawCellShadow];
    [self setNeedsDisplay];
}

- (void) drawCellShadow {
    //setup layer
    CALayer *cellLayer = self.layer;
    cellLayer.shadowColor = [UIColor blackColor].CGColor;
    cellLayer.shadowOffset = CGSizeMake(0.0, 0.0);
    cellLayer.shadowRadius = kShadowRadius;
    cellLayer.shadowOpacity = kShadowOpacity;
    
    CGSize size = self.bounds.size;
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    
    //Draw top
    [shadowPath moveToPoint:CGPointMake(0.0, 0.0)];
    [shadowPath addLineToPoint:CGPointMake(0.0, -kShadowRadius)];
    [shadowPath addLineToPoint:CGPointMake(size.width, -kShadowRadius)];
    [shadowPath addLineToPoint:CGPointMake(size.width, 0.0)];
    
    //Draw left
    [shadowPath moveToPoint:CGPointMake(-kShadowRadius, 0.0)];
    [shadowPath addLineToPoint:CGPointMake(0.0, 0.0)];
    [shadowPath addLineToPoint:CGPointMake(0.0, size.height)];
    [shadowPath addLineToPoint:CGPointMake(-kShadowRadius, size.height)];
    
    //Draw right
    [shadowPath moveToPoint:CGPointMake(size.width, 0.0)];
    [shadowPath addLineToPoint:CGPointMake(size.width + kShadowRadius, 0.0)];
    [shadowPath addLineToPoint:CGPointMake(size.width + kShadowRadius, size.height)];
    [shadowPath addLineToPoint:CGPointMake(size.width, size.height)];
    
    //Draw bottom
    [shadowPath moveToPoint:CGPointMake(0.0, size.height)];
    [shadowPath addLineToPoint:CGPointMake(0, size.height + kShadowRadius)];
    [shadowPath addLineToPoint:CGPointMake(size.width, size.height + kShadowRadius)];
    [shadowPath addLineToPoint:CGPointMake(size.width, size.height)];
    
    cellLayer.shadowPath = shadowPath.CGPath;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)detailClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shopInfoDetailDidClick:)]) {
        [self.delegate shopInfoDetailDidClick:_photo];
    }
}


@end
