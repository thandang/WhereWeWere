//
//  HHShopInfoView.h
//  hayhat
//
//  Created by Than Dang on 7/26/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HHShopInfoDelegate;

@class WWPhoto;
@interface HHShopInfoView : UIView {
    __weak IBOutlet UILabel *txtShopName;
    __weak IBOutlet UILabel *txtAddress;
    __weak IBOutlet UILabel *txtPhone;
    __weak IBOutlet UIButton *btnArrow;
    
}

@property (nonatomic, weak) id<HHShopInfoDelegate>delegate;

- (id) loadViewFromNib;

- (void) configShopInfo:(WWPhoto *)photo;

@end

@protocol HHShopInfoDelegate <NSObject>

@optional
- (void) shopInfoDetailDidClick:(WWPhoto *)photo;

@end
