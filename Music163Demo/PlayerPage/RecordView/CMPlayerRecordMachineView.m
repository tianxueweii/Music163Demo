//
//  CMPlayerRecordMachineView.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/20.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "CMPlayerRecordMachineView.h"
#import "CMPlayerRecordItemView.h"
#import "CMPlayerRecordMachineView.h"
#import "CMPlayer.h"


#define CMPLAYER_RECORD_COVER_LAYER self.playingRecordItemView.coverImageView.layer

NSString *const CMPLAYER_RECORD_PLAY_ANIMATION_KEY = @"com.cmplayer.record.play";
NSString *const CMPLAYER_RECORD_NEEDLE_ANIMATION_KEY = @"com.cmplayer.record.needle";

static CMPlayerRecordItemView *CMPlayerRecordItemViewCreate() {
    CMPlayerRecordItemView *item = [[CMPlayerRecordItemView alloc] init];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue = [NSNumber numberWithFloat: M_PI *2];
    animation.duration = 20;
    animation.autoreverses = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatDuration = INFINITY; // 无限播放
    animation.removedOnCompletion = NO;  // 完成时不移除
    
    item.coverImageView.layer.speed = 0.0;
    item.coverImageView.layer.beginTime = 0.0;
    [item.coverImageView.layer addAnimation:animation forKey:CMPLAYER_RECORD_PLAY_ANIMATION_KEY];
    
    return item;
}

@interface CMPlayerRecordMachineView()<UIScrollViewDelegate>

@property (nonatomic, weak) CMPlayer *player;

@property (nonatomic, strong) UIImageView *needleImageView;
@property (nonatomic, strong) UIScrollView *recordScrollView;
@property (nonatomic, strong) UIImageView *recordBackgroundCircle;

@property (nonatomic, strong) CMPlayerRecordItemView *firstRecordItemView;
@property (nonatomic, strong) CMPlayerRecordItemView *secondRecordItemView;
@property (nonatomic, strong) CMPlayerRecordItemView *thirdRecordItemView;

// 指向当前播放View节点
@property (nonatomic, weak) CMPlayerRecordItemView *playingRecordItemView;

/**
 完成滚动
 
 @return 播放队列刷新唱片
 */
@property (nonatomic, copy) CMPlayerRecordActionBlock reordScrollActionComp;
@end

@implementation CMPlayerRecordMachineView

- (instancetype)initWithPlayer:(CMPlayer *)player {
    self = [super init];
    if (self) {
        self.player = player;
        [self initRecordItems];
        [self viewTemplete];
        [self configConstraint];
    }
    return self;
}

#pragma mark - Render

- (void)viewTemplete {
    
    [self addSubview:self.needleImageView];
    [self addSubview:self.recordBackgroundCircle];
    [self addSubview:self.recordScrollView];
    
    [self.recordScrollView addSubview:self.firstRecordItemView];
    [self.recordScrollView addSubview:self.secondRecordItemView];
    [self.recordScrollView addSubview:self.thirdRecordItemView];
    
    [self sendSubviewToBack:self.recordBackgroundCircle];
    [self bringSubviewToFront:self.needleImageView];
    
}

- (void)configConstraint {
    
    [_recordScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [_recordBackgroundCircle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.recordScrollView.mas_centerX);
        make.centerY.mas_equalTo(self.recordScrollView.mas_centerY).mas_offset(0);
        make.size.mas_equalTo(_isiPhoneXSeries ? CGSizeMake(CMRatioPx(310), CMRatioPx(310)) : CGSizeMake(CMRatioPx(300), CMRatioPx(300)));
    }];
}


- (void)initRecordItems {
    /**
     双链表，playing指针指向播放itemView
        1
      ↗︎     ⤵︎
     3    ←   2  ← playing
     */
    _firstRecordItemView = CMPlayerRecordItemViewCreate();
    _secondRecordItemView = CMPlayerRecordItemViewCreate();
    _thirdRecordItemView = CMPlayerRecordItemViewCreate();
    
    _firstRecordItemView.nextView = _secondRecordItemView;
    _firstRecordItemView.prevView = _thirdRecordItemView;
    
    _secondRecordItemView.nextView = _thirdRecordItemView;
    _secondRecordItemView.prevView = _firstRecordItemView;
    
    _thirdRecordItemView.nextView = _firstRecordItemView;
    _thirdRecordItemView.prevView = _secondRecordItemView;
    
    self.playingRecordItemView = _secondRecordItemView;
    
}

