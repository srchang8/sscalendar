//
//  SSCalendarHybridDataSource.h
//  calendart
//
//  Created by Good on 28/03/2017.
//  Copyright © 2017 Good. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SSCalendarHybridDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, copy) NSArray *years;
@property (nonatomic, weak) UICollectionView *view;

- (id)initWithView:(UICollectionView *)view;
- (void)updateLayoutForBounds:(CGRect)bounds;

@end
