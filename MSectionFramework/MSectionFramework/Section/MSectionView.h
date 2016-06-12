//
//  MSectionView.h
//  MSectionFramework
//
//  Created by Micker on 16/6/12.
//  Copyright © 2016年 Micker. All rights reserved.
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

@interface MSectionView : UIView
@property (nonatomic, strong) NSArray               *contents;
@property (nonatomic, assign) NSInteger             currentIndex;
@property (nonatomic, assign) NSInteger             secionPerPage;
@property (nonatomic, strong, readonly) UIView      *indicatorLineView;
@property (nonatomic, strong) UIScrollView          *observerView;
@property (nonatomic, assign) id<MSectionViewProtocol> delegate;
@property (nonatomic, assign) M_SECTION_ANIMATE_TYPE animateType;
@property (nonatomic, copy)  void (^block)(NSInteger);

- (void) beforColor:(UIColor *) befor after:(UIColor *) after;

- (void) reloadData;

@end
