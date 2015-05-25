//
//  SDMQueryOperation.m
//  Metermaid
//
//  Created by Dang Thanh Than on 1/20/15.
//  Copyright (c) 2015 Apide. All rights reserved.
//

#import "SDMQueryOperation.h"
#import "FMDatabase.h"
#import "WWPhoto.h"

@interface SDMQueryOperation ()

@property (nonatomic, strong) NSString  *queryString;
@property (nonatomic, weak) FMDatabase  *db;
@property (nonatomic, assign) QUERY_TYPE query_type;
@property (nonatomic, strong) NSDictionary *param;
@property (nonatomic, strong) NSString  *table;

- (NSArray *) queryDataWithQuery:(NSString *) query;
- (BOOL) queryUpdateDataWithQuery:(NSString *) query;
- (BOOL) queryAddRecortWithQuery:(NSString *) query withParam:(NSDictionary *)param;

@end

@implementation SDMQueryOperation

- (instancetype) initWithQuery:(NSString *)query paramInsert:(NSDictionary *)param onTable:(NSString *)table onDB:(FMDatabase *)db type:(QUERY_TYPE)type {
    self = [super init];
    if (self) {
        self.queryString = query;
        self.db = db;
        self.query_type = type;
        self.param = param;
        self.table = table;
    }
    return self;
}

#pragma mark - Main Operation
- (void) main {
    @autoreleasepool {
        if (!self.isCancelled) {
            if ([self.queryString length] == 0)
                return;
            if (self.query_type == UPDATE_QUERY || self.query_type == DELETE_QUERY || self.query_type == DELETE_ALL) {
                BOOL success = [self queryUpdateDataWithQuery:self.queryString];
                dispatch_async(dispatch_get_main_queue(), ^{ //run on main thread
                    if (self.delegate && [self.delegate respondsToSelector:@selector(operation:didInsertOrUpdateSuccess:)]) {
                        [self.delegate operation:self didInsertOrUpdateSuccess:success];
                    }
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                });
            } else if (self.query_type == INSERT_QUERY) {
                if (self.param) {
                    BOOL success = [self queryAddRecortWithQuery:self.queryString withParam:self.param];
                    dispatch_async(dispatch_get_main_queue(), ^{ //run on main thread
                        if (self.delegate && [self.delegate respondsToSelector:@selector(operation:didInsertOrUpdateSuccess:)]) {
                            [self.delegate operation:self didInsertOrUpdateSuccess:success];
                        }
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    });
                }
                
            } else if(self.query_type == QUERY_NORMAL || self.query_type == QUERY_ONE) {
                NSArray *resultArray = [self queryDataWithQuery:self.queryString];
                dispatch_async(dispatch_get_main_queue(), ^{ //run on main thread
                    if (self.delegate && [self.delegate respondsToSelector:@selector(operation:didFinishedWithResult:)]) {
                        [self.delegate operation:self didFinishedWithResult:resultArray];
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    }
                });
            }
        }
    }
}


- (NSArray *) queryDataWithQuery:(NSString *)query {
    //TODO: Handle query here
    FMResultSet *rs = [_db executeQuery:query];
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    while ([rs next]) {
        WWPhoto *photo = [[WWPhoto alloc] initFromResultSet:rs];
        [resultArr addObject:photo];
    }
    return resultArr;
}

- (BOOL) queryUpdateDataWithQuery:(NSString *)query {
    return [_db executeUpdate:self.queryString];
}

- (BOOL) queryAddRecortWithQuery:(NSString *)query  withParam:(NSDictionary *)param {
    return [self.db executeUpdate:self.queryString withParameterDictionary:param];
}


@end
