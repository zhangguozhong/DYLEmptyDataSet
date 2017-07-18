//
//  UIScrollView+DYLEmptyDataSet.m
//  DYLEmptyDataSet
//
//  Created by mannyi on 2017/7/18.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "UIScrollView+DYLEmptyDataSet.h"
#import <objc/runtime.h>

@interface DYLWeakObjectContainer : NSObject

@property (weak, nonatomic) id weakObject;
- (instancetype)initWeakObject:(id)weakObject;

@end

@implementation DYLWeakObjectContainer

- (instancetype)initWeakObject:(id)weakObject
{
    self = [super init];
    if (self) {
        _weakObject = weakObject;
    }
    return self;
}

@end


@interface DYLEmptyDataSetView : UIView

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIView *customView;

@end

@implementation DYLEmptyDataSetView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)didMoveToSuperview
{
    CGRect superviewBounds = self.superview.bounds;
    self.frame = CGRectMake(0, 0, CGRectGetWidth(superviewBounds), CGRectGetHeight(superviewBounds));
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(superviewBounds), CGRectGetHeight(superviewBounds));
        self.contentView.alpha = 1;
    }];
}

- (UIView *)contentView
{
    if (!_contentView) {
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.alpha = 0;
        _contentView = contentView;
    }
    return _contentView;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.superview.bounds), 40)];
        detailLabel.textAlignment = NSTextAlignmentCenter;
        detailLabel.textColor = [UIColor blackColor];
        _detailLabel = detailLabel;
        [_contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (void)setCustomView:(UIView *)customView
{
    if (!customView) {
        return;
    }
    
    if (_customView) {
        [_customView removeFromSuperview];
        _customView = nil;
    }
    
    _customView = customView;
    customView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_customView];
}

@end


static NSMutableDictionary *_impLookupTable;
static NSString * const DYLSwizzleInfoPointerKey = @"pointer";
static NSString * const DYLSwizzleInfoOwnerKey = @"owner";
static NSString * const DYLSwizzleInfoSelectorKey = @"selector";

@implementation UIScrollView (DYLEmptyDataSet)

- (void)setEmptyDataSetSource:(id<DYLEmptyDataSetSource>)emptyDataSetSource
{
    if (!emptyDataSetSource || ![self dyl_canDispaly]) {
        [self dyl_invalidate];
    }
    
    objc_setAssociatedObject(self, @selector(emptyDataSetSource), [[DYLWeakObjectContainer alloc] initWeakObject:emptyDataSetSource], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self swizzleIfPossible:@selector(reloadData)];
    
    if ([self isKindOfClass:[UITableView class]]) {
        [self swizzleIfPossible:@selector(endUpdates)];
    }
}

- (id<DYLEmptyDataSetSource>)emptyDataSetSource
{
    DYLWeakObjectContainer *container = objc_getAssociatedObject(self, _cmd);
    return container.weakObject;
}

- (void)setEmptyDataSetDelegate:(id<DYLEmptyDataSetDelegate>)emptyDataSetDelegate
{
    if (!emptyDataSetDelegate) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(emptyDataSetDelegate), [[DYLWeakObjectContainer alloc] initWeakObject:emptyDataSetDelegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<DYLEmptyDataSetDelegate>)emptyDataSetDelegate
{
    DYLWeakObjectContainer *container = objc_getAssociatedObject(self, _cmd);
    return container.weakObject;
}


- (DYLEmptyDataSetView *)emptyDataSetView
{
    DYLEmptyDataSetView *view = objc_getAssociatedObject(self, _cmd);
    if (!view) {
        view = [[DYLEmptyDataSetView alloc] init];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.hidden = NO;
        
        [self setEmptyDataSetView:view];
    }
    return view;
}

- (void)setEmptyDataSetView:(DYLEmptyDataSetView *)view
{
    objc_setAssociatedObject(self, @selector(emptyDataSetView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)reloadEmptyDataSet
{
    [self dyl_reloadEmptyDataSet];
}

- (void)dyl_reloadEmptyDataSet
{
    if (![self dyl_canDispaly]) {
        return;
    }
    
    if ([self dyl_itemsCount] == 0) {
        
        DYLEmptyDataSetView *view = self.emptyDataSetView;
        if (!view.superview) {
            if (([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) && self.subviews.count > 1) {
                [self insertSubview:view atIndex:0];
            }
            else {
                [self addSubview:view];
            }
        }
        
        self.scrollEnabled = [self dyl_shouldAllowScroll];
        
        UIView *customView = [self dyl_customView];
        if (customView) {
            view.customView = customView;
        }
        else {
            view.detailLabel.text = [self dyl_titleString];
            view.backgroundColor = [UIColor lightGrayColor];
        }
    }
}

- (BOOL)dyl_canDispaly
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource conformsToProtocol:@protocol(DYLEmptyDataSetSource)]) {
        if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]] || [self isKindOfClass:[UIScrollView class]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)dyl_invalidate
{
    if (self.emptyDataSetView) {
        [self.emptyDataSetView removeFromSuperview];
        [self setEmptyDataSetView:nil];
    }
    
    self.scrollEnabled = YES;
}

- (NSString *)dyl_titleString
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(titleForEmptyDataSet:)]) {
        return [self.emptyDataSetSource titleForEmptyDataSet:self];
    }
    return nil;
}

