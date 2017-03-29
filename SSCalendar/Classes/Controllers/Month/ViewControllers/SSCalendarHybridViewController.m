//
//  SSCalendarHybridViewController.m
//  calendart
//
//  Created by Good on 28/03/2017.
//  Copyright © 2017 Good. All rights reserved.
//

#import "SSCalendarHybridViewController.h"
#import "SSCalendarHybridDataSource.h"

#import "SSCalendarDailyViewController.h"
#import "SSCalendarDayCell.h"
#import "SSDayNode.h"

#import "SSYearNode.h"
#import "SSMonthNode.h"
#import "SSCalendarMonthlyHeaderView.h"
#import "SSConstants.h"
#import "SSCalendarDayCell.h"
#import "SSDataController.h"

@interface SSCalendarHybridViewController ()
@property (nonatomic, strong) SSDataController *dataController;
@property (nonatomic, strong) SSCalendarDailyViewController *dailyVC;

@end

@implementation SSCalendarHybridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [[SSCalendarHybridDataSource alloc] initWithView:_yearView];
    _yearView.dataSource = _dataSource;
    _yearView.delegate = self;
    
    _dataSource.years = _years;
    
    [self refresh];
    
    
    [self initializeDailyViewController];

}

- (void) initializeDailyViewController {
    int value = 1;
    int month = 3;
    int year = 2017;
    int weekday = 1;
    
    _dailyVC = [[SSCalendarDailyViewController alloc] initWithDataController:_dataController];
    SSDayNode *dat = [[SSDayNode alloc] initWithValue:value Month:month Year:year Weekday:weekday];
    _dailyVC.day = dat;
    [self addChildViewController:_dailyVC];
    _dailyVC.view.frame = _subViewEvents.bounds;
    [_subViewEvents addSubview:_dailyVC.view];
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
    [_dataSource updateLayoutForBounds:_yearView.bounds];
    
    if (_startingIndexPath != nil)
    {
        [self scrollToIndexPath:_startingIndexPath updateTitle:NO];
        self.startingIndexPath = nil;
    }
}


- (void)refresh
{
    SSCalendarCountCache *calendarCounts = _dataController.calendarCountCache;
    if (calendarCounts != nil)
    {
        [_dataController updateCalendarYears];
        [_yearView reloadData];
    }
}

- (id)initWithEvents:(NSArray *)events
{
    NSBundle *bundle = [SSCalendarUtils calendarBundle];
    if (self = [super initWithNibName:@"SSCalendarHybridViewController" bundle:bundle]) {
        self.dataController = [[SSDataController alloc] init];
        [_dataController setEvents:events];
        self.years = _dataController.calendarYears;
        
    }
    return self;
}

#pragma mark - UICollectionViewDelegateMethods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    SSCalendarDayCell *cell = (SSCalendarDayCell *) [collectionView cellForItemAtIndexPath:indexPath];
    
    
    _dailyVC.day = cell.day;
    [_dailyVC refreshEveything];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *visibleCells = [_yearView visibleCells];
    
    for (SSCalendarDayCell *cell in visibleCells)
    {
        if (cell.day != nil && cell.frame.origin.y >= 0)
        {
            self.title = [NSString stringWithFormat:@"%li", (long)cell.day.year];
            break;
        }
    }
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath updateTitle:(BOOL)updateTitle
{
    [_yearView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) _yearView.collectionViewLayout;
    
    CGPoint offset = _yearView.contentOffset;
    offset.y = offset.y - layout.headerReferenceSize.height;
    _yearView.contentOffset = offset;
    
    if (updateTitle)
    {
        NSInteger year = ((SSYearNode *) [_years objectAtIndex:indexPath.section / 12]).value;
        self.title = [NSString stringWithFormat:@"%li", (long)year];
    }
}
@end
