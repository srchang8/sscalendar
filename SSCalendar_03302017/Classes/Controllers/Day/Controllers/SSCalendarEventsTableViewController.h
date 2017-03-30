//
//  SSCalendarEventsTableViewController.h
//  Pods
//
//  Created by Steven Preston on 7/28/13.
//  Copyright (c) 2013 Stellar16. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SSCalendarEventsTableViewController : NSObject  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSArray *events;
@property (nonatomic, weak) UITableView *tableView;

- (id)initWithTableView:(UITableView *)tableView;

@end
