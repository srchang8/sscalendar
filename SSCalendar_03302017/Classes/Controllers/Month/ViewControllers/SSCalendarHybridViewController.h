//
//  SSCalendarHybridViewController.h
//  calendart
//
//  Created by Good on 28/03/2017.
//  Copyright © 2017 Good. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SSCalendarHybridDataSource;

@interface SSCalendarHybridViewController : UIViewController <UICollectionViewDelegate>
@property (nonatomic, copy) NSArray *years;
@property (nonatomic, strong) NSIndexPath *startingIndexPath;
@property (weak, nonatomic) IBOutlet UIView *subViewEvents;

@property (weak, nonatomic) IBOutlet UICollectionView *yearView;
@property (nonatomic, strong) SSCalendarHybridDataSource *dataSource;

- (id)initWithEvents:(NSArray *)events;

@end
