//
//  SSCalendarCache.h
//  eSchoolView
//
//  Created by Steven Preston on 8/11/13.
//  Copyright (c) 2013 Stellar16. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SSCalendarCache : NSCache

- (void)putEvents:(NSArray *)events;
- (void)putEvents:(NSArray *)events ForYear:(NSInteger)year Month:(NSInteger)month;
- (NSArray *)getEventsForYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day;
- (BOOL)areEventsLoadedForYear:(NSInteger)year Month:(NSInteger)month;

@end
