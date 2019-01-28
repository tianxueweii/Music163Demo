//
//  CMPlayerVehicleView.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/19.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "CMPlayerVehicleView.h"
#import "CMPlayer.h"

@interface CMPlayerVehicleView ()

@property (nonatomic, weak) CMPlayer *player;
@property (nonatomic, strong) id<AspectToken> playerAspectToken;

#pragma mark -
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *prevBtn;
@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) UIButton *modeSwitchBtn;
@property (nonatomic, strong) UIButton *playListBtn;


@end

@implementation CMPlayerVehicleView

- (instancetype)initWithPlayer:(CMPlayer *)player {
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.player = player;
        
        [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
        [self.player addObserver:self forKeyPath:@"playerMode" options:NSKeyValueObservingOptionNew context:nil];
        
        self.playerAspectToken = [self.player aspect_hookSelector:NSSelectorFromString(@"dealloc") withOptions:AspectPositionAfter usingBlock:^{
            [self.player removeObserver:self forKeyPath:@"timeControlStatus" context:nil];
            [self.player removeObserver:self forKeyPath:@"playerMode" context:nil];
        } error:nil];
        
        [self viewTemplete];
        [self configConstraint];
    }
    return self;
}

- (void)dealloc {
    [self.playerAspectToken remove];
    [self.player removeObserver:self forKeyPath:@"timeControlStatus" context:nil];
    [self.player removeObserver:self forKeyPath:@"playerMode" context:nil];
}

#pragma mark - Observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"timeControlStatus"]) {
        [self renderPlayBtnWithStatus:self.player.timeControlStatus];
    } else if ([keyPath isEqualToString:@"playerMode"]) {
        [self renderModeSwitchBtnWithMode:self.player.playerMode];
    }
    
}

#pragma mark - Render

- (void)viewTemplete {
    [self addSubview:self.playBtn];
    [self addSubview:self.modeSwitchBtn];
    [self addSubview:self.prevBtn];
    [self addSubview:self.nextBtn];
    [self addSubview:self.playListBtn];
}

- (void)configConstraint {
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
    
    [_modeSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(CMRatioPx(15));
        make.centerY.mas_equalTo(self.playBtn);
    }];
    
    [_playListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-CMRatioPx(15));
        make.centerY.mas_equalTo(self.playBtn);
    }];
    
    [_prevBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.playBtn.mas_left).mas_offset(-CMRatioPx(25));
        make.centerY.mas_equalTo(self.playBtn);
    }];
    
    [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playBtn.mas_right).mas_offset(CMRatioPx(25));
        make.centerY.mas_equalTo(self.playBtn);
    }];
}

- (void)renderPlayBtnWithStatus:(AVPlayerTimeControlStatus)status {
    switch (status) {
        case AVPlayerTimeControlStatusPaused: {
            [self.playBtn setImage:UIImage(@"cm2_fm_btn_play") forState:UIControlStateNormal];
            [self.playBtn setImage:UIImage(@"cm2_fm_btn_play_prs") forState:UIControlStateHighlighted];
            break;
        }
        case AVPlayerTimeControlStatusPlaying: {
            [self.playBtn setImage:UIImage(@"cm2_fm_btn_pause") forState:UIControlStateNormal];
            [self.playBtn setImage:UIImage(@"cm2_fm_btn_pause_prs") forState:UIControlStateHighlighted];
            break;
        }
        case AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate: {
            // loading
            [self.playBtn setImage:UIImage(@"cm2_fm_btn_pause") forState:UIControlStateNormal];
            [self.playBtn setImage:UIImage(@"cm2_fm_btn_pause_prs") forState:UIControlStateHighlighted];
            break;
        }
    }
}

/**
 根据mode渲染按钮
 因为有多处控制mode，所以利用监听渲染

 @param mode 播放mode
 */
- (void)renderModeSwitchBtnWithMode:(CMPlayerMode)mode {
    switch (mode) {
        case CMPlayerModeOne: {
            [self.modeSwitchBtn setImage:UIImage(@"cm2_icn_one") forState:UIControlStateNormal];
            [self.modeSwitchBtn setImage:UIImage(@"cm2_icn_one_prs") forState:UIControlStateHighlighted];
            break;
        }
        case CMPlayerModeLoop: {
            [self.modeSwitchBtn setImage:UIImage(@"cm2_icn_loop") forState:UIControlStateNormal];
            [self.modeSwitchBtn setImage:UIImage(@"cm2_icn_loop_prs") forState:UIControlStateHighlighted];
            break;
        }
        case CMPlayerModeShuffle: {
            [self.modeSwitchBtn setImage:UIImage(@"cm2_icn_shuffle") forState:UIControlStateNormal];
            [self.modeSwitchBtn setImage:UIImage(@"cm2_icn_shuffle_prs") forState:UIControlStateHighlighted];
            break;
        }
    }
}

#pragma mark - Get

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self renderPlayBtnWithStatus:self.player.timeControlStatus];
        weakDef(self)
        _playBtn.touchUpInsideBlock = ^(UIButton * _Nonnull __weak button) {
            if (weak_self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
                [weak_self.player pause];
            } else {
                [weak_self.player play];
            }
        };
    }
    return _playBtn;
}

- (UIButton *)modeSwitchBtn {
    if (!_modeSwitchBtn) {
        _modeSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self renderModeSwitchBtnWithMode:self.player.playerMode];
        weakDef(self)
        _modeSwitchBtn.touchUpInsideBlock = ^(UIButton * _Nonnull __weak button) {
            switch (weak_self.player.playerMode) {
                case CMPlayerModeLoop:
                    weak_self.player.playerMode = CMPlayerModeOne;
                    break;
                case CMPlayerModeOne:
                    weak_self.player.playerMode = CMPlayerModeShuffle;
                    break;
                case CMPlayerModeShuffle:
                    weak_self.player.playerMode = CMPlayerModeLoop;
                    break;
                default:
                    weak_self.player.playerMode = CMPlayerModeLoop;
                    break;
            }
        };
    }
    return _modeSwitchBtn;
}

- (UIButton *)playListBtn {
    if (!_playListBtn) {
        _playListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playListBtn setImage:UIImage(@"cm2_icn_list") forState:UIControlStateNormal];
        [_playListBtn setImage:UIImage(@"cm2_icn_list_prs") forState:UIControlStateHighlighted];
        
        _playListBtn.touchUpInsideBlock = ^(UIButton * _Nonnull __weak button) {
            NSLog(@"点击播放列表");
        };
    }
    return _playListBtn;
}

- (UIButton *)prevBtn {
    if (!_prevBtn) {
        _prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_prevBtn setImage:UIImage(@"cm2_play_btn_prev") forState:UIControlStateNormal];
        [_prevBtn setImage:UIImage(@"cm2_play_btn_prev_prs") forState:UIControlStateHighlighted];
        
        weakDef(self)
        _prevBtn.touchUpInsideBlock = ^(UIButton * _Nonnull __weak button) {
            [weak_self.player prev];
        };
    }
    return _prevBtn;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_nextBtn setImage:UIImage(@"cm2_fm_btn_next") forState:UIControlStateNormal];
        [_nextBtn setImage:UIImage(@"cm2_fm_btn_next_prs") forState:UIControlStateHighlighted];
        
        weakDef(self)
        _nextBtn.touchUpInsideBlock = ^(UIButton * _Nonnull __weak button) {
            [weak_self.player next];
        };
    }
    return _nextBtn;
}

@end
