//
//  ViewController.m
//  testSection
//
//  Created by Micker on 16/8/22.
//  Copyright © 2016年 wallstreetcn. All rights reserved.
//

#import "ViewController.h"
#import "MSectionView.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView              *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout    *flowLayout;
@property (nonatomic, strong) MSectionView               *sectionView;
@property (nonatomic, strong) NSArray                       *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datas = @[@"首页",@"聚合",@"排行",@"图片",@"国内",@"国际",@"社会",@"评论",@"数读",@"军事",@"航空",@"媒体"];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.sectionView];
    self.sectionView.contents = self.datas;
    [self.collectionView reloadData];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:[NSString stringWithFormat:@"%@",@(1)]];
    
    [self.sectionView goToIndex:2];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionView *) collectionView {
    if (!_collectionView) {
        CGRect rect = CGRectMake(0, 42, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *) flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = .0f;
        _flowLayout.minimumInteritemSpacing = .0f;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _flowLayout.itemSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
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

#pragma mark -- UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_datas count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = (UICollectionViewCell *)
    [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"%@",@(1)]
                                              forIndexPath:indexPath];
    UILabel *label = [cell viewWithTag:1000];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, CGRectGetWidth(self.view.bounds) , 30)];
        label.tag = 1000;
        label.textColor = [UIColor yellowColor];
        label.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:label];
    }
    label.text = [_datas objectAtIndex:indexPath.item];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}



@end