- (BOOL)dyl_shouldAllowScroll
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldAllowScroll:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldAllowScroll:self];
    }
    return YES;
}

- (UIView *)dyl_customView
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(customViewForEmptyDataSet:)]) {
        return [self.emptyDataSetSource customViewForEmptyDataSet:self];
    }
    return nil;
}

- (NSInteger)dyl_itemsCount
{
    NSInteger items = 0;
    
    if (![self respondsToSelector:@selector(dataSource)]) {
        return items;
    }
    
    if ([self isKindOfClass:[UITableView class]]) {
        
        UITableView *tableView = (UITableView *)self;
        id<UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        for (NSInteger section = 0; section < sections; section++) {
            items += [dataSource tableView:tableView numberOfRowsInSection:section];
        }
    }
    
    if ([self isKindOfClass:[UICollectionView class]]) {
        
        UICollectionView *collectionView = (UICollectionView *)self;
        id<UICollectionViewDataSource> dataSource = collectionView.dataSource;
        
        NSInteger sections = 1;
        if ([dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        for (NSInteger section = 0; section < sections; section++) {
            items += [dataSource collectionView:collectionView numberOfItemsInSection:section];
        }
    }
    
    return items;
}

// 交换方法，通过method_setImplementation实现
- (void)swizzleIfPossible:(SEL)selector
{
    if (![self respondsToSelector:selector]) {
        return;
    }
    
    if (!_impLookupTable) {
        _impLookupTable = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    
    // 这里确保每个class的method_setImplementation只执行一次。
    for (NSDictionary *info in [_impLookupTable allValues]) {
        Class class = [info objectForKey:DYLSwizzleInfoOwnerKey];
        NSString *selectorName = [info objectForKey:DYLSwizzleInfoSelectorKey];
        
        if ([selectorName isEqualToString:NSStringFromSelector(selector)]) {
            if ([self isKindOfClass:class]) {
                return;
            }
        }
    }
    
    Class baseClass = dyl_baseClassToSwizzleForTarget(self);
    NSString *key = dyl_implementationKey(baseClass, selector);
    NSValue *valuePointer = [[_impLookupTable objectForKey:key] objectForKey:DYLSwizzleInfoPointerKey];
    
    // 这里判断如果valuePointer已经存在的话，就直接返回，保证每个class的method的impPointer只保存一次。
    if (valuePointer || !baseClass || !key) {
        return;
    }
    
    Method method = class_getInstanceMethod(baseClass, selector);
    IMP imp_original_implementation = method_setImplementation(method, (IMP)dyl_new_implementation);
    
    NSDictionary *swizzleInfo = @{DYLSwizzleInfoOwnerKey:baseClass,
                                  DYLSwizzleInfoSelectorKey:NSStringFromSelector(selector),
                                  DYLSwizzleInfoPointerKey:[NSValue valueWithPointer:imp_original_implementation]};
    
    [_impLookupTable setObject:swizzleInfo forKey:key];
}

Class dyl_baseClassToSwizzleForTarget(id target)
{
    if ([target isKindOfClass:[UITableView class]]) {
        return [UITableView class];
    }
    else if ([target isKindOfClass:[UICollectionView class]]) {
        return [UICollectionView class];
    }
    else if ([target isKindOfClass:[UIScrollView class]]) {
        return [UIScrollView class];
    }
    
    return nil;
}

NSString *dyl_implementationKey(Class class, SEL selector)
{
    if (!class || !selector) {
        return nil;
    }
    
    NSString *className = NSStringFromClass(class);
    NSString *selectorName = NSStringFromSelector(selector);
    
    return [NSString stringWithFormat:@"%@_%@", className, selectorName];
}

void dyl_new_implementation(id self, SEL _cmd)
{
    Class baseClass = dyl_baseClassToSwizzleForTarget(self);
    NSString *key = dyl_implementationKey(baseClass, _cmd);
    
    NSDictionary *swizzleInfo = _impLookupTable[key];
    
    NSValue *valuePointer = [swizzleInfo objectForKey:DYLSwizzleInfoPointerKey];
    IMP originalImpPointor = [valuePointer pointerValue];
    
    // 执行是否显示无数据界面
    [self dyl_reloadEmptyDataSet];
    
    // 如果已保存，执行系统原本的implementation
    if (originalImpPointor) {
        ((void(*)(id,SEL))originalImpPointor)(self, _cmd);
    }
}

@end
