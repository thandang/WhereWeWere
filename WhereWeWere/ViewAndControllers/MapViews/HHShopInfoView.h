//
//  HHShopInfoView.h
//  hayhat
//
//  Created by Than Dang on 7/26/14.
//  Copyright (c) 2014 soyo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BFPaperButton;
@protocol HHShopInfoDelegate;

@class WWPhoto;
@interface HHShopInfoView : UIView {
    __weak  UILabel *_txtShopName;
    __weak  UILabel *_txtNotes;
    __weak  UIImageView *_img;
    __weak BFPaperButton *_btnBackground;
}

@property (nonatomic, weak) id<HHShopInfoDelegate>delegate;


- (void) configShopInfo:(WWPhoto *)photo;

@end

@protocol HHShopInfoDelegate <NSObject>

@optional
- (void) shopInfoDetailDidClick:(WWPhoto *)photo;

@end
