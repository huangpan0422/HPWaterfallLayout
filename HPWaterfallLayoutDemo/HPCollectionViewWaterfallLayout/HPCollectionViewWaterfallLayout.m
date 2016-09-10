//
//  HPCollectionViewWaterfallLayout.m
//  iCarouselTest
//
//  Created by huangpan on 16/9/7.
//  Copyright © 2016年 Leon. All rights reserved.
//

#import "HPCollectionViewWaterfallLayout.h"

/** 默认行距 */
static CGFloat const kDefaultMinimumRowSpacing        = 5.0f;
/** 默认列距 */
static CGFloat const kDefaultMinimumColumnSpacing     = 5.0f;
/** 默认Section间距 */
static NSUInteger const kDefaultMinimumSectionSpacing = 10.0f;
/** 默认列数 */
static NSUInteger const kDefaultColumnCountPerRow     = 2;
/** 默认边距*/
static UIEdgeInsets const kDefaultEdgeInsets          = {5, 5, 0, 5};

@interface HPCollectionViewWaterfallLayout () {
    NSUInteger _curSection;
}
@property (nonatomic, strong) NSMutableArray *maxHeightForColumns;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes;
@property (nonatomic, strong) NSMutableDictionary<id, UICollectionViewLayoutAttributes*> *cacheCell;
@property (nonatomic, strong) NSMutableDictionary<id, UICollectionViewLayoutAttributes*> *cacheHeaders;
@property (nonatomic, strong) NSMutableDictionary<id, UICollectionViewLayoutAttributes*> *cacheFooters;
/**
 *  当前collectionView需要显示的contentSize的高度
 */
@property (nonatomic, assign) CGFloat curContentSizeHeight;

@property (nonatomic, weak) id<UICollectionViewDataSource> dataSource;
@end

@implementation HPCollectionViewWaterfallLayout

@synthesize edgeInsets = _edgeInsets;
@synthesize minimumRowSpace = _minimumRowSpace;
@synthesize minimumColumnSpace = _minimumColumnSpace;
@synthesize minimumSectionSpace = _minimumSectionSpace;
@synthesize columnCountsPerRow = _columnCountsPerRow;
@synthesize distanceFromVisibleTopPosition = _distanceFromVisibleTopPosition;

-  (void)dealloc {
    NSLog(@"我被销毁啦 ~~~~~~~~ ");
}

#pragma mark - Init
- (instancetype)init {
    if ( self = [super init] ) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ( self = [super initWithCoder:aDecoder] ) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    _minimumRowSpace = kDefaultMinimumRowSpacing;
    _minimumColumnSpace = kDefaultMinimumColumnSpacing;
    _columnCountsPerRow = kDefaultColumnCountPerRow;
    _minimumSectionSpace = kDefaultMinimumSectionSpacing;
    _distanceFromVisibleTopPosition = 0.0f;
    _edgeInsets = kDefaultEdgeInsets;
    _curSection = 0;
    _headerReferenceSize = CGSizeZero;
    _footerReferenceSize = CGSizeZero;
    //
    _maxHeightForColumns = [NSMutableArray array];
    _layoutAttributes = [NSMutableArray array];
    _cacheCell = [NSMutableDictionary dictionary];
    _cacheHeaders = [NSMutableDictionary dictionary];
    _cacheFooters = [NSMutableDictionary dictionary];
}

#pragma mark - Override Functions
- (void)prepareLayout {
    [super prepareLayout];
    // 0. 清除缓存
    [self.cacheCell removeAllObjects];
    [self.cacheHeaders removeAllObjects];
    [self.cacheFooters removeAllObjects];
    
    // 1. 清除原来的高度并新增起始高度
    [self.maxHeightForColumns  removeAllObjects];
    for (NSInteger i = 0; i < self.columnCountsPerRow; i++) {
        [self.maxHeightForColumns addObject:@(self.edgeInsets.top)];
    }
    
    // 2. 清除之前所有的布局属性
    [self.layoutAttributes removeAllObjects];
    // 3. 创建Attributes
    [self _prepareLayoutAttributes];
}

