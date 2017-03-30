//
//  SSCalendarUtils.m
//  Pods
//
//  Created by Steven Preston on 7/30/13.
//  Copyright (c) 2013 Stellar16. All rights reserved.
//

#import "SSCalendarUtils.h"

@implementation SSCalendarUtils


+ (NSBundle *)calendarBundle
{
    NSBundle *podBundle = [NSBundle bundleForClass:SSCalendarUtils.self];
    NSURL *bundleURL = [podBundle URLForResource:@"SSCalendar" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:bundleURL];
}

+ (NSCalendar *)calendar
{
    return [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
}


+ (NSInteger)currentYear
{
    NSCalendar *calendar = [SSCalendarUtils calendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return comps.year;
}


+ (NSInteger)numberOfMonthsInYear
{
    return 12;
}


+ (NSInteger)numberDaysInYear:(NSInteger)year
{
    NSDateComponents *comps = [SSCalendarUtils dateComponentsWithYear:year Month:1 Day:1];
    
    NSCalendar *calendar = [SSCalendarUtils calendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[calendar dateFromComponents:comps]];
    
    return range.length;
}


+ (NSInteger)numberOfDaysInMonth:(NSInteger)month Year:(NSInteger)year
{
    NSDateComponents *comps = [SSCalendarUtils dateComponentsWithYear:year Month:month Day:1];
    
    NSCalendar *calendar = [SSCalendarUtils calendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[calendar dateFromComponents:comps]];
    
    return range.length;
}


+ (NSInteger)numberOfDaysFrom:(NSDate *)startDate To:(NSDate *)endDate
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [SSCalendarUtils calendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:startDate];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:endDate];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    
    NSInteger days = difference.day;
    return days;
}

+ (NSInteger)numberOfMonthsFrom:(NSDate *)startDate To:(NSDate *)endDate
{
    NSDate *fromDate;
    NSDate *toDate;

    NSCalendar *calendar = [SSCalendarUtils calendar];

    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&fromDate interval:NULL forDate:startDate];
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&toDate interval:NULL forDate:endDate];

    NSDateComponents *difference = [calendar components:NSCalendarUnitMonth fromDate:fromDate toDate:toDate options:0];

    NSInteger months = difference.month;
    return months;
}


+ (NSDateComponents *)componentsOfDate:(NSDate *)date
{
    NSCalendar *calendar = [SSCalendarUtils calendar];
    return [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitWeekday fromDate:date];
}

+ (NSInteger)weekdayOfDate:(NSDate *)date
{
    return [self componentsOfDate:date].weekday;
}

+ (NSInteger)dayOfDate:(NSDate *)date
{
    return [self componentsOfDate:date].day;
}

+ (NSInteger)monthOfDate:(NSDate *)date
{
    return [self componentsOfDate:date].month;
}

+ (NSInteger)yearOfDate:(NSDate *)date
{
    return [self componentsOfDate:date].year;
}


+ (NSDate *)dateByAddingDays:(NSInteger)days To:(NSDate *)date
{
    NSCalendar *calendar = [SSCalendarUtils calendar];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.day = days;
    
    NSDate *newDate = [calendar dateByAddingComponents:comps toDate:date options:0];
    return newDate;
}


+ (NSDateComponents *)dateComponentsWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = year;
    comps.month = month;
    comps.day = day;
    
    return comps;
}


+ (NSDate *)dateWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day
{
    NSDateComponents *comps = [SSCalendarUtils dateComponentsWithYear:year Month:month Day:day];
    
    return [[SSCalendarUtils calendar] dateFromComponents:comps];
}


+ (BOOL)isDate1:(NSDate *)date1 theSameDayAs:(NSDate *)date2
{
    NSCalendar *calendar = [SSCalendarUtils calendar];
    NSDateComponents *comps1 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date1];
    NSDateComponents *comps2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date2];
    
    return comps1.year == comps2.year && comps1.month == comps2.month && comps1.day == comps2.day;

}

@end
