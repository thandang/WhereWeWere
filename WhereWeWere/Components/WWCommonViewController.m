//
//  WWCommonViewController.m
//  WhereWeWere
//
//  Created by Dang Thanh Than on 5/25/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import "WWCommonViewController.h"
#import "MBProgressHUD.h"

@interface WWCommonViewController () {
    MBProgressHUD   *_myHUD;
}

@end

@implementation WWCommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showHUD {
    if (!_myHUD) {
        _myHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

- (void) hideHUD {
    [_myHUD hide:YES];
    _myHUD = nil;
}

@end
