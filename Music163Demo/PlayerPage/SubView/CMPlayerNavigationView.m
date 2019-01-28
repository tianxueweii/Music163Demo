//
//  CMPlayerNavigationView.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/20.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "CMPlayerNavigationView.h"
#import "CMPlayerItem.h"

@interface CMPlayerNavigationView()

@property (nonatomic, strong) UILabel *musicNameLable;

@property (nonatomic, strong) UIButton *musicAuthorButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIView *line;

@end

@implementation CMPlayerNavigationView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self viewTemplete];
        [self configConstraint];
    }
    return self;
}

#pragma mark - Interface

- (void)renderNavigationViewWithPlayerItem:(CMPlayerItem *)playerItem {
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.2;
    transition.type = @"fade";
    
    [self.musicAuthorButton setTitle:playerItem.musicAuthor forState:UIControlStateNormal];
    [self.musicNameLable setText:playerItem.musicName];
    
    [self.musicAuthorButton.layer addAnimation:transition forKey:nil];
    [self.musicNameLable.layer addAnimation:transition forKey:nil];
}

#pragma mark - Render

- (void)viewTemplete {
    [self addSubview:self.musicNameLable];
    [self addSubview:self.backButton];
    [self addSubview:self.shareButton];
    [self addSubview:self.musicAuthorButton];
    [self addSubview:self.line];
}

- (void)configConstraint {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.musicNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(10);
    }];
    
    [self.musicAuthorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-5);
        make.height.mas_equalTo(10);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - Get

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.3];
    }
    return _line;
}

- (UILabel *)musicNameLable {
    if (!_musicNameLable) {
        _musicNameLable = [[UILabel alloc] init];
        _musicNameLable.font = [UIFont systemFontOfSize:15];
        _musicNameLable.textColor = CM_TEXT_COLOR_WHT;
    }
    return _musicNameLable;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:UIImage(@"cm2_topbar_icn_back") forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(handleBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setImage:UIImage(@"cm2_list_detail_icn_share") forState:UIControlStateNormal];
        [_shareButton setImage:UIImage(@"cm2_list_detail_icn_share_prs") forState:UIControlStateHighlighted];
        [_shareButton setImage:UIImage(@"cm2_list_detail_icn_share_dis") forState:UIControlStateDisabled];
    }
    return _shareButton;
}

- (UIButton *)musicAuthorButton {
    if (!_musicAuthorButton) {
        _musicAuthorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _musicAuthorButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [_musicAuthorButton setTitleColor:CM_TEXT_COLOR_WHT forState:UIControlStateNormal];
    }
    return _musicAuthorButton;
}

#pragma mark - Action

- (void)handleBackButtonAction:sender {
    if (self.backButtonClickBlock) {
        self.backButtonClickBlock(sender);
    }
}

@end