/**
 *  layout
 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *willShowAttributes = [self _willShowAttributesForElementsInVisibleBounds];
    if ( !self.needPinSectionHeaders ) {
        return willShowAttributes;
    }
    UICollectionView * const collection = self.collectionView;
    CGPoint const contentOffset = collection.contentOffset;
    // 位移
    for (UICollectionViewLayoutAttributes *layoutAttributes in willShowAttributes) {
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            NSInteger section = layoutAttributes.indexPath.section;
            NSInteger numberOfItemsInSection = [collection numberOfItemsInSection:section];
            
            NSIndexPath *firstObjectIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            NSIndexPath *lastObjectIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
            
            BOOL cellsExist;
            UICollectionViewLayoutAttributes *firstObjectAttrs;
            UICollectionViewLayoutAttributes *lastObjectAttrs;
            
            if (numberOfItemsInSection > 0) {
                cellsExist = YES;
                firstObjectAttrs = [self layoutAttributesForItemAtIndexPath:firstObjectIndexPath];
                lastObjectAttrs = [self layoutAttributesForItemAtIndexPath:lastObjectIndexPath];
            } else {
                cellsExist = NO;
                firstObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:firstObjectIndexPath];
                lastObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:firstObjectIndexPath];
            }
            
            if ( firstObjectAttrs && lastObjectAttrs ) {
                CGFloat topHeaderHeight = (cellsExist) ? CGRectGetHeight(layoutAttributes.frame) : 0;
                CGRect frameWithEdgeInsets = UIEdgeInsetsInsetRect(layoutAttributes.frame,
                                                                   collection.contentInset);
                
                CGPoint origin = frameWithEdgeInsets.origin;
                origin.y = MIN(
                               MAX(
                                   contentOffset.y + self.distanceFromVisibleTopPosition + collection.contentInset.top,
                                   (CGRectGetMinY(firstObjectAttrs.frame) - topHeaderHeight - self.minimumSectionSpace * 0.5)
                                   ),
                               (CGRectGetMaxY(lastObjectAttrs.frame))
                               );
                layoutAttributes.zIndex = 1024;
                layoutAttributes.frame = (CGRect){
                    .origin = origin,
                    .size = layoutAttributes.frame.size
                };
            }
        }
    }
    return willShowAttributes;
}

/**
 *  Cells
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *cellAttributes =
    [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    if ( self.cacheCell[indexPath] ) {
        UICollectionViewLayoutAttributes *cacheAttributes = self.cacheCell[indexPath];
        cellAttributes.frame = cacheAttributes.frame;
        return cellAttributes;
    }
    // 1. 取当前UICollectionView的宽度
    CGFloat collectioViewWidth = CGRectGetWidth(self.collectionView.frame);
    // 2. 计算cell的宽高
    CGFloat cellWidth = (collectioViewWidth - self.edgeInsets.left - self.edgeInsets.right - (self.columnCountsPerRow - 1) * self.minimumColumnSpace) / self.columnCountsPerRow;
    CGFloat cellHeight = [self.delegate layout:self heightForItemAtIndexPath:indexPath];
    
    // 3. 是否切换section
    __block CGFloat curColumnHeight = 0;
    __block NSUInteger targetColumnIndex = 0;
    if ( indexPath.section > _curSection ) {
        _curSection = indexPath.section;
        // 3.1.1. 取最大
        [self _find:YES completion:^(NSUInteger index, CGFloat height) {
            curColumnHeight = height;
        }];
        // 3.1.2. 更换Section后均从第0列开始布局
        targetColumnIndex = 0;
        // 3.1.3.1. 换section后的更新统一高度
        curColumnHeight -= self.minimumRowSpace;
        for (NSInteger i = 0; i < self.columnCountsPerRow; i++) {
            self.maxHeightForColumns[i] = @(curColumnHeight);
        }
    } else {
        // 3.1.3.2. 取最小
        [self _find:NO completion:^(NSUInteger index, CGFloat height) {
            curColumnHeight = height;
            targetColumnIndex = index;
        }];
    }
    // 4. 计算当前cell的frame
    CGFloat cellX = self.edgeInsets.left + targetColumnIndex * (cellWidth + self.minimumColumnSpace);
    CGFloat cellY = curColumnHeight;
    if (cellY != self.edgeInsets.top) {
        cellY += self.minimumRowSpace;
    }
    
    cellAttributes.frame = CGRectMake(cellX, cellY, cellWidth, cellHeight);
    // 5. 更新最短那列的高度
    self.maxHeightForColumns[targetColumnIndex] = @(CGRectGetMaxY(cellAttributes.frame));
    // 6. 记录内容的高度
    CGFloat curContentHeight = CGRectGetMaxY(cellAttributes.frame);
    if (self.curContentSizeHeight < curContentHeight) {
        self.curContentSizeHeight = curContentHeight;
    }
    if ( cellAttributes && !CGSizeEqualToSize(CGSizeZero, cellAttributes.frame.size) ) {
        [self.cacheCell setObject:cellAttributes forKey:indexPath];
        return cellAttributes;
    }
    return nil;
}

/**
 *  Supplementary views
 */
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath; {
    if ( [elementKind isEqualToString:UICollectionElementKindSectionHeader] ) {
        return [self _attributesForElementKindSectionHeaderAtIndexPath:indexPath];
    } else {
        // footer
        return [self _attributesForElementKindSectionFooterAtIndexPath:indexPath];
    }
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if ( self.needPinSectionHeaders ) {
        return YES;
    }
    if ( CGSizeEqualToSize(self.collectionView.bounds.size, newBounds.size)) {
        return NO;
    }
    return YES;
}

