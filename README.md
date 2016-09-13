#MSectionFramework控件
##前言
[MSectionFramework](https://github.com/was0107/MSectionFramework),为实现Section的导航控件，目前大量APP中均有使用到此效果，
如网易新闻的分类，淘宝中的微淘、社区，天猫中的关注、范儿等等；

##效果图展示
为更好的展示效果，请耐心等待<br>
<img src="https://raw.githubusercontent.com/was0107/MSectionFramework/master/images/section.gif" width="50%">

##简介
* 1、此包提供Section的Framework及testSection；
* 2、支持标题颜色渐变过渡，标题的缩放，支持指示条的透明度及蛇形渐进；
* 3、支持设置每屏的展示数目，用于在大、小屏之间的转换；
* 4、支持当前选中之后的回调，delegate或者block均可；
* 5、支持关联到基于UIScrollView的控件，如UICollectionView、UIScrollView；


##说明
* 1、支持的动画类型如下，另默认情况是全部包含，亦可以通过自定义动画类型组合，选择合适的效果；
```
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
```

##如何使用

```
- (void) configSectionAppearence {
    [[MSectionView appearance] setCellFont:[UIFont systemFontOfSize:14]];
    [[MSectionView appearance] setBackgroundColor:[UIColor blackColor]];
    [[MSectionView appearance] setIndicatorBackgroundColor:[UIColor yellowColor]];
    [[MSectionView appearance] setColors:@[[UIColor whiteColor],[UIColor yellowColor]]];
}

- (MSectionView *) sectionView {
    if (!_sectionView) {
        _sectionView = [[MSectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 42)];
        _sectionView.observerView = self.collectionView;
//        _sectionView.secionPerPage = 3;
        _sectionView.padding = 10;
        __weak __typeof__(self) weakSelf = self;
        _sectionView.block = ^(NSInteger index) {
            NSLog(@"当前选中项为[%@] = %@", @(index),weakSelf.datas[index]);
        };
    }
    return _sectionView;
}


```


##Change Log

V0.2
-----

* 1、废除`- (void) beforColor:(UIColor *) befor after:(UIColor *) after `,使用`- (void) setColors:(NSArray *) colors`;
* 2、通过`Appearence`进行统一设置颜色及字体大小；
* 3、支持`secionPerPage`和`padding`两种设置单元格间距的方法；

V0.1
-----
* 1、完成初稿，实现各种移动过程中的动画效果；
* 2、开放相应的设置字体和颜色的方法；
