//
//  MSectionView.m
//  MSectionFramework
//
//  Created by Micker on 16/6/12.
//  Copyright © 2016年 Micker. All rights reserved.
//

#import "MSectionView.h"
#import "MSectionViewCell.h"

@interface MSectionView()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIView            *indicatorLineView;
@property (nonatomic, strong) UICollectionView  *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) NSInteger        index;

@end

@implementation MSectionView {
    CGFloat _beforeComponents[3], _afterComponents[3];
    UIColor *_beforColor, *_afterColor;
    CGFloat _padding, _itemWidth, _tipWidth;
    CGFloat _curentWidthPercent;
}
@synthesize secionPerPage = _secionPerPage;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _padding = 10.0f;
        _tipWidth = 50.0f;
        _animateType = M_SECTION_ANIMATE_DEFAULT;
    }
    return self;
}

- (void) dealloc {
    if (_observerView) {
        [_observerView removeObserver:self forKeyPath:@"contentOffset"];
    }
}

#pragma mark -- Getter

- (UIView *) indicatorLineView {
    if (!_indicatorLineView) {
        _indicatorLineView = [[UIView alloc] initWithFrame:CGRectMake(_padding, CGRectGetHeight(self.bounds)-4, _itemWidth, 4)];
    }
    return _indicatorLineView;
}

- (UICollectionView *) collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[MSectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MSectionViewCell class])];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *) flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = .0f;
        _flowLayout.minimumInteritemSpacing = .0f;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _flowLayout.itemSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

#pragma mark -- UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self contents] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MSectionViewCell *cell = (MSectionViewCell *)
    [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MSectionViewCell class])
                                              forIndexPath:indexPath];
    [cell doSetContentData:[self.contents objectAtIndex:indexPath.item]];
    float value = (_currentIndex == indexPath.item) ? 1.1 : 1.0f;
    (![self checkAnimateType:M_SECTION_ANIMATE_TEXT_COLOR]) ? nil : [cell updateTextColor:(_currentIndex == indexPath.item) ? _afterColor : _beforColor];
    (![self checkAnimateType:M_SECTION_ANIMATE_TEXT_TRANSFORM]) ? nil : [cell updateTransform:CGAffineTransformMakeScale(value, value)];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.observerView setContentOffset:CGPointMake(indexPath.item * self.observerView.frame.size.width, 0) animated:NO];
    [self doAfterAnimation];
}


- (void) setObserverView:(UIScrollView *)observerView {
    if (_observerView != observerView && observerView) {
        _observerView = observerView;
        [_observerView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

#pragma mark --Actions

- (void) updateIndicatorPositionWithPercent:(CGFloat) percent {
    
    CGRect rect = self.indicatorLineView.frame;
    rect.origin.x = (_itemWidth - _tipWidth)/2 + (_currentIndex + percent)* _itemWidth;
    if ([self checkAnimateType:M_SECTION_ANIMATE_INDICATOR_SNAKE]) {
        rect.size.width = _tipWidth * (fminf(percent, 1-percent) + 1);
    }
    self.indicatorLineView.frame = rect;
    (![self checkAnimateType:M_SECTION_ANIMATE_INDICATOR_ALPHA]) ? nil : [self.indicatorLineView setAlpha:fmaxf(percent, 1-percent)];
}

- (void) doAfterAnimation {
    // deal with visible cell, the cell is not near current selected cell
    [[self.collectionView indexPathsForVisibleItems] enumerateObjectsUsingBlock:^(__kindof NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        
        MSectionViewCell *currentCell = (MSectionViewCell *)[self.collectionView
                                                                   cellForItemAtIndexPath:indexPath];
        if (fabs(_curentWidthPercent - _currentIndex) >= 1) {
            (![self checkAnimateType:M_SECTION_ANIMATE_TEXT_COLOR]) ? nil : [currentCell updateTextColor:_beforColor];
            (![self checkAnimateType:M_SECTION_ANIMATE_TEXT_TRANSFORM]) ? nil : [currentCell updateTransform:CGAffineTransformIdentity];
        }
    }];
    
    //deal with current cell is not appear
    MSectionViewCell *cell = (MSectionViewCell *)[self.collectionView
                                                        cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]];
    if (!cell) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
        (![self checkAnimateType:M_SECTION_ANIMATE_TEXT_COLOR]) ? nil : [cell updateTextColor:_afterColor];
        (![self checkAnimateType:M_SECTION_ANIMATE_TEXT_TRANSFORM]) ? nil : [cell updateTransform:CGAffineTransformIdentity];
    }
    
    //deal with current cell's near cell;
    [self updateCollectionViewCell];
}

- (void) setCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex < 0 || currentIndex > [self.contents count]-1 ||  _currentIndex == currentIndex) {
        return;
    }
    _currentIndex = currentIndex;
    if (self.block) {
        self.block(_currentIndex);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(currrentIndexChanged:)]) {
        [self.delegate currrentIndexChanged:_currentIndex];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doAfterAnimation) object:nil];
    [self doAfterAnimation];
}

