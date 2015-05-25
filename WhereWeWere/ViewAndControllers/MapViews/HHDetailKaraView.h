//
//  HHDetailKaraView.h
//  hayhat
//
//  Created by Than Dang on 8/22/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WWPhoto;
@interface HHDetailKaraView : UIView {
    
    __weak IBOutlet UILabel *_lblAddress;
    __weak IBOutlet UILabel *_lblPhone;
    __weak IBOutlet UILabel *_lblDistance;
    __weak IBOutlet UILabel *_lblDuration;
    __weak IBOutlet UILabel *_lblPromotion;
    __weak IBOutlet UITextView *_txtPromotion;
}

- (id) loadViewFromNib;

- (void) configViewWith:(WWPhoto *)photo distance:(float) distance duration:(float)duration;

@end
