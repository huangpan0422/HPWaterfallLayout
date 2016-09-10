//
//  HPCollectionReusableView.m
//  iCarouselTest
//
//  Created by huangpan on 16/9/6.
//  Copyright © 2016年 Leon. All rights reserved.
//

#import "HPCollectionReusableView.h"

@interface HPCollectionReusableView ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HPCollectionReusableView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor grayColor];
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
    [self addSubview:self.titleLabel];
    // 布局
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}
@end


#pragma mark - HPCollectionHeaderReusableView
@implementation HPCollectionHeaderReusableView
- (void)setUp {
    [super setUp];
    self.backgroundColor = [UIColor redColor];
}
@end

#pragma mark - HPCollectionFooterReusableView
@implementation HPCollectionFooterReusableView
- (void)setUp {
    [super setUp];
    self.backgroundColor = [UIColor darkGrayColor];
}
@end
