//
//  SDMDataManager.m
//  Metermaild
//
//  Created by Dang Thanh Than on 1/19/15.
//  Copyright (c) 2015 Apide. All rights reserved.
//

#import "SDMDataManager.h"
#import "SDMQueryOperation.h"
#import "WWPhoto.h"


@interface SDMDataManager ()

@property (nonatomic, strong) NSOperationQueue  *queryQueue;


@end
@implementation SDMDataManager

+ (SDMDataManager *) sharedInstance {
    static SDMDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[SDMDataManager alloc] init];
        }
    });
    return instance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.queryQueue = [[NSOperationQueue alloc] init];
        self.queryQueue.maxConcurrentOperationCount = 1;
        
        NSString *dbVersion = [WWUtils getDBVersion];
        if (![dbVersion isEqualToString:CURRENT_DB_VERSION]) {
            [self copyDatabase];
        }
        
        if (!_database) {
            _database = [FMDatabase databaseWithPath:[DATABASE_FOLDER stringByAppendingPathComponent:DATABASE_NAME]];
        }
        
        
        DEBUG_LOG(@"database path: %@", [_database databasePath]);
        if (![_database open]) {
            return nil;
        }
    }
    return self;
}

- (void) dealloc {
    [self close];
}

- (void) close {
    [self.queryQueue cancelAllOperations];
    [self.database close];
}

- (void) cancelAllOperation {
    [self.queryQueue cancelAllOperations];
}

- (BOOL) copyDatabase {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path_db = [DATABASE_FOLDER stringByAppendingPathComponent:DATABASE_NAME];
    if (![fm fileExistsAtPath:DATABASE_FOLDER isDirectory:nil]) {
        [fm createDirectoryAtPath:DATABASE_FOLDER withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        if ([fm fileExistsAtPath:path_db isDirectory:nil]) {
            //handle to copy to new item here
            [fm removeItemAtPath:path_db error:nil];
        }
    }
    BOOL success = [fm copyItemAtPath:BUNDLE_DB_PATH toPath:path_db error:nil];
    if (success) {
        //handle for move or update item here
        [WWUtils setDBVersion:CURRENT_DB_VERSION];
    }
    return success;
}

- (void) savePhoto:(WWPhoto *)photo {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSDictionary *dictParam = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (long)photo.photoId], kPhotoId,
                               photo.name, kName,
                               [WWUtils dateToString:photo.dateSaved withFormat:kDateTimeFormatServer], kDateSave, [@(photo.latitude) stringValue], kLatitude, [@(photo.longitude) stringValue], kLongitude, photo.notes, kNotes, nil];
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ VALUES(:%@, :%@, :%@, :%@, :%@, :%@)", kPhotoTable, kPhotoId, kName, kDateSave, kLatitude, kLongitude, kNotes];
    SDMQueryOperation *opAction = [[SDMQueryOperation alloc] initWithQuery:query paramInsert:dictParam onTable:kPhotoTable onDB:_database type:INSERT_QUERY];
    opAction.delegate = self.controller;
    [self.queryQueue addOperation:opAction];
}

- (void) getPhotos {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC", kPhotoTable, kDateSave];
    SDMQueryOperation *opAction = [[SDMQueryOperation alloc] initWithQuery:query paramInsert:nil onTable:kPhotoTable onDB:_database type:QUERY_NORMAL];
    opAction.delegate = self.controller;
    [self.queryQueue addOperation:opAction];
}

- (void) deletePhoto:(NSInteger)photoId {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *query  = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%ld'", kPhotoTable, kPhotoId, (long)photoId];
    SDMQueryOperation *opAction = [[SDMQueryOperation alloc] initWithQuery:query paramInsert:nil onTable:kPhotoTable onDB:_database type:DELETE_ALL];
    opAction.delegate = self.controller;
    [self.queryQueue addOperation:opAction];
}

@end