- (void) updateCollectionViewCell {
    CGFloat offSet = self.currentIndex * self.observerView.frame.size.width;
    CGFloat observerOffset = self.observerView.contentOffset.x;
    NSUInteger widthIndex = observerOffset/ self.observerView.frame.size.width;
    CGFloat widthPercent = (observerOffset - (self.currentIndex) *  self.observerView.frame.size.width)/self.observerView.frame.size.width;
    
    NSUInteger index = self.currentIndex;
    index = (observerOffset > offSet) ? index + 1 : index - 1;
    MSectionViewCell *oldCell = (MSectionViewCell *)[self.collectionView
                                                           cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
    MSectionViewCell *newCell = (MSectionViewCell *)[self.collectionView
                                                           cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    _curentWidthPercent = widthIndex + widthPercent;
    float oldValue = 1.1 - (0.1) * widthPercent;
    float newValue = 1 + 0.1 * widthPercent;
    
    (![self checkAnimateType:M_SECTION_ANIMATE_TEXT_COLOR]) ? nil : [oldCell updateTextColor:[self colorWithAfterPercent:widthPercent]];
    (![self checkAnimateType:M_SECTION_ANIMATE_TEXT_TRANSFORM]) ? nil : [oldCell updateTransform:CGAffineTransformMakeScale(oldValue, oldValue)];
    
    (![self checkAnimateType:M_SECTION_ANIMATE_TEXT_COLOR]) ? nil : [newCell updateTextColor:[self colorWithBeforePercent:widthPercent]];
    (![self checkAnimateType:M_SECTION_ANIMATE_TEXT_TRANSFORM]) ? nil : [newCell updateTransform:CGAffineTransformMakeScale(newValue, newValue)];
    
    [self updateIndicatorPositionWithPercent:widthPercent];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([@"contentOffset" isEqualToString:keyPath]) {
        CGFloat observerOffset = self.observerView.contentOffset.x;
        NSUInteger widthIndex = observerOffset/ self.observerView.frame.size.width;
        CGFloat widthPercent = (observerOffset - (self.currentIndex) *  self.observerView.frame.size.width)/self.observerView.frame.size.width;
        [self updateCollectionViewCell];
        self.currentIndex = widthIndex;
    }
}

- (void) beforColor:(UIColor *) befor after:(UIColor *) after {
    _beforColor = befor;
    _afterColor = after;
    [self getRGBComponents:_beforeComponents forColor:befor];
    [self getRGBComponents:_afterComponents forColor:after];
}

- (void) reloadData {
    _currentIndex = -1;
    [self.collectionView reloadData];
    self.currentIndex = 0;
    _itemWidth = CGRectGetWidth(self.bounds)/ [self secionPerPage];
    self.flowLayout.itemSize = CGSizeMake(_itemWidth, CGRectGetHeight(self.bounds));
    if (!self.collectionView.superview) {
        [self addSubview:self.collectionView];
    }
    self.indicatorLineView.frame = CGRectMake((_itemWidth - _tipWidth)/2, CGRectGetHeight(self.bounds)-2, _tipWidth, 2);
    if (!self.indicatorLineView.superview) {
        [self.collectionView addSubview:self.indicatorLineView];
    }
}

- (NSInteger) secionPerPage {
    if (_secionPerPage <= 0) {
        return 3;
    }
    return _secionPerPage;
}

- (void) setContents:(NSArray *)contents {
    _contents = contents;
    [self reloadData];
}


#pragma mark --Private

- (BOOL) checkAnimateType:(M_SECTION_ANIMATE_TYPE) type {
    return type == (type & self.animateType);
}

- (CGFloat) valueBefor:(CGFloat)before anfter:(CGFloat) after percent:(CGFloat) percent {
    return before + (after - before) * percent;
}

- (void)getRGBComponents:(CGFloat [4])components forColor:(UIColor *)color  {
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpace, kCGImageAlphaPremultipliedLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
}

- (UIColor *) colorWithBeforePercent:(CGFloat) percent {
    
    return [UIColor colorWithRed:[self valueBefor:_beforeComponents[0] anfter:_afterComponents[0] percent:percent]
                           green:[self valueBefor:_beforeComponents[1] anfter:_afterComponents[1] percent:percent]
                            blue:[self valueBefor:_beforeComponents[2] anfter:_afterComponents[2] percent:percent]
                           alpha:1];
}

- (UIColor *) colorWithAfterPercent:(CGFloat) percent {
    
    return [UIColor colorWithRed:[self valueBefor:_afterComponents[0] anfter:_beforeComponents[0] percent:percent]
                           green:[self valueBefor:_afterComponents[1] anfter:_beforeComponents[1] percent:percent]
                            blue:[self valueBefor:_afterComponents[2] anfter:_beforeComponents[2] percent:percent]
                           alpha:1];
}

@end
