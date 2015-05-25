//
//  SDMQueryOperation.h
//  Metermaid
//
//  Created by Dang Thanh Than on 1/20/15.
//  Copyright (c) 2015 Apide. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    INSERT_QUERY,
    UPDATE_QUERY,
    DELETE_QUERY,
    DELETE_ALL,
    QUERY_NORMAL,
    QUERY_ONE
}QUERY_TYPE;

@protocol SDMQueryOperationDelegate;
@class FMDatabase;

@interface SDMQueryOperation : NSOperation

- (instancetype) initWithQuery:(NSString *)query paramInsert:(NSDictionary *)param onTable:(NSString *)table onDB:(FMDatabase *)db type:(QUERY_TYPE)type;

@property (nonatomic, weak) id<SDMQueryOperationDelegate> delegate;


@end

@protocol SDMQueryOperationDelegate <NSObject>
@optional
- (void) operation:(SDMQueryOperation *)op didFinishedWithResult:(NSArray *)result;
- (void) operation:(SDMQueryOperation *)op didInsertOrUpdateSuccess:(BOOL) success;

@end
