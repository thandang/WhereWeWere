//
//  HHTouchView.m
//  hayhat
//
//  Created by Than Dang on 3/9/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import "HHTouchView.h"

@interface HHTouchView()
- (UIView *) hitAtPoint:(CGPoint) point withEvent:(UIEvent *) event;
@end

@implementation HHTouchView
@synthesize hitTouch = _hitTouch;
@synthesize caller;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (UIView *) hitAtPoint:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *rtnView = [self hitTest:point withEvent:event];
    if (![rtnView isKindOfClass:[UIButton class]]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [caller performSelector:_hitTouch];
        #pragma clang dianostic pop
    }
    return rtnView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
