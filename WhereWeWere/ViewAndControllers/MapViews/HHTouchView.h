//
//  HHTouchView.h
//  hayhat
//
//  Created by Than Dang on 3/9/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHTouchView : UIView {
    SEL     _hitTouch;
}

@property (assign) id   caller;
@property (assign) SEL  hitTouch;

@end