- (void)renderRecordItemsWithPlayQueue:(NSArray *)queue {
    
    [self.playingRecordItemView.prevView cleanUp];
    [self.playingRecordItemView.nextView cleanUp];
    
    [self.playingRecordItemView.prevView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(_screenWidth);
        make.height.mas_equalTo(self.recordScrollView.frame.size.height);
    }];
    [self.playingRecordItemView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playingRecordItemView.prevView.mas_right);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(_screenWidth);
        make.height.mas_equalTo(self.recordScrollView.frame.size.height);
    }];
    [self.playingRecordItemView.nextView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playingRecordItemView.mas_right);
        make.top.bottom.right.mas_equalTo(0);
        make.width.mas_equalTo(_screenWidth);
        make.height.mas_equalTo(self.recordScrollView.frame.size.height);
    }];
    
    [self.playingRecordItemView renderRecordCellWithPlayerItem:queue[1]];
    [self.playingRecordItemView.prevView renderRecordCellWithPlayerItem:queue[0]];
    [self.playingRecordItemView.nextView renderRecordCellWithPlayerItem:queue[2]];
    
    [self.recordScrollView setContentOffset:CGPointMake(_screenWidth, 0) animated:NO];
    
}


#pragma mark - Get

- (UIImageView *)needleImageView {
    if (!_needleImageView) {
        // _needleImageView = [[UIImageView alloc] initWithImage:UIImage(@"cm2_play_needle_play-ipx")];
        _needleImageView = [[UIImageView alloc] initWithImage:_isiPhoneXSeries ? UIImage(@"cm4_play_needle_play_long") : UIImage(@"cm4_play_needle_play")];
        _needleImageView.center = CGPointMake(_screenWidth / 2, 0);
        // 默认偏移
        _needleImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI * 30.f / 180.f);
    }
    return _needleImageView;
}

- (UIScrollView *)recordScrollView {
    if (!_recordScrollView) {
        _recordScrollView = [[UIScrollView alloc] init];
        _recordScrollView.delegate = self;
        _recordScrollView.pagingEnabled = YES;
        _recordScrollView.bounces = NO;
        _recordScrollView.showsVerticalScrollIndicator = NO;
        _recordScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _recordScrollView;
}

- (UIImageView *)recordBackgroundCircle {
    if (!_recordBackgroundCircle) {
        _recordBackgroundCircle = [[UIImageView alloc] initWithImage:UIImage(@"cm2_runfm_circle")];
    }
    return _recordBackgroundCircle;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 首饰开始，暂停动画
    [self pauseAction];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x > _screenWidth && self.nextDragActionComp) {
        // 下一首
        [self renderRecordItemsWithPlayQueue:self.nextDragActionComp()];
    } else if (scrollView.contentOffset.x < _screenWidth && self.prevDragActionComp) {
        // 上一首
        [self renderRecordItemsWithPlayQueue:self.prevDragActionComp()];
    } else {
        // 当前首
        if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
            [self playAction];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 拖拽结束不减速
    if (!decelerate) {
        if (scrollView.contentOffset.x > _screenWidth && self.nextDragActionComp) {
            // 下一首
            [self renderRecordItemsWithPlayQueue:self.nextDragActionComp()];
        } else if (scrollView.contentOffset.x < _screenWidth && self.prevDragActionComp) {
            // 上一首
            [self renderRecordItemsWithPlayQueue:self.prevDragActionComp()];
        } else {
            // 当前首
            if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
                [self playAction];
            }
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.reordScrollActionComp) {
        [self renderRecordItemsWithPlayQueue:self.reordScrollActionComp()];
    }
}

#pragma mark - Interface Action

- (void)playAction {
    if (self.recordScrollView.isDragging || self.recordScrollView.isDecelerating) {
        return;
    }
    
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.needleImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        // 重新设置动画时间轴，从-pausedTime开始播放
        CFTimeInterval pausedTime = CMPLAYER_RECORD_COVER_LAYER.timeOffset;
        CMPLAYER_RECORD_COVER_LAYER.speed = 1.0;
        CMPLAYER_RECORD_COVER_LAYER.timeOffset = 0.0;
        CMPLAYER_RECORD_COVER_LAYER.beginTime = 0;
        // timeSincePause相对当前时间负pausedTime
        CFTimeInterval timeSincePause = [CMPLAYER_RECORD_COVER_LAYER convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        CMPLAYER_RECORD_COVER_LAYER.beginTime = timeSincePause;
    }];
    
}

- (void)pauseAction {
    CFTimeInterval pausedTime = [CMPLAYER_RECORD_COVER_LAYER convertTime:CACurrentMediaTime() fromLayer:nil];
    // 动画偏移至当前时间
    CMPLAYER_RECORD_COVER_LAYER.speed = 0.0;
    CMPLAYER_RECORD_COVER_LAYER.timeOffset = pausedTime;
    // needle旋转
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.needleImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI * 30.f / 180.f);
    } completion:nil];
}

- (void)nextActionComp:(CMPlayerRecordActionBlock)comp {
    self.reordScrollActionComp = comp;
    self.playingRecordItemView = self.playingRecordItemView.nextView;
    [self.recordScrollView setContentOffset:CGPointMake(_screenWidth * 2, 0) animated:YES];
}

- (void)prevActionComp:(CMPlayerRecordActionBlock)comp {
    self.reordScrollActionComp = comp;
    self.playingRecordItemView = self.playingRecordItemView.prevView;
    [self.recordScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
@end
