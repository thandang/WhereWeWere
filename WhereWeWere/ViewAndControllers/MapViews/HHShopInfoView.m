//
//  HHShopInfoView.m
//  hayhat
//
//  Created by Than Dang on 7/26/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import "HHShopInfoView.h"
#import "WWPhoto.h"
#import "BFPaperButton.h"

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
        self.backgroundColor = kCOLOR_BACKGROUND;
        if (!_txtShopName) {
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 3.0, frame.size.width - 60, 21.0)];
            lbl.font = kDefaultFontButton;
            lbl.textColor = [UIColor whiteColor];
            [self addSubview:lbl];
            _txtShopName = lbl;
        }
        if (!_txtNotes) {
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 25.0, frame.size.width - 60, 30.0)];
            lbl.font = kTimeFont;
            lbl.textColor = [UIColor whiteColor];
            [self addSubview:lbl];
            _txtNotes = lbl;
        }
        if (!_img) {
            UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 50.0, (frame.size.height - 40.0)/2, 40.0, 40.0)];
            [self addSubview:imv];
            _img = imv;
        }
    }
    return self;
}



- (void) configShopInfo:(WWPhoto *)photo {
    self.backgroundColor = kCOLOR_BACKGROUND;
    _txtShopName.text = photo.name;
    
    _txtNotes.frame = CGRectMake(_txtShopName.frame.origin.x, _txtShopName.frame.size.height + _txtShopName.frame.origin.y + 2, 275.0, _txtShopName.frame.size.height);
    _txtNotes.numberOfLines = 0;
    _txtNotes.text = [NSString stringWithFormat:@"Notes: %@", photo.notes];
    [_txtNotes sizeToFit];
    
    
    _img.image = photo.image;
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


- (void)detailClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shopInfoDetailDidClick:)]) {
        [self.delegate shopInfoDetailDidClick:_photo];
    }
}


@end
