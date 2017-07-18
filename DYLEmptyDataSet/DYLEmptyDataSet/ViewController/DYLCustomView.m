//
//  DYLCustomView.m
//  DYLEmptyDataSet
//
//  Created by mannyi on 2017/7/18.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "DYLCustomView.h"

@interface DYLCustomView ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIColor *viewBgColor;

@end

@implementation DYLCustomView

- (instancetype)init {
    return [self initViewWithColor:[UIColor whiteColor] andTitle:@"暂无记录"];
}

- (instancetype)initViewWithColor:(UIColor *)bgColor andTitle:(NSString *)aTitle {
    self = [super init];
    if (self) {
        self.viewBgColor = bgColor;
        [self createView];
        [self setCustomViewTitle:aTitle];
    }
    return self;
}

- (void)didMoveToSuperview
{
    CGRect superviewBounds = self.superview.bounds;
    self.frame = CGRectMake(0, 0, CGRectGetWidth(superviewBounds), CGRectGetHeight(superviewBounds));
    self.backgroundColor = _viewBgColor;
    self.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(superviewBounds), 40);
    self.titleLabel.center = self.center;
}


- (void)createView
{
    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_titleLabel];
}

- (void)setCustomViewTitle:(NSString *)aTitle
{
    self.titleLabel.text = aTitle;
}

@end
