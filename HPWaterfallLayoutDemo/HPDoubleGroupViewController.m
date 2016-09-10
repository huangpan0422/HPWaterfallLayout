//
//  HPDoubleGroupViewController.m
//  HPWaterfallLayoutDemo
//
//  Created by huangpan on 16/9/10.
//  Copyright © 2016年 Leon. All rights reserved.
//

#import "HPDoubleGroupViewController.h"
#import "HPCollectionViewWaterfallLayout.h"
#import "HPCollectionViewCell.h"
#import "HPCollectionReusableView.h"
#import "YYFPSLabel.h"

static NSString *doubleGroupReuseWaterfallCellIdentfier   = @"doubleGroupReuseWaterfallCellIdentfier";
static NSString *doubleGroupReuseWaterfallHeaderIdentfier = @"doubleGroupReuseWaterfallHeaderIdentfier";
static NSString *doubleGroupReuseWaterfallFooterIdentfier = @"doubleGroupReuseWaterfallFooterIdentfier";

@interface HPDoubleGroupViewController ()<HPCollectionViewWaterfallLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource> {
    HPCollectionViewWaterfallLayout *_waterfallLayout;
}
@property (nonatomic, strong) YYFPSLabel *fpsLabel;
@property (nonatomic, strong) NSMutableArray *cellHeightArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation HPDoubleGroupViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // 测试数据
    _cellHeightArray = [NSMutableArray array];
    NSInteger index = 0;
    while ( index < 1000) {
        u_int32_t random = arc4random_uniform(30) + 10;
        CGFloat width = random * 5;
        [self.cellHeightArray addObject:@(width)];
        index ++;
    }
    //
    _waterfallLayout = [[HPCollectionViewWaterfallLayout alloc] init];
    _waterfallLayout.delegate = self;
    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:_waterfallLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[HPCollectionViewCell class] forCellWithReuseIdentifier:doubleGroupReuseWaterfallCellIdentfier];
    [self.collectionView registerClass:[HPCollectionHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:doubleGroupReuseWaterfallHeaderIdentfier];
    [self.collectionView registerClass:[HPCollectionFooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:doubleGroupReuseWaterfallFooterIdentfier];
    
    //
    UIButton *headerPinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    headerPinBtn.layer.cornerRadius = 50.0f;
    headerPinBtn.clipsToBounds = YES;
    headerPinBtn.backgroundColor = [UIColor whiteColor];
    [headerPinBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [headerPinBtn setTitle:@"取消悬浮" forState:UIControlStateSelected];
    [headerPinBtn setTitle:@"悬浮" forState:UIControlStateNormal];
    [headerPinBtn addTarget:self action:@selector(sectionHeaderDidPin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:headerPinBtn];
    headerPinBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[headerPinBtn(==100)]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerPinBtn)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[headerPinBtn(==100)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerPinBtn)]];
    //
    //
    _fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(10, 100, 50, 30)];
    [_fpsLabel sizeToFit];
    [self.view addSubview:_fpsLabel];
}

#pragma mark - Event Handle
- (void)sectionHeaderDidPin:(UIButton *)sender {
    if (sender.isSelected) {
        sender.selected = NO;
        _waterfallLayout.needPinSectionHeaders = NO;
        [self.collectionView reloadData];
    } else {
        sender.selected = YES;
        _waterfallLayout.needPinSectionHeaders = YES;
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellHeightArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:doubleGroupReuseWaterfallCellIdentfier forIndexPath:indexPath];
    [cell setTitle:[NSString stringWithFormat:@"%zd - %zd",indexPath.section, indexPath.row]];
    cell.backgroundColor = [UIColor purpleColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    HPCollectionReusableView *reuseView = nil;
    if ( [kind isEqualToString:UICollectionElementKindSectionHeader] ) {
        reuseView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:doubleGroupReuseWaterfallHeaderIdentfier forIndexPath:indexPath];
        reuseView.title = [NSString stringWithFormat:@"我就是悬浮顶栏%zd你信不信？",indexPath.section];
    }
    else {
        reuseView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:doubleGroupReuseWaterfallFooterIdentfier forIndexPath:indexPath];
        reuseView.title = [NSString stringWithFormat:@"我就是普通底部栏%zd你信不信？",indexPath.section];
    }
    return reuseView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(HPCollectionViewWaterfallLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 44);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(HPCollectionViewWaterfallLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 44);
}

#pragma mark - HPCollectionViewWaterfallLayout
- (CGFloat)layout:(HPCollectionViewWaterfallLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = self.cellHeightArray[indexPath.row];
    return [height floatValue];
}

@end