- (CGSize)collectionViewContentSize {
    if ( self.layoutCompletedContentSize ) {
        CGFloat contentSizeW = CGRectGetWidth(self.collectionView.frame);
        CGFloat contentSizeH = self.curContentSizeHeight + self.edgeInsets.bottom;
        self.layoutCompletedContentSize(CGSizeMake(contentSizeW, contentSizeH));
    }
    return CGSizeMake(0, self.curContentSizeHeight + self.edgeInsets.bottom);
}

#pragma mark - Helper
/**
 *  计算SectionHeader的Attributes
 */
- (nullable UICollectionViewLayoutAttributes *)_attributesForElementKindSectionHeaderAtIndexPath:(NSIndexPath *)indexPath {
    // 0. 查询缓存
    if ( self.cacheHeaders[indexPath] ) {
        return self.cacheCell[indexPath];
    }
    UICollectionViewLayoutAttributes *headerAttributes =
    [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
    // 1. 取当前kind的Size
    CGSize headerSize = self.headerReferenceSize;
    if ( [self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)] ) {
        headerSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:indexPath.section];
    }
    // 2. 重组headerAttributes，成功后缓存
    return [self _combineAttributes:headerAttributes withElementSize:headerSize indexPath:indexPath completion:^(UICollectionViewLayoutAttributes *attributes) {
            [self.cacheHeaders setObject:attributes forKey:indexPath];
    }];
}

/**
 *  计算SectionFooter的Attributes
 */
- (nullable UICollectionViewLayoutAttributes *)_attributesForElementKindSectionFooterAtIndexPath:(NSIndexPath *)indexPath {
    // 0. 查询缓存
    if ( self.cacheFooters[indexPath] ) {
        return self.cacheFooters[indexPath];
    }
    UICollectionViewLayoutAttributes *footerAttributes =
    [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:indexPath];
    // 1. 取当前kind的Size
    CGSize footerSize = self.footerReferenceSize;
    if ( [self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)] ) {
        footerSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:indexPath.section];
    }
    
    // 2. 重组headerAttributes，成功后缓存
    return [self _combineAttributes:footerAttributes withElementSize:footerSize indexPath:indexPath completion:^(UICollectionViewLayoutAttributes *attributes) {
        [self.cacheFooters setObject:attributes forKey:indexPath];
    }];
}

