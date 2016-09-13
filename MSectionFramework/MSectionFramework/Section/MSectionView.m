//
//  MSectionView.m
//  GoldSectionFramework
//
//  Created by Micker on 16/5/22.
//  Copyright © 2016年 wallstreetcn. All rights reserved.
//

#import "MSectionView.h"
#import "MSectionViewCell.h"

@interface MSectionView()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, strong) UIView                     *indicatorLineView;
@property (nonatomic, strong) UICollectionView           *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) NSInteger                  index;
@property (nonatomic, assign) NSUInteger                 currentIndex;

@end

@implementation MSectionView {
    CGFloat _beforeComponents[3], _afterComponents[3];
    UIColor *_beforColor, *_afterColor;
    CGFloat _curentWidthPercent;
    NSMutableArray *_contentSizeArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _padding = 16.0f;
        _currentIndex = -1;
        _animateType = M_SECTION_ANIMATE_DEFAULT;
        _contentSizeArray = [NSMutableArray array];
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
        _indicatorLineView = [[UIView alloc] initWithFrame:CGRectMake(_padding, CGRectGetHeight(self.bounds)-2, 0, 2)];
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
        _flowLayout.minimumLineSpacing =  _padding * 2;
        _flowLayout.minimumInteritemSpacing = _padding * 2;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, _padding * 2, 0, _padding * 2);
        _flowLayout.itemSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}


- (UIFont *) cellCustomFont {
    if (!_cellFont) {
        return [UIFont systemFontOfSize:14.0f];
    }
    return _cellFont;
}

- (void) setCellFont:(UIFont *)cellFont UI_APPEARANCE_SELECTOR {
    _cellFont = cellFont;
    [self reloadData];
}

- (void) setIndicatorBackgroundColor:(UIColor *)indicatorBackgroundColor {
    _indicatorBackgroundColor = indicatorBackgroundColor;
    self.indicatorLineView.backgroundColor = _indicatorBackgroundColor;
}

- (void) setColors:(NSArray *) colors UI_APPEARANCE_SELECTOR {
    if ([colors count] == 2) {
        [self __beforColor:colors[0] after:colors[1]];
    } else {
        NSLog(@"colors count must be 2!!");
    }
}

#pragma mark -- UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self contents] count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake([self tipWidth:indexPath.item], CGRectGetHeight(self.bounds));
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MSectionViewCell *cell = (MSectionViewCell *)
    [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MSectionViewCell class])
                                              forIndexPath:indexPath];
    cell.nameLabel.font = [self cellCustomFont];
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

- (void) updateIndicatorPositionWithPercent:(CGFloat) widthPercent {
    CGRect rect = self.indicatorLineView.frame;
    NSInteger value = _currentIndex + ((widthPercent >= 0) ? (widthPercent > 0 ? 1 : 0) : -1);
    CGFloat offSetX = [self contentOffSetX:self.currentIndex];
    CGFloat tipWidth0 = [self tipWidth:value];
    CGFloat tipWidth1 = [self tipWidth:_currentIndex ];
    rect.origin.x = offSetX + (tipWidth1 + 1 * _padding) * widthPercent + 0.5 * _padding;
    rect.size.width = tipWidth1 + (tipWidth0 - tipWidth1) * widthPercent - 1 * _padding;
    self.indicatorLineView.frame = rect;
    (![self checkAnimateType:M_SECTION_ANIMATE_INDICATOR_ALPHA]) ? nil : [self.indicatorLineView setAlpha:fmaxf(widthPercent, 1-widthPercent)];
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
    CGPoint point = [self.collectionView convertPoint:cell.center toView:self];
    if (!cell || (point.x < 0 || point.x > CGRectGetWidth(self.bounds))) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
        (![self checkAnimateType:M_SECTION_ANIMATE_TEXT_COLOR]) ? nil : [cell updateTextColor:_afterColor];
        (![self checkAnimateType:M_SECTION_ANIMATE_TEXT_TRANSFORM]) ? nil : [cell updateTransform:CGAffineTransformIdentity];
    }
    
    //deal with current cell's near cell;
    [self updateCollectionViewCell];
}


