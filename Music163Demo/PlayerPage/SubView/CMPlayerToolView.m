//
//  CMPlayerToolView.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/20.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "CMPlayerToolView.h"

static UIButton *CMPlayerToolBtn(UIImage *normalImg, UIImage *highlightImg, UIImage *selectedImg) {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:normalImg forState:UIControlStateNormal];
    [btn setImage:highlightImg forState:UIControlStateHighlighted];
    [btn setImage:selectedImg forState:UIControlStateSelected];
    return btn;
}

@interface CMPlayerToolView ()

@property (nonatomic, strong) UIButton *loveBtn;
@property (nonatomic, strong) UIButton *downloadBtn;
@property (nonatomic, strong) UIButton *effectBtn;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *moreBtn;

@end

@implementation CMPlayerToolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self viewTemplete];
        [self configConstraint];
    }
    return self;
}

#pragma mark - Render

- (void)viewTemplete {
    [self addSubview:self.loveBtn];
    [self addSubview:self.downloadBtn];
    [self addSubview:self.effectBtn];
    [self addSubview:self.commentBtn];
    [self addSubview:self.moreBtn];
}

- (void)configConstraint {
    [self.effectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
    
    [self.downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.centerX.mas_equalTo(-CMRatioPx(60));
    }];
    
    [self.loveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.centerX.mas_equalTo(-CMRatioPx(120));
    }];
    
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.centerX.mas_equalTo(CMRatioPx(60));
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.centerX.mas_equalTo(CMRatioPx(120));
    }];
    
}

#pragma mark - Get

- (UIButton *)loveBtn {
    if (!_loveBtn) {
        _loveBtn = CMPlayerToolBtn(UIImage(@"cm2_play_icn_love"), UIImage(@"cm2_play_icn_love_prs"), UIImage(@"cm2_play_icn_loved"));
        _loveBtn.touchUpInsideBlock = ^(UIButton * _Nonnull __weak button) {
            button.selected = !button.selected;
        };
    }
    return _loveBtn;
}

- (UIButton *)downloadBtn {
    if (!_downloadBtn) {
        _downloadBtn = CMPlayerToolBtn(UIImage(@"cm2_play_icn_dld"), UIImage(@"cm2_play_icn_dld_prs"), UIImage(@""));
    }
    return _downloadBtn;
}

- (UIButton *)effectBtn {
    if (!_effectBtn) {
        _effectBtn = CMPlayerToolBtn(UIImage(@"cm5_topbar_icn_effect"), UIImage(@"cm5_topbar_icn_effect_press"), UIImage(@""));
    }
    return _effectBtn;
}

- (UIButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = CMPlayerToolBtn(UIImage(@"cm2_play_icn_cmt_num"), UIImage(@"cm2_play_icn_cmt_num_prs"), UIImage(@""));
    }
    return _commentBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = CMPlayerToolBtn(UIImage(@"cm2_play_icn_more"), UIImage(@"cm2_play_icn_more_prs"), UIImage(@""));
    }
    return _moreBtn;
}


@end
