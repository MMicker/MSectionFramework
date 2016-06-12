//
//  ViewController.m
//  testSection
//
//  Created by Micker on 16/6/12.
//  Copyright © 2016年 Micker. All rights reserved.
//

#import "ViewController.h"
#import "MSectionView.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) MSectionView *sectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSArray *datas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _datas = @[@"首页",@"聚合",@"排行",@"图片",@"国内",@"国际",@"社会",@"评论",@"数读",@"军事",@"航空",@"媒体"];
    self.flowLayout.itemSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:self.sectionView];
    self.sectionView.contents = _datas;
    [self.sectionView reloadData];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MSectionView *) sectionView {
    if (!_sectionView) {
        _sectionView = [[MSectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
        _sectionView.backgroundColor = [UIColor clearColor];
        [_sectionView beforColor:[UIColor lightGrayColor] after:[UIColor yellowColor]];
        _sectionView.observerView = self.collectionView;
        _sectionView.secionPerPage = 5;
        _sectionView.indicatorLineView.backgroundColor = [UIColor yellowColor];
        __weak __typeof__(self) weakSelf = self;
        _sectionView.block = ^(NSInteger index) {
            NSLog(@"当前选中项为[%@] = %@", @(index), weakSelf.datas[index]);
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
    [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    UILabel *label = [cell viewWithTag:100];
    label.textColor = [UIColor lightGrayColor];
    NSString *text = [NSString stringWithFormat:@"当前选中项为[%@]", self.datas[indexPath.item]];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttribute:NSForegroundColorAttributeName
                            value:[UIColor yellowColor]
                            range:NSMakeRange(7, [self.datas[indexPath.item] length])];
    label.attributedText = attributeString;
    return cell;
}

@end