- (void) goToIndex:(NSUInteger) index {
    if (index > [self.contents count] || !self.observerView) {
        return;
    }
    self.currentIndex = index;
    [self.observerView setContentOffset:CGPointMake(_currentIndex * CGRectGetWidth(self.observerView.frame), 0) animated:YES];
}

- (void) setCurrentIndex:(NSUInteger)currentIndex {
    if (currentIndex > [self.contents count]-1 ||  _currentIndex == currentIndex) {
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
    if (!self.observerView) {
        return;
    }
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
    if ([@"contentOffset" isEqualToString:keyPath] && self.contents) {
        CGFloat observerOffset = self.observerView.contentOffset.x;
        NSUInteger widthIndex = observerOffset/ self.observerView.frame.size.width;
//        CGFloat widthPercent = (observerOffset - (self.currentIndex) *  self.observerView.frame.size.width)/self.observerView.frame.size.width;
        [self updateCollectionViewCell];
        self.currentIndex = widthIndex;
    }
}

- (CGFloat) contentOffSetX:(NSUInteger) index {
    __block CGFloat offsetX = 0;
    for (NSUInteger i = 0 ; i < index; i++) {
        NSNumber *number = [_contentSizeArray objectAtIndex:i];
        offsetX += [number floatValue] + _padding * 1;
        
    }
    return offsetX + _padding * 1;
}

- (CGFloat) tipWidth:(NSInteger) index {
    if (index > [self.contents count]-1 || index < 0) {
        return 48.0f;
    }
    NSString *value = [self.contents objectAtIndex:index];
    CGSize size = [value sizeWithAttributes:@{NSFontAttributeName:[self cellCustomFont]}];
    return size.width + _padding * 2;
}

- (void) reloadData {
    
    if ([self.contents count] == 0) {
        return;
    }
    
    {
        //处理平分padding的情况
        if (self.secionPerPage > 0) {
            NSString *value = [self.contents objectAtIndex:0];
            CGSize size = [value sizeWithAttributes:@{NSFontAttributeName:[self cellCustomFont]}];
            self.padding = (self.bounds.size.width - self.secionPerPage * size.width) / ( self.secionPerPage * 3 + 1);
        }
        
        _flowLayout.minimumLineSpacing =  _padding * 1;
        _flowLayout.minimumInteritemSpacing = _padding * 1;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, _padding * 1, 0, _padding * 1);
    }
    
    {
        //缓存各item的宽度
        [_contentSizeArray removeAllObjects];
        __weak typeof(self) weakSelf = self;
        [self.contents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_contentSizeArray addObject:@([weakSelf tipWidth:idx])];
        }];
    }
    
    {
        //重新加载数据
        [self.collectionView reloadData];
        if (-1 == _currentIndex) {
            self.currentIndex = 0;
        }
    }
    
    {
        //添加视图
        if (!self.collectionView.superview) {
            [self addSubview:self.collectionView];
        }
        if (!self.indicatorLineView.superview) {
            [self.collectionView addSubview:self.indicatorLineView];
        }
    }
}

- (void) setContents:(NSArray *)contents {
    _contents = contents;
    [self reloadData];
}

#pragma mark --Private

- (BOOL) checkAnimateType:(M_SECTION_ANIMATE_TYPE) type {
    return type == (type & self.animateType);
}

- (void) beforColor:(UIColor *) befor after:(UIColor *) after {
    [self __beforColor:befor after:after];
}

- (void) __beforColor:(UIColor *) befor after:(UIColor *) after {
    _beforColor = befor;
    _afterColor = after;
    [self getRGBComponents:_beforeComponents forColor:befor];
    [self getRGBComponents:_afterComponents forColor:after];
    [self.collectionView reloadData];
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
