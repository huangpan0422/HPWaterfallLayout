//
//  HPCollectionViewWaterfallLayout.h
//  iCarouselTest
//
//  Created by huangpan on 16/9/7.
//  Copyright © 2016年 Leon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HPCollectionViewWaterfallLayout;

@protocol HPCollectionViewWaterfallLayoutDelegate <NSObject>

@required
- (CGFloat)layout:(HPCollectionViewWaterfallLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
/**
 *  行间距
 */
- (CGFloat)minimumRowSpacingInLayout:(HPCollectionViewWaterfallLayout *)layout ;
/**
 *  列间距
 */
- (CGFloat)minimumColumnSpacingInLayout:(HPCollectionViewWaterfallLayout *)layout;
/**
 *  Section间距
 */
- (CGFloat)minimumSectionSpacingInLayout:(HPCollectionViewWaterfallLayout *)layout atSection:(NSUInteger)section;
/**
 *  列数
 */
- (NSUInteger)columnCountsPerRowInLayout:(HPCollectionViewWaterfallLayout *)layout;
/**
 *  KindSectionHeader的Size
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(HPCollectionViewWaterfallLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
/**
 *  KindSectionFooter的Size
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(HPCollectionViewWaterfallLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;
/**
 *  collectionView内边距
 */
- (UIEdgeInsets)edgeInsetsInCollectionViewForLayout:(HPCollectionViewWaterfallLayout *)layout;

@end

@interface HPCollectionViewWaterfallLayout : UICollectionViewLayout

@property (nonatomic, weak) id<HPCollectionViewWaterfallLayoutDelegate> delegate;
/**
 *  是否需要粘滞 
 */
@property (nonatomic, assign) BOOL needPinSectionHeaders;
/** 
 *  粘滞的距离，只有当needPinSectionHeaders为YES才生效（默认0.f，即导航栏底部粘滞)
 */
@property (nonatomic, assign) CGFloat distanceFromVisibleTopPosition;
@property (nonatomic, assign) CGFloat minimumRowSpace;
@property (nonatomic, assign) CGFloat minimumColumnSpace;
@property (nonatomic, assign) CGFloat minimumSectionSpace;
@property (nonatomic, assign) NSUInteger columnCountsPerRow;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
/** 
 *  KindSectionHeader的Size
 */
@property (nonatomic, assign) CGSize headerReferenceSize;
/** 
 *  KindSectionFooter的Size
 */
@property (nonatomic, assign) CGSize footerReferenceSize;

@property (nonatomic, copy) void(^layoutCompletedContentSize)(CGSize);

@end
