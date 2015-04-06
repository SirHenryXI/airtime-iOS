//
//  CATimeConverter.m
//  AirTime
//
//  Created by Chase Acton on 11/20/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import "CATimeConverter.h"
#import "NSDate+Utilities.h"

@implementation CATimeConverter

+ (NSString *)formatTime:(NSString *)input{
    //Harvest returns all time logged in hours, ex. 1.32 hours.
    //Convert this to hours and minutes and display properly
    float hoursFloat = [input floatValue];  //Get float value of hours
    int minutesInt = hoursFloat * 60;       //Convert to minutes
    int hours = minutesInt / 60;
    int minutes = minutesInt % 60;
    if (minutes == 0){
        //Don't show minutes if 0
        return [NSString stringWithFormat:@"%i:00",hours];
    }else{
        return [NSString stringWithFormat:@"%i:%02u",hours,minutes];
    }
    
//    let labelText:String = String(format: "%u:%02u:%02u", hours,minutes,seconds)

}

+ (NSString *)formatDate:(NSString *)input{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *capturedStartDate = [dateFormatter dateFromString:input];
    
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"EEEE"];
    NSString *weekdayString = [weekday stringFromDate:capturedStartDate];
    
    if ([capturedStartDate isToday]){
        return @"Today";
    }else if ([capturedStartDate isYesterday]){
        return @"Yesterday";
    }
    return weekdayString;
}

@end