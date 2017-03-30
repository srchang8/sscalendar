//
//  SSCalendarDailyViewController.m
//  Pods
//
//  Created by Steven Preston on 7/26/13.
//  Copyright (c) 2013 Stellar16. All rights reserved.
//

#import "SSCalendarDailyViewController.h"
#import "SSCalendarDayCell.h"
#import "SSCalendarEventsCell.h"
#import "SSCalendarDayViewController.h"
#import "SSCalendarWeekViewController.h"
#import "SSCalendarWeekHeaderView.h"
#import "SSDayNode.h"
#import "SSConstants.h"
#import "SSDataController.h"

@interface SSCalendarDailyViewController()

@property (nonatomic, strong) SSDataController *dataController;

- (void)scrollWeekViewToDay;
- (void)scrollDayViewToDay;
- (void)selectDayInWeekView;
- (void)reloadDayLabel;

@end

@implementation SSCalendarDailyViewController

#pragma mark - Lifecycle Methods

- (id)initWithEvents:(NSArray *)events
{
    NSBundle *bundle = [SSCalendarUtils calendarBundle];
    if (self = [super initWithNibName:@"SSCalendarDailyViewController" bundle:bundle]) {
        self.dataController = [[SSDataController alloc] init];
        [_dataController setEvents:events];
        self.years = _dataController.calendarYears;
    }
    return self;
}


- (id)initWithDataController:(SSDataController *)dataController
{
    NSBundle *bundle = [SSCalendarUtils calendarBundle];
    if (self = [super initWithNibName:@"SSCalendarDailyViewController" bundle:bundle]) {
        self.dataController = dataController;
        self.years = _dataController.calendarYears;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = nil;
    
    todayBarButtonItem.title = @"Today";
    
    headerView.backgroundColor = [UIColor colorWithHexString:COLOR_BACKGROUND_OFF_WHITE];
    separatorView.backgroundColor = [UIColor colorWithHexString:COLOR_SEPARATOR];
    separatorViewHeightConstraint.constant = [SSDimensions onePixel];

    self.weekViewController = [[SSCalendarWeekViewController alloc] initWithView:_weekView];
    _weekView.dataSource = _weekViewController;
    _weekView.delegate = self;
     
    self.dayViewController = [[SSCalendarDayViewController alloc] initWithView:_dayView];
    _dayView.dataSource = _dayViewController;
    _dayView.delegate = self;
    
    _weekViewController.years = _years;
    _dayViewController.days = _weekViewController.days;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SSStyles hideShadowOnNavigationBar:self.navigationController.navigationBar];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SSStyles showShadowOnNavigationBar:self.navigationController.navigationBar];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [_weekViewController updateLayoutForBounds:_weekView.bounds];
    // reloadData seems to be required to invalidate the collection view and lay it out correctly. Only needed for 2nd and onwards view loads on a month that has already been viewed.
    [_weekView reloadData];

    [self scrollWeekViewToDay];
    [self scrollDayViewToDay];
    [self selectDayInWeekView];
    [self reloadDayLabel];
}


- (void)refresh
{
    [_weekView reloadData];
    [self selectDayInWeekView];
    BOOL requestMade = NO;//[[SSDataController shared] requestEventsWithYear:_day.year Month:_day.month];
    if (requestMade)
    {
        [_dayView reloadData];
    }
}


#pragma mark - Setter Methods

- (void)setDay:(SSDayNode *)day
{
    _day = day;

    BOOL requestMade = NO;//[[SSDataController shared] requestEventsWithYear:_day.year Month:_day.month];
    if (requestMade)
    {
        [_dayView reloadData];
    }
}


#pragma mark - UI Action Methods

