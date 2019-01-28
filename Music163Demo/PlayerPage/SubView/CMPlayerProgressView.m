//
//  CMPlayerProgressView.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/20.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "CMPlayerProgressView.h"
#import "NSString+CMFormattingCategory.h"

#define CMPLAYER_PROGRESS_MARGIN 55

@interface CMPlayerProgressView ()

@property (nonatomic, strong) UILabel *currentSecLabel;
@property (nonatomic, strong) UILabel *durationSecLabel;

/**
 播放Dot
 */
@property (nonatomic, strong) UIImageView *progressDot;
/**
 播放轨道
 */
@property (nonatomic, strong) UIView *progressTrack;
/**
 已播放进度
 */
@property (nonatomic, strong) UIView *progressPlayLine;
/**
 缓存进度
 */
@property (nonatomic, strong) UIView *progressBufferLine;

@property (nonatomic, assign) NSTimeInterval durationSeconds;

@end

@implementation CMPlayerProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self viewTemplete];
        [self configConstraint];
    }
    return self;
}

#pragma mark - Interface

- (void)renderViewWithCurrentSeconds:(NSTimeInterval)curSec durationSeconds:(NSTimeInterval)durSec buffer:(NSTimeInterval)bufferSec;{
    self.durationSeconds = durSec;
    if (self.isDragging) return;
    
    if (isnan(durSec) || !durSec) {
        durSec = 0.0001;
    }
    if (isnan(curSec) || !curSec) {
        curSec = 0;
    }
    if (isnan(bufferSec) || !bufferSec) {
        bufferSec = 0;
    }
    
    
    CGFloat progressRate = curSec / durSec;
    CGFloat bufferRate = bufferSec / durSec;
    
    self.progressDot.center = CGPointMake(self.progressTrack.frame.origin.x + self.progressTrack.frame.size.width * progressRate, self.progressTrack.center.y);
    
    self.progressPlayLine.frame = CGRectMake(0, 0, self.progressTrack.frame.size.width * progressRate, self.progressTrack.frame.size.height);
    self.progressBufferLine.frame = CGRectMake(0, 0, self.progressTrack.frame.size.width * bufferRate, self.progressTrack.frame.size.height);
    
    self.currentSecLabel.text = [NSString cm_defaultFormattingWithTime:curSec];
    self.durationSecLabel.text = [NSString cm_defaultFormattingWithTime:durSec];
}

#pragma mark - Render
- (void)viewTemplete {
    [self addSubview:self.progressTrack];
    [self addSubview:self.currentSecLabel];
    [self addSubview:self.durationSecLabel];
    
    [self addSubview:self.progressDot];
    
    [self.progressTrack addSubview:self.progressPlayLine];
    [self.progressTrack addSubview:self.progressBufferLine];
    
    [self.progressTrack bringSubviewToFront:self.progressPlayLine];
}

- (void)configConstraint {
    [self.progressTrack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(CMPLAYER_PROGRESS_MARGIN);
        make.right.mas_equalTo(-CMPLAYER_PROGRESS_MARGIN);
        make.height.mas_equalTo(2);
    }];
    
    [self.currentSecLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(self.progressTrack.mas_left).mas_offset(-12);
    }];
    
    [self.durationSecLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.progressTrack.mas_right).mas_offset(12);
    }];
    
//    [self layoutIfNeeded];
//    self.progressDot.center = CGPointMake(CMPLAYER_PROGRESS_MARGIN, self.progressTrack.center.y);
}

#pragma mark - Get

- (UILabel *)currentSecLabel {
    if (!_currentSecLabel) {
        _currentSecLabel = [[UILabel alloc] init];
        _currentSecLabel.font = [UIFont systemFontOfSize:10];
        _currentSecLabel.textColor = CM_TEXT_COLOR_WHT;
        _currentSecLabel.text = @"00:00";
    }
    return _currentSecLabel;
}

- (UILabel *)durationSecLabel {
    if (!_durationSecLabel) {
        _durationSecLabel = [[UILabel alloc] init];
        _durationSecLabel.font = [UIFont systemFontOfSize:10];
        _durationSecLabel.textColor = CM_TEXT_COLOR_AUX;
        _durationSecLabel.text = @"00:00";
    }
    return _durationSecLabel;
}

#pragma mark -

- (UIImageView *)progressDot {
    if (!_progressDot) {
        _progressDot = [[UIImageView alloc] initWithImage:UIImage(@"cm2_fm_playbar_btn")];
        _progressDot.contentMode = UIViewContentModeCenter;
        _progressDot.frame = CGRectMake(0, 0, 30, 30);
        UIImageView *point = [[UIImageView alloc] initWithImage:UIImage(@"cm2_fm_playbar_btn_dot")];
        [_progressDot addSubview:point];
        point.center = _progressDot.center;
        point.userInteractionEnabled = YES;
        _progressDot.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *dragGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragGesture:)];
        [_progressDot addGestureRecognizer:dragGes];
    }
    return _progressDot;
}

- (UIView *)progressTrack {
    if (!_progressTrack) {
        _progressTrack = [[UIView alloc] init];
        _progressTrack.backgroundColor = UIColor.darkGrayColor;
        _progressTrack.layer.cornerRadius = 1;
        _progressTrack.layer.masksToBounds = YES;
    }
    return _progressTrack;
}

- (UIView *)progressPlayLine {
    if (!_progressPlayLine) {
        _progressPlayLine = [[UIView alloc] init];
        _progressPlayLine.backgroundColor = CM_THEME_COLOR;
    }
    return _progressPlayLine;
}

- (UIView *)progressBufferLine {
    if (!_progressBufferLine) {
        _progressBufferLine = [[UIView alloc] init];
        _progressBufferLine.backgroundColor = UIColor.lightGrayColor;
    }
    return _progressBufferLine;
}

#pragma mark - Gesture

- (void)handleDragGesture:(UIPanGestureRecognizer *)ges {
    if (isnan(self.durationSeconds) || !self.durationSeconds) {
        return;
    }
    static CGPoint newDotCenter;
    static CGFloat rate = 0;
    static NSTimeInterval seconds = 0;
    switch (ges.state) {
        case UIGestureRecognizerStateBegan: {
            self.isDragging = YES;
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [ges translationInView:self];
            newDotCenter = CGPointMake(self.progressDot.center.x + translation.x, self.progressDot.center.y);
            rate = (newDotCenter.x - CMPLAYER_PROGRESS_MARGIN) / (_screenWidth - CMPLAYER_PROGRESS_MARGIN * 2);
            seconds = self.durationSeconds * rate;
            [ges setTranslation:CGPointMake(0, 0) inView:self];
            if (newDotCenter.x < CMPLAYER_PROGRESS_MARGIN || newDotCenter.x > _screenWidth - CMPLAYER_PROGRESS_MARGIN) {
                return;
            }
            
            self.progressDot.center = newDotCenter;
            self.progressPlayLine.frame = CGRectMake(0, 0, self.progressTrack.frame.size.width * rate, self.progressTrack.frame.size.height);
            if (seconds >= 0) {
                self.currentSecLabel.text = [NSString cm_defaultFormattingWithTime:seconds];
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (self.dragCompleteBlock) {
                self.dragCompleteBlock(seconds, rate);
            }
            self.isDragging = NO;
            break;
        }
        default:
            break;
    }
}
@end
