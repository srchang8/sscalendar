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
    
    self.dayViewController = [[SSCalendarDayViewController alloc] initWithView:_dayView];
    _dayView.dataSource = _dayViewController;
    
    _weekViewController.years = _years;
    _dayViewController.days = _weekViewController.days;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SSStyles hideShadowOnNavigationBar:self.navigationController.navigationBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _weekView.delegate = self;
    _dayView.delegate = self;
    [_weekView reloadData];
    [self scrollWeekViewToDay:TRUE];
    [self scrollDayViewToDay];
    [self reloadDayLabel];
    [self selectDayInWeekView];
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
            [self scrollWeekViewToDay:TRUE];
            [self scrollDayViewToDay];
            [self selectDayInWeekView];
            [self reloadDayLabel];
            break;
        }
    }
}


#pragma mark - UI Helper Methods

- (void)updateTitle:(NSDate*)date
{
    NSString *title = [StellarConversionUtils stringFromDate:date withFormat:@"MMMM yyyy"];
    [super setTitle:title];
}

- (BOOL)scrollWeekViewToDay:(BOOL)animated
{
    CGFloat frameHeight = [_weekView frame].size.height;
    CGFloat frameTop = [_weekView contentOffset].y;
    CGFloat frameBottom = frameTop + frameHeight;
    
    // make sure that new cell is fully visible, scroll if necessary
    NSIndexPath *dayPath = [self getIndexPathForDay: _day];
    UIView *cell = [_weekView cellForItemAtIndexPath: dayPath];
    if (cell) {
        CGFloat cellHeight = [cell frame].size.height;
        CGFloat cellTop = [cell frame].origin.y;
        CGFloat cellBottom = cellTop + cellHeight;
        if (cellTop >= frameTop && cellBottom <= frameBottom) {
            [self updateTitle:_day.date];
            return FALSE;
        }
    }
    
    NSDate *start = _weekViewController.startDate;
    NSDate *first = [SSCalendarUtils dateWithYear:_day.year Month:_day.month Day:1];
    NSDate *current = [_day date];
    
    NSInteger offsetStart = [SSCalendarUtils weekdayOfDate:start] - 1;
    NSInteger offsetFirst = [SSCalendarUtils weekdayOfDate:first] - 1;
    
    NSInteger weeksFirst = ([SSCalendarUtils numberOfDaysFrom:start To:first] + offsetStart) / 7;
    NSInteger monthsFirst = [SSCalendarUtils numberOfMonthsFrom:start To:first];
    
    NSInteger weeksCurrent = ([SSCalendarUtils numberOfDaysFrom:start To:current] + offsetStart) / 7;
    NSInteger monthsCurrent = [SSCalendarUtils numberOfMonthsFrom:start To:current] + 1;
    
    // If the first day of a month is not a Sunday, the week is split between two months and takes two rows of height.
    NSInteger breaks = 0;
    NSInteger startYear = [SSCalendarUtils yearOfDate:start];
    NSInteger endYear = [SSCalendarUtils yearOfDate:first];
    for (NSInteger year = startYear; year <= endYear; year++) {
        NSInteger startMonth = year == startYear ? [SSCalendarUtils monthOfDate:start] + 1: 1;
        NSInteger endMonth = year == endYear ? [SSCalendarUtils monthOfDate:first] : 12;
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
    
    CGFloat posFirst = (weeksFirst + breaks) * weekHeight + monthsFirst * monthHeight;
    CGFloat posCurrent = (weeksCurrent + breaks) * weekHeight + monthsCurrent * monthHeight;
    
    // scroll to start of month, or more if necessary to make current day fully visible
    CGFloat pos = MAX(posFirst, posCurrent + weekHeight - frameHeight);
    
    [_weekView setContentOffset: CGPointMake(0, pos) animated: animated];
    if (! animated) {
        [self updateTitle:_day.date];
    }
    // else scrollViewDidEndScrollingAnimation will call updateTitle
    
    return TRUE;
}


- (void)scrollDayViewToDay
{
    if (! [_dayViewController.day isEqual:_day])
    {
        [_dayViewController scrollToDay:_day animated:YES];
    }
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
        [self updateTitle:_day.date];
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
        if ([self scrollWeekViewToDay:TRUE]) {
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
    
    if (scrollView == _weekView)
    {
        [self updateTitle: _day.date];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _weekView)
    {
        CGFloat frameHeight = [_weekView frame].size.height;
        CGFloat frameTop = [_weekView contentOffset].y;
        CGFloat frameBottom = frameTop + frameHeight;
        
        SSDayNode *first = nil;
        for (SSCalendarDayCell *cell in _weekView.visibleCells)
        {
            SSDayNode *day = cell.day;
            if (day)
            {
                CGFloat cellHeight = [cell frame].size.height;
                CGFloat cellTop = [cell frame].origin.y;
                CGFloat cellBottom = cellTop + cellHeight;
                
                if (cellTop >= frameTop && cellBottom <= frameBottom)
                {
                    if (! first || [day isBefore: first]) first = day;
                }
            }
        }
        if (first) [self updateTitle:first.date];
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
