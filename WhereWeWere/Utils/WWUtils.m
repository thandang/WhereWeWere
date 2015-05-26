//
//  WWUtils.m
//  WhereWeWere
//
//  Created by Dang Thanh Than on 5/25/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import "WWUtils.h"
#import "AppDelegate.h"
#import "NSString+Util.h"


@implementation WWUtils

+ (NSString *) getDBVersion {
    NSUserDefaults *uDefault = [NSUserDefaults standardUserDefaults];
    NSString *dbVersion = [uDefault stringForKey:DATABASE_VERSION];
    return dbVersion;
}

+ (BOOL) setDBVersion:(NSString *)version {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:version forKey:DATABASE_VERSION];
    return [ud synchronize];
}


+ (NSDate *) stringToDateTime:(NSString *)stringDate withFormat:(NSString *)format {
    if (nil == stringDate || [stringDate isKindOfClass:[NSNull class]] || [stringDate length] == 0 || [stringDate isEqualToString:@"null"]) return nil;
    //Setup timezone
    // Set up an NSDateFormatter for UTC time zone
    NSDateFormatter* formatterUtc = [[NSDateFormatter alloc] init];
    [formatterUtc setDateFormat:format];
    //    [formatterUtc setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    //    [formatterUtc setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    // Cast the input string to NSDate
    NSDate* utcDate = [formatterUtc dateFromString:stringDate];
    return utcDate;
}

+ (NSString *) dateToString:(NSDate *)date withFormat:(NSString *)format {
    if (nil == date) return @"";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormat setDateFormat:format];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    return [dateFormat stringFromDate:date];
}

+ (void) hideKeyboard:(UIView *)topView {
    for (UIView *v in [topView subviews]) {
        if ([v isKindOfClass:[UITextField class]] || [v isKindOfClass:[UITextView class]]) {
            [v resignFirstResponder];
        } else {
            [self hideKeyboard:v];
        }
    }
}

+ (NSInteger) compareFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    if (!fromDate || !toDate) {
        return -1;
    }
    NSDate *today = nil;
    NSDate *beginningOfOtherDate = nil;
    
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&today interval:NULL forDate:fromDate];
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&beginningOfOtherDate interval:NULL forDate:toDate];
    
    if([today compare:beginningOfOtherDate] == NSOrderedSame) {
        return 0;
    } else if ([today compare:beginningOfOtherDate] == NSOrderedDescending){
        return -1;
    } else {
        return 1;
    }
}


+ (void) hideKeyboard:(UIView *)topView completion:(void (^)(BOOL))completion {
    int i = 0;
    for (UIView *v in [topView subviews]) {
        i++;
        if ([v isKindOfClass:[UITextField class]] || [v isKindOfClass:[UITextView class]]) {
            [v resignFirstResponder];
        } else {
            [self hideKeyboard:v];
        }
        if (i == [[topView subviews] count]) {
            if (completion) {
                completion(YES); //handle completion block
            }
        }
    }
}

+ (CGRect) getMainScreenBounds {
    return [UIScreen mainScreen].bounds;
}

+ (float) widthWithText:(NSString *)text andFont:(UIFont *)font {
    CGSize lineSize = [text sizeWithAttributes:@{NSFontAttributeName:font}];
    return lineSize.width;
}

+ (BOOL) isNumberic:(NSString *)value {
    if (!value || (value && [[value removeSpace] length] < 1)) {
        return YES;
    }
    BOOL valid = NO;;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:[value removeSpace]];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    
    return valid;
}

+ (int) randomNumber:(int)lower upper:(int)upper {
    int rndValue = lower + arc4random() % (upper - lower);
    return rndValue;
}

+ (NSDate *) getTimeFromDate:(NSDate *)date {
    if (!date) {
        return [NSDate date];
    }
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned    unitFlagTime = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *timeComponents = [gregorianCalendar components: unitFlagTime fromDate:date];
    
    unsigned unitFlagDate = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *resultDate = [gregorianCalendar components:unitFlagDate | unitFlagTime fromDate:[NSDate date]];
    [resultDate setHour:timeComponents.hour];
    [resultDate setMinute:timeComponents.minute];
    [resultDate setSecond:timeComponents.second];
    return [gregorianCalendar dateFromComponents:resultDate];
}


+ (UIImage *) imageWithName:(NSString *)name {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathToSave = [[[DOCUMENT_FOLDER stringByAppendingPathComponent:FOLDER_PHOTOS] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"png"];
    if ([fileManager fileExistsAtPath:pathToSave isDirectory:nil]) {
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:pathToSave]];
    }
    return nil;
}

+ (UIView *) getMainView {
    return [kAppDelegate window].rootViewController.view;
}

+ (UIColor *)defaultBackgroundColor {
    return [UIColor colorWithRed:236.0f/255.0f
                           green:254.0f/255.0f
                            blue:255.0f/255.0f
                           alpha:1.0f];
}

+ (void)setRegionByCenter:(MKMapView *)mapView_ {
    if ([mapView_.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    for (id<MKAnnotation> annotation in mapView_.annotations) {
        topLeftCoord.longitude =
        fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude =
        fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude =
        fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude =
        fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude =
    topLeftCoord.latitude -
    (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude =
    topLeftCoord.longitude +
    (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    
    // add span
    region.span.latitudeDelta =
    fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    region.span.longitudeDelta =
    fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    // add region
    region = [mapView_ regionThatFits:region];
    [mapView_ setRegion:region];
}

@end
