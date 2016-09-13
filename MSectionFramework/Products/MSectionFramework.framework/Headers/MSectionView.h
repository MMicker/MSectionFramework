//
//  MSectionView.h
//  GoldSectionFramework
//
//  Created by Micker on 16/5/22.
//  Copyright © 2016年 wallstreetcn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger , M_SECTION_ANIMATE_TYPE) {
    M_SECTION_ANIMATE_TEXT_COLOR = 1 << 0,       //文本颜色
    M_SECTION_ANIMATE_TEXT_TRANSFORM = 1 << 1,   //文本变换
    M_SECTION_ANIMATE_INDICATOR_ALPHA = 1 << 2,  //指示条透明度
    M_SECTION_ANIMATE_INDICATOR_SNAKE = 1 << 3,  //指示条蛇形增长
    
    M_SECTION_ANIMATE_DEFAULT =                  //默认值
    M_SECTION_ANIMATE_TEXT_COLOR |
    M_SECTION_ANIMATE_TEXT_TRANSFORM |
    M_SECTION_ANIMATE_INDICATOR_ALPHA |
    M_SECTION_ANIMATE_INDICATOR_SNAKE,
};

@protocol MSectionViewProtocol <NSObject>

- (void) currrentIndexChanged:(NSInteger) index;

@end

@interface MSectionView : UIView<UIAppearance>
@property (nonatomic, strong) NSArray               *contents;
@property (nonatomic, assign, readonly) NSUInteger  currentIndex;
@property (nonatomic, strong, readonly) UIView      *indicatorLineView;
@property (nonatomic, strong) UIScrollView          *observerView;
@property (nonatomic, assign) id<MSectionViewProtocol> delegate;
@property (nonatomic, assign) M_SECTION_ANIMATE_TYPE animateType;
@property (nonatomic, strong) UIFont                *cellFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor               *indicatorBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat               padding;        //default is 16.0
@property (nonatomic, assign) NSInteger             secionPerPage;  //once set , the padding will changed, used for equal width

@property (nonatomic, copy)  void (^block)(NSInteger);

- (void) setColors:(NSArray *) colors UI_APPEARANCE_SELECTOR;

- (void) reloadData;

- (void) goToIndex:(NSUInteger) index;

#pragma mark -- deprecated

- (void) beforColor:(UIColor *) befor after:(UIColor *) after __deprecated_msg("use setColors to sepcial the two colors");

@end
