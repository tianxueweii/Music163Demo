//
//  CMPlayerViewController.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/16.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "CMPlayerViewController.h"
#import "CMPlayerVehicleView.h"
#import "CMPlayerToolView.h"
#import "CMPlayerProgressView.h"
#import "CMPlayerNavigationView.h"

#import "CMPlayerRecordMachineView.h"

#import "CMPlayer.h"
#import "CMPlayerItem.h"



@interface CMPlayerViewController ()<CMPlayerDelegate, UIScrollViewDelegate>

/**
 播放列表
 */
@property (nonatomic, strong) NSArray *playList;
@property (nonatomic, strong) CMPlayer *player;

/**
 背景
 */
@property (nonatomic, strong) UIImageView *backgroundImageView;

/**
 导航栏
 */
@property (nonatomic, strong) CMPlayerNavigationView *navigationView;
/**
 唱片视图
 */
@property (nonatomic, strong) CMPlayerRecordMachineView *recordContainerView;
/**
 工具栏
 */
@property (nonatomic, strong) CMPlayerToolView *toolView;
/**
 进度栏
 */
@property (nonatomic, strong) CMPlayerProgressView *progressView;
/**
 操作栏
 */
@property (nonatomic, strong) CMPlayerVehicleView *vehicleView;

@end

@implementation CMPlayerViewController

+ (instancetype)sharedPlayerViewController {
    static dispatch_once_t onceToken;
    static id ins;
    dispatch_once(&onceToken, ^{
        ins = [[self alloc] init];
    });
    return ins;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.contents = (__bridge id _Nullable)UIImage(@"cm2_fm_bg").CGImage;
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    [self.view addSubview:self.backgroundImageView];

    // 高斯模糊
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurView.frame = self.view.bounds;
    [self.view addSubview:blurView];
    
    // 初始化子视图
    [self viewTemplete];
    [self configConstraint];
    
    // 初始渲染
    [self.view layoutIfNeeded];
    [self.recordContainerView renderRecordItemsWithPlayQueue:self.player.currentPlayingQueue];
    [self.navigationView renderNavigationViewWithPlayerItem:self.player.currentMusicItem];
    [self.progressView renderViewWithCurrentSeconds:0 durationSeconds:0 buffer:0];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Render

- (void)viewTemplete {
    
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.toolView];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.vehicleView];
    [self.view addSubview:self.recordContainerView];
}

- (void)configConstraint {
    [_navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_statusBarHeight);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    
    [_toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.progressView.mas_top);
        make.height.mas_equalTo(_isiPhoneXSeries ? 60 : 40);
    }];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.vehicleView.mas_top);
        make.height.mas_equalTo(_isiPhoneXSeries ? 45 : 30);
    }];
    
    [_vehicleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(_isiPhoneXSeries ? -24 : -10);
        make.height.mas_equalTo(_isiPhoneXSeries ? 75 : 68);
    }];
    
    [_recordContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_isiPhoneXSeries ? 88: 64);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.toolView.mas_top);
    }];
}

#pragma mark - CMPlayerDelegate

- (void)musicPlayerPlayingProgressCurrenSeconds:(NSTimeInterval)currentSec duration:(NSTimeInterval)durationSec buffer:(NSTimeInterval)bufferSec;{
    [self.progressView renderViewWithCurrentSeconds:currentSec durationSeconds:durationSec buffer:bufferSec];
}

- (void)musicPlayerStatusNext:(CMPlayer *)player musicPlayerItem:(CMPlayerItem *)item {
    weakDef(self)
    [weak_self.navigationView renderNavigationViewWithPlayerItem:weak_self.player.currentMusicItem];
    [self.recordContainerView nextActionComp:^NSArray *{
        return weak_self.player.currentPlayingQueue;
    }];
}

- (void)musicPlayerStatusPrev:(CMPlayer *)player musicPlayerItem:(CMPlayerItem *)item {
    weakDef(self)
    [weak_self.navigationView renderNavigationViewWithPlayerItem:weak_self.player.currentMusicItem];
    [self.recordContainerView prevActionComp:^NSArray *{
        return weak_self.player.currentPlayingQueue;
    }];
}

- (void)musicPlayerStatusPlaying:(CMPlayer *)player musicPlayerItem:(CMPlayerItem *)item {
    [self.recordContainerView playAction];
    
    CATransition *trans = [CATransition animation];
    trans.type = @"fade";
    trans.duration = 0.5;
    
    [self.backgroundImageView.layer addAnimation:trans forKey:nil];
    [self.backgroundImageView sd_setImageWithURL:item.musicCoverURL];
}

- (void)musicPlayerStatusPaused:(CMPlayer *)player musicPlayerItem:(CMPlayerItem *)item {
    [self.recordContainerView pauseAction];
}

#pragma mark - Get

- (CMPlayer *)player {
    if (!_player) {
        _player = [[CMPlayer alloc] initWithPlayList:self.playList];
        _player.delegate = self;
    }
    return _player;
}

- (CMPlayerNavigationView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[CMPlayerNavigationView alloc] init];
        weakDef(self)
        _navigationView.backButtonClickBlock = ^(UIButton * _Nonnull __weak button) {
            [weak_self.navigationController popViewControllerAnimated:YES];
        };
    }
    return _navigationView;
}

- (CMPlayerRecordMachineView *)recordContainerView {
    if (!_recordContainerView) {
        _recordContainerView = [[CMPlayerRecordMachineView alloc] initWithPlayer:self.player];
        _recordContainerView.clipsToBounds = YES;
        weakDef(self)
        _recordContainerView.nextDragActionComp = ^NSArray * _Nonnull{
            [weak_self.player next];
            return weak_self.player.currentPlayingQueue;
        };
        _recordContainerView.prevDragActionComp = ^NSArray * _Nonnull{
            [weak_self.player prev];
            return weak_self.player.currentPlayingQueue;
        };
    }
    return _recordContainerView;
}


- (CMPlayerToolView *)toolView {
    if (!_toolView) {
        _toolView = [[CMPlayerToolView alloc] init];
    }
    return _toolView;
}

- (CMPlayerProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[CMPlayerProgressView alloc] init];
        weakDef(self)
        _progressView.dragCompleteBlock = ^(NSTimeInterval seconds, CGFloat rate) {
            [weak_self.player seekToTime:CMTimeMakeWithSeconds(seconds, weak_self.player.currentItem.duration.timescale)
                         toleranceBefore:CMTimeMakeWithSeconds(1, weak_self.player.currentItem.duration.timescale)
                          toleranceAfter:kCMTimeZero];
        };
    }
    return _progressView;
}

- (CMPlayerVehicleView *)vehicleView {
    if (!_vehicleView) {
        _vehicleView = [[CMPlayerVehicleView alloc] initWithPlayer:self.player];
    }
    return _vehicleView;
}


#pragma mark - Data

/**
 文件获取播放列表
 */
- (NSArray *)playList {
    if (!_playList) {
        NSMutableArray *mutableArr = [NSMutableArray array];
        NSArray *playListArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MusicPlayList" ofType:@"plist"]];
        for (NSDictionary *music in playListArr) {
            CMPlayerItem *item = [CMPlayerItem musicPlayItemWithURL:[NSURL URLWithString:music[@"URL"]]
                                                               name:music[@"Name"]
                                                             author:music[@"Author"]
                                                           coverURL:[NSURL URLWithString:
                                                                     [NSString stringWithFormat:@"%@?param=300y300", music[@"CoverURL"]]]];
            [mutableArr addObject:item];
        }
        _playList = mutableArr.copy;
    }
    return _playList;
}

@end