- (nullable UICollectionViewLayoutAttributes *)_combineAttributes:(UICollectionViewLayoutAttributes * _Nullable)attributes withElementSize:(CGSize)elementSize indexPath:(NSIndexPath *)indexPath completion:(void(^)(UICollectionViewLayoutAttributes *attributes))completion {
    __block CGFloat headerY = 0;
    [self _find:YES completion:^(NSUInteger index, CGFloat height) {
        headerY = height;
    }];
    // 2. 过滤size为CGSizeZero的footer
    if ( !CGSizeEqualToSize(CGSizeZero, elementSize) ) {
        CGFloat minimumSectionSpace = [self _minimumSectionSpaceAtSection:indexPath.section];
        headerY += minimumSectionSpace * 0.5;
        attributes.frame = CGRectMake(0, headerY, elementSize.width, elementSize.height);
        CGFloat curColumnHeight = CGRectGetMaxY(attributes.frame) + minimumSectionSpace * 0.5;
        for (NSInteger i = 0; i < self.columnCountsPerRow; i++) {
            self.maxHeightForColumns[i] = @(curColumnHeight);
        }
        [self.cacheFooters setObject:attributes forKey:indexPath];
        // 3. 记录内容的高度
        CGFloat curContentHeight = CGRectGetMaxY(attributes.frame);
        if (self.curContentSizeHeight < curContentHeight) {
            self.curContentSizeHeight = curContentHeight;
        }
        if ( completion ) {completion(attributes);}
        return attributes;
    }
    return nil;
}

/**
 *  查找最大或者最小的一行高度所在的columnIndex
 *
 *  @param maxOrMinHeight 最大或最小（YES:最大 | NO:最小）
 */
- (void)_find:(BOOL)maxOrMinHeight
  completion:(void(^)(NSUInteger index, CGFloat height))completion {
    NSUInteger targetColumnIndex = 0;
    CGFloat columnHeight = [self.maxHeightForColumns[0] floatValue];
    for (NSInteger i = 1; i < self.columnCountsPerRow; i++) {
        CGFloat curColumnHeight = [self.maxHeightForColumns[i] floatValue];
        if ( maxOrMinHeight ) {
            if (columnHeight < curColumnHeight) {
                columnHeight = curColumnHeight;
                targetColumnIndex = i;
            }
        } else {
            if (columnHeight > curColumnHeight) {
                columnHeight = curColumnHeight;
                targetColumnIndex = i;
            }
        }
    }
    if ( completion ) {
        completion(targetColumnIndex, columnHeight);
    };
}

- (CGFloat)_minimumSectionSpaceAtSection:(NSUInteger)section {
    CGFloat minimumSectionSpace = self.minimumSectionSpace;
    if ( [self.delegate respondsToSelector:@selector(minimumSectionSpacingInLayout:atSection:)] ) {
        minimumSectionSpace = [self.delegate minimumSectionSpacingInLayout:self atSection:section];
    }
    return minimumSectionSpace;
}

