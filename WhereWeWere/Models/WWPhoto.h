//
//  WWPhoto.h
//  WhereWeWere
//
//  Created by Than Dang on 5/25/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMResultSet;

@interface WWPhoto : NSObject

@property (nonatomic, assign) NSInteger photoId;
@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *notes;
@property (nonatomic, strong) NSDate    *dateSaved;
@property (nonatomic, strong) UIImage   *image;
@property (nonatomic, strong) UIImage   *thumbnail;
@property (nonatomic, assign) double     latitude;
@property (nonatomic, assign) double     longitude;

- (instancetype) initFromResultSet:(FMResultSet *)rs;

@end
