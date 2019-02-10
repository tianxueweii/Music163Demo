//
//  CMPlayerRecordItemView.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/20.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "CMPlayerRecordItemView.h"
#import "CMPlayerItem.h"

@interface CMPlayerRecordItemView ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *recordBorderImageView;

@end

@implementation CMPlayerRecordItemView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self viewTemplete];
        [self configConstraint];
    }
    return self;
}

#pragma mark - Render
- (void)viewTemplete {
    [self addSubview:self.coverImageView];
    [self.coverImageView addSubview:self.recordBorderImageView];
}

- (void)configConstraint {
    [self.recordBorderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(_isiPhoneXSeries ? CGSizeMake(CMRatioPx(330), CMRatioPx(330)) : CGSizeMake(CMRatioPx(325), CMRatioPx(325)));
    }];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(CMRatioPx(200), CMRatioPx(200)));
    }];
}

#pragma mark - Get

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
    }
    return _coverImageView;
}

- (UIImageView *)recordBorderImageView {
    if (!_recordBorderImageView) {
//        _recordBorderImageView = [[UIImageView alloc] initWithImage:_isiPhoneXSeries ? UIImage(@"cm2_play_disc-ipx") : UIImage(@"cm2_play_disc")];
        _recordBorderImageView = [[UIImageView alloc] initWithImage:UIImage(@"cm4_play_disc")];
    }
    return _recordBorderImageView;
}

#pragma mark - Interface

- (void)cleanUp {
    self.coverImageView.image = nil;
    self.coverImageView.layer.speed = 0;
    self.coverImageView.layer.timeOffset = 0.0;
    self.coverImageView.layer.beginTime = 0.0;
}

- (void)renderRecordCellWithPlayerItem:(CMPlayerItem *)playerItem {
    weakDef(self)
    [[SDWebImageManager sharedManager] loadImageWithURL:playerItem.musicCoverURL options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        // 该回调在主线程，调用异步切割图片方法
        [UIImage xw_clipCircleImage:image completion:^(UIImage * _Nonnull img) {
            weak_self.coverImageView.image = img;
        }];
    }];
}

@end
