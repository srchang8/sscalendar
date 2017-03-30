//
//  SSCalendarWeekView.m
//  Pods
//
//  Created by Steven Preston on 7/26/13.
//  Copyright (c) 2013 Stellar16. All rights reserved.
//

#import "SSCalendarWeekViewController.h"
#import "SSCalendarMonthlyHeaderView.h"
#import "SSCalendarWeekLayout.h"
#import "SSCalendarDayCell.h"
#import "SSYearNode.h"
#import "SSMonthNode.h"
#import "SSDayNode.h"
#import "SSConstants.h"

@implementation SSCalendarWeekViewController

#pragma mark - Lifecycle Methods

- (id)initWithView:(UICollectionView *)view
{
    self = [super init];
    if (self)
    {
        self.view = view;

        view.collectionViewLayout = [[SSCalendarWeekLayout alloc] init];
        view.pagingEnabled = NO;
        view.allowsMultipleSelection = NO;

        NSBundle *bundle = [SSCalendarUtils calendarBundle];
        [view registerNib:[UINib nibWithNibName:@"SSCalendarDayCell" bundle:bundle] forCellWithReuseIdentifier:@"DayCell"];
        [view registerNib:[UINib nibWithNibName:@"SSCalendarMonthlyHeaderView" bundle:bundle] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MonthlyHeaderView"];
    }
    return self;
}


- (void)updateLayoutForBounds:(CGRect)bounds
{
    [((SSCalendarWeekLayout *) _view.collectionViewLayout) updateLayoutForBounds:bounds];
}


#pragma mark - Setter Methods

- (void)setYears:(NSArray *)years
{
    _years = [years copy];
    
    NSMutableArray *newDays = [NSMutableArray array];
    for (SSYearNode *year in _years)
    {
        [newDays addObjectsFromArray:year.days];
    }

    /*
    SSYearNode *firstYear = [_years objectAtIndex:0];
    NSInteger weekday = firstYear.weekdayOfFirstDay - 1;
    
    //Add days to the beginning of our days array so that they start on a Sunday.
    for (NSInteger i = weekday; i >= 0; i--)
    {
        //TODO: Constants
        NSInteger count = weekday - i;
        SSDayNode *day = [[SSDayNode alloc] initWithValue:31 - count Month:12 Year:firstYear.value - 1 Weekday:weekday];
        // [newDays insertObject:day atIndex:0];
    }
    
    
    //Add days to the end of our days array so that they end on a Saturday.
    SSDayNode *lastDay = [newDays lastObject];
    NSInteger numberOfMissingDays = 6 - lastDay.weekday;
    
    for (int i = 1; i <= numberOfMissingDays; i++)
    {
        NSInteger nextYear = ((SSYearNode *) [_years lastObject]).value + 1;
        SSDayNode *day = [[SSDayNode alloc] initWithValue:i Month:1 Year:nextYear Weekday:lastDay.weekday + i];
        // [newDays addObject:day];
    }
    */

    days = [newDays copy];
    
    //Set the start date.
    SSDayNode *startDay = [days objectAtIndex:0];
    startDate = startDay.date;
}


#pragma mark - Getter Methods

- (NSArray *)days
{
    return days;
}


- (NSDate *)startDate
{
    return startDate;
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _years.count * 12;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger yearIndex = section / 12;
    NSInteger monthIndex = section % 12;

    SSYearNode *year = [_years objectAtIndex:yearIndex];
    SSMonthNode *month = [year.months objectAtIndex:monthIndex];

    return month.dayCount + month.weekdayOfFirstDay;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DayCell";
    SSCalendarDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.style = SSCalendarDayCellStyleWeekly;

    NSInteger yearIndex = indexPath.section / 12;
    NSInteger monthIndex = indexPath.section % 12;

    SSYearNode *year = [_years objectAtIndex:yearIndex];
    SSMonthNode *month = [year.months objectAtIndex:monthIndex];

    NSInteger dayIndex = indexPath.row - month.weekdayOfFirstDay;

    if (dayIndex >= 0)
    {
        SSDayNode *day = [month.dayNodes objectAtIndex:dayIndex];
        cell.day = day;
    }
    else
    {
        cell.day = nil;
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SSCalendarMonthlyHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MonthlyHeaderView" forIndexPath:indexPath];

    NSInteger yearIndex = indexPath.section / 12;
    NSInteger monthIndex = indexPath.section % 12;

    SSYearNode *year = [_years objectAtIndex:yearIndex];
    SSMonthNode *month = [year.months objectAtIndex:monthIndex];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    view.label.text = [[[formatter shortMonthSymbols] objectAtIndex:monthIndex] uppercaseString];
    view.label.textColor = [UIColor colorWithHexString:COLOR_SECONDARY];

    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionView.collectionViewLayout;
    CGFloat labelOffset = month.weekdayOfFirstDay * layout.itemSize.width + 6.0f;

    view.leadingConstraint.constant = labelOffset;

    return view;
}



@end
