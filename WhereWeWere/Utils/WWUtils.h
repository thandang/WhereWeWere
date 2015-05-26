//
//  WWUtils.h
//  WhereWeWere
//
//  Created by Dang Thanh Than on 5/25/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WWUtils : NSObject

+ (NSDate *) stringToDateTime:(NSString *)stringDate withFormat:(NSString *) format;
+ (NSString *) dateToString:(NSDate *)date withFormat:(NSString *) format;
+ (NSInteger) compareFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

+ (void) hideKeyboard:(UIView *)topView;
+ (void) hideKeyboard:(UIView *)topView completion:(void(^)(BOOL finished))completion;

+ (BOOL) isNumberic:(NSString *)value;
+ (float) widthWithText:(NSString *)text andFont:(UIFont *)font;

+ (NSString *) getDBVersion;
+ (BOOL) setDBVersion:(NSString *) version;

+ (CGRect) getMainScreenBounds;

+ (int) randomNumber:(int)lower upper:(int)upper;

+ (UIImage *) imageWithName:(NSString *)name;

+ (UIView *) getMainView;
+ (UIColor *)defaultBackgroundColor;
+ (void)setRegionByCenter:(MKMapView *)mapView_;

@end
