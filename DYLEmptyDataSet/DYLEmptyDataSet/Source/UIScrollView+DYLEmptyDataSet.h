//
//  UIScrollView+DYLEmptyDataSet.h
//  DYLEmptyDataSet
//
//  Created by mannyi on 2017/7/18.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DYLEmptyDataSetSource <NSObject>

@optional
- (NSString *)titleForEmptyDataSet:(UIScrollView *)scrollView;
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView;

@end

@protocol DYLEmptyDataSetDelegate <NSObject>

@optional
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView;

@end

@interface UIScrollView (DYLEmptyDataSet)

@property (weak, nonatomic) id<DYLEmptyDataSetSource> emptyDataSetSource;
@property (weak, nonatomic) id<DYLEmptyDataSetDelegate> emptyDataSetDelegate;

- (void)reloadEmptyDataSet;

@end
