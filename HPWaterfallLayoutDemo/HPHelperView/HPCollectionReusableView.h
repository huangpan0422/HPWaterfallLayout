//
//  HPCollectionReusableView.h
//  iCarouselTest
//
//  Created by huangpan on 16/9/6.
//  Copyright © 2016年 Leon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPCollectionReusableView : UICollectionReusableView
@property (nonatomic, copy) NSString *title;
/**
 *  初始化一些数据，子类可重写，若不call supper，title不能直接显示
 */
- (void)setUp;
@end

@interface HPCollectionHeaderReusableView : HPCollectionReusableView

@end


@interface HPCollectionFooterReusableView : HPCollectionReusableView

@end