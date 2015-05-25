//
//  SDMDataManager.h
//  Metermaild
//
//  Created by Dang Thanh Than on 1/19/15.
//  Copyright (c) 2015 Apide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
@class FFPhoto;

@interface SDMDataManager : NSObject

@property (nonatomic, readonly) FMDatabase  *database;
@property (nonatomic, strong) id   controller;

+ (SDMDataManager *) sharedInstance;
- (void) close;
- (void) cancelAllOperation;

- (void) savePhoto: (FFPhoto *)photo;
- (void) getPhotos;
- (void) deletePhoto:(NSInteger)photoId;

@end