- (void)_prepareLayoutAttributes {
    NSUInteger curSectionCount = [self.collectionView numberOfSections];
    for (NSUInteger section = 0; section < curSectionCount; section++) {
        // Headers
        _dataSource = self.collectionView.dataSource;
        if ( self.dataSource && [self.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)] ) {
            NSIndexPath *headerIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];;
            UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:headerIndexPath];
            if ( attrs ) {
                [self.layoutAttributes addObject:attrs];
            }
        }
        // Cells
        NSInteger itemsCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger i = 0; i < itemsCount; i++) {
            // 创建Cell位置
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:i inSection:section];
            // 获取indexPath位置cell对应的布局属性
            UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:cellIndexPath];
            if ( attrs ) {
                [self.layoutAttributes addObject:attrs];
            }
        }
        // Footers
        if ( self.dataSource && [self.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)] ) {
            NSIndexPath *footerIndexPath = [NSIndexPath indexPathForRow:(itemsCount - 1) inSection:section];;
            UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:footerIndexPath];
            if ( attrs ) {
                [self.layoutAttributes addObject:attrs];
            }
        }
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)_willShowAttributesForElementsInVisibleBounds {
    
    CGRect visibleRect = (CGRect){
        .origin = self.collectionView.contentOffset,
        .size = self.collectionView.bounds.size
    };
    NSMutableArray<UICollectionViewLayoutAttributes *> *willShowAttributes = [NSMutableArray array];
    [self.layoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attributes, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( CGRectIntersectsRect(attributes.frame, visibleRect) ) {
            [willShowAttributes addObject:attributes];
        }
    }];
    
    if ( self.needPinSectionHeaders ) {
        [self.cacheHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, UICollectionViewLayoutAttributes * _Nonnull obj, BOOL * _Nonnull stop) {
            [willShowAttributes addObject:obj];
        }];
    }
    return [willShowAttributes copy];
}

//- (NSArray)

/**
 *  与source相比较，target是否是有有效的数据
 */
- (BOOL)isValid:(CGFloat)target compare:(CGFloat)source {
    return (target >= 0 && target != source);
}

#pragma mark - Getter & Setter
- (CGFloat)minimumRowSpace {
    if ( [self.delegate respondsToSelector:@selector(minimumRowSpacingInLayout:)] ) {
        return [self.delegate minimumRowSpacingInLayout:self];
    } else {
        return _minimumRowSpace;
    }
}

- (void)setMinimumRowSpace:(CGFloat)minimumRowSpace {
    if ( [self isValid:minimumRowSpace compare:_minimumRowSpace] ) {
        _minimumColumnSpace = minimumRowSpace;
        [self invalidateLayout];
    }
}

- (CGFloat)minimumColumnSpace {
    if ( [self.delegate respondsToSelector:@selector(minimumColumnSpacingInLayout:)] ) {
        return [self.delegate minimumColumnSpacingInLayout:self];
    } else {
        return _minimumColumnSpace;
    }
}

- (void)setMinimumColumnSpace:(CGFloat)minimumColumnSpace {
    if ( [self isValid:minimumColumnSpace compare:_minimumColumnSpace] ) {
        _minimumColumnSpace = minimumColumnSpace;
        [self invalidateLayout];
    }
}

- (NSUInteger)columnCountsPerRow {
    if ( [self.delegate respondsToSelector:@selector(columnCountsPerRowInLayout:)] ) {
        return [self.delegate columnCountsPerRowInLayout:self];
    } else {
        return _columnCountsPerRow;
    }
}

- (void)setColumnCountsPerRow:(NSUInteger)columnCountsPerRow {
    if ( _columnCountsPerRow != columnCountsPerRow ) {
        _columnCountsPerRow = columnCountsPerRow;
        [self invalidateLayout];
    }
}

- (UIEdgeInsets)edgeInsets {
    if ( [self.delegate respondsToSelector:@selector(edgeInsetsInCollectionViewForLayout:)] ) {
        return [self.delegate edgeInsetsInCollectionViewForLayout:self];
    } else {
        return _edgeInsets;
    }
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    if ( !UIEdgeInsetsEqualToEdgeInsets(_edgeInsets, edgeInsets) ) {
        _edgeInsets = edgeInsets;
        [self invalidateLayout];
    }
}

- (void)setDistanceFromVisibleTopPosition:(CGFloat)distanceFromVisibleTopPosition {
    if ( _distanceFromVisibleTopPosition != distanceFromVisibleTopPosition ) {
        _distanceFromVisibleTopPosition = distanceFromVisibleTopPosition;
        [self invalidateLayout];
    }
}
@end