- (IBAction)todayPressed:(id)sender
{
    NSDateComponents *components = [[SSCalendarUtils calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    
    for (SSDayNode *day in _weekViewController.days)
    {
        if ([day isEqualToDateComponents:components])
        {
            self.day = day;
            [self scrollWeekViewToDay];
            [self scrollDayViewToDay];
            [self selectDayInWeekView];
            [self reloadDayLabel];
            break;
        }
    }
}


#pragma mark - UI Helper Methods

- (void)scrollWeekViewToDay
{
    NSDate *start = _weekViewController.startDate;
    NSDate *current = [SSCalendarUtils dateWithYear:_day.year Month:_day.month Day:1];
    NSInteger offset = [SSCalendarUtils weekdayOfDate:start] - 1;

    NSInteger weeks = ([SSCalendarUtils numberOfDaysFrom:start To:current] + offset) / 7;
    NSInteger months = [SSCalendarUtils numberOfMonthsFrom:start To:current];

    // If the first day of a month is not a Sunday, the week is split between two months and takes two rows of height.
    NSInteger breaks = 0;
    NSInteger startYear = [SSCalendarUtils yearOfDate:start];
    NSInteger endYear = [SSCalendarUtils yearOfDate:current];
    for (NSInteger year = startYear; year <= endYear; year++) {
        NSInteger startMonth = year == startYear ? [SSCalendarUtils monthOfDate:start] + 1: 1;
        NSInteger endMonth = year == endYear ? [SSCalendarUtils monthOfDate:current] : 12;
        for (NSInteger month = startMonth; month <= endMonth; month++) {
            NSDate *first = [SSCalendarUtils dateWithYear:year Month:month Day:1];
            NSInteger weekdayOfFirstDay = [SSCalendarUtils weekdayOfDate:first] - 1;
            if (weekdayOfFirstDay != 0) breaks++;
        }
    }

    // height of week row. TODO: define a constant, use it everywhere
    CGFloat weekHeight = 43.0;

    // height of month name row. TODO: define a constant, use it everywhere
    CGFloat monthHeight = 34.0;

    CGFloat y = (weeks + breaks) * weekHeight + months * monthHeight;

    [_weekView setContentOffset: CGPointMake(0, y) animated: TRUE];
}


- (void)scrollDayViewToDay
{
    if ([_dayViewController.day isEqual:_day])
    {
        return;
    }
    [_dayViewController scrollToDay:_day animated:YES];
}


- (void)selectDayInWeekView
{
    NSIndexPath *indexPath = [self getIndexPathForDay: _day];
    [_weekView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
}


- (NSIndexPath*)getIndexPathForDay:(SSDayNode*)day
{
    NSInteger months = [SSCalendarUtils numberOfMonthsFrom:_weekViewController.startDate To:day.date];

    NSDate *first = [SSCalendarUtils dateWithYear:day.year Month:day.month Day:1];
    NSInteger weekdayOfFirstDay = [SSCalendarUtils weekdayOfDate:first] - 1;
    NSInteger days = [SSCalendarUtils dayOfDate:day.date];

    return [NSIndexPath indexPathForRow:days-1+weekdayOfFirstDay inSection:months];
}


- (void)reloadDayLabel
{
    //TODO: Constant
    NSDate *date = [_day date];
    _dateLabel.text = [StellarConversionUtils stringFromDate:date withFormat:@"EEEE MMMM d, yyyy"];
}


#pragma mark - UICollectionViewDelegateMethods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _weekView)
    {
        SSCalendarDayCell *cell = (SSCalendarDayCell *) [collectionView cellForItemAtIndexPath:indexPath];
        self.day = cell.day;
        
        [self scrollDayViewToDay];
        [self reloadDayLabel];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _dayView)
    {
        NSInteger index = (NSInteger) (_dayView.contentOffset.x / _dayView.bounds.size.width);
        SSDayNode *day = [_dayViewController.visibleDays objectAtIndex:index];

        self.day = day;
        _dayViewController.day = day;
        [_dayViewController reloadDay];

        // make sure that new cell is fully visible, scroll if necessary
        NSIndexPath *dayPath = [self getIndexPathForDay: day];
        UIView *cell = [_weekView cellForItemAtIndexPath: dayPath];
        CGFloat cellTop = [cell frame].origin.y - [_weekView contentOffset].y;
        CGFloat cellBottom = cellTop + [cell frame].size.height;
        CGFloat frameBottom = [_weekView frame].size.height;
        if (cellTop <= 0.0 || cellBottom > frameBottom) {
            [self scrollWeekViewToDay];
            [_weekView reloadData]; // make selected day visible
        }

        [self selectDayInWeekView];
        [self reloadDayLabel];
    }
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == _dayView)
    {
        [_dayViewController reloadDay];
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _dayView)
    {
        return _dayView.bounds.size;
    }
    else
    {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) _weekView.collectionViewLayout;
        return layout.itemSize;
    }
}

@end
