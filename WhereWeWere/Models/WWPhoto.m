//
//  WWPhoto.m
//  WhereWeWere
//
//  Created by Than Dang on 5/25/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import "WWPhoto.h"
#import "FMResultSet.h"

@implementation WWPhoto

- (instancetype) init {
    self = [super init];
    if (self) {
        self.photoId = [WWUtils randomNumber:1 upper:99999];
    }
    return self;
}

- (instancetype) initFromResultSet:(FMResultSet *)rs {
    self = [super init];
    if (self) {
        self.photoId = [rs intForColumn:kPhotoId];
        self.name = [rs stringForColumn:kName];
        self.dateSaved = [WWUtils stringToDateTime:[rs stringForColumn:kDateSave] withFormat:kDateTimeFormatServer];
        self.latitude = [rs doubleForColumn:kLatitude];
        self.longitude = [rs doubleForColumn:kLongitude];
        self.notes = [rs stringForColumn:kNotes];
    }
    return self;
}

@end
