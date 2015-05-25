//
//  AOCaptureViewController.h
//  AlphaOmega
//
//  Created by Dang Thanh Than on 4/1/15.
//  Copyright (c) 2015 Apide Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BFPaperButton;
@interface AOCaptureViewController : UIViewController {
    __weak  BFPaperButton *btnClose;
    __weak  BFPaperButton *btnAccept;
    __weak  UIImageView *imgResult;
    
}

+ (void)addAdjustingAnimationToLayer:(CALayer *)layer removeAnimation:(BOOL)remove;

@end
