//
//  SSCalendarMonthlyHeaderView.h
//  Pods
//
//  Created by Steven Preston on 7/19/13.
//  Copyright (c) 2013 Stellar16. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SSCalendarMonthlyHeaderView : UICollectionReusableView

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *leadingConstraint;

@end
