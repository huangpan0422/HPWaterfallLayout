//
//  HPCollectionViewCell.m
//  iCarouselTest
//
//  Created by huangpan on 16/9/2.
//  Copyright © 2016年 Leon. All rights reserved.
//

#import "HPCollectionViewCell.h"


@interface HPCollectionViewCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HPCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if ( self= [super initWithFrame:frame] ) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    //
    _titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.titleLabel];
    // 布局
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}
@end
