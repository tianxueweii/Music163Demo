//
//  CMPlayer.h
//  Music163Demo
//
//  Created by 田学为 on 2019/1/16.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>



NS_ASSUME_NONNULL_BEGIN

@class CMPlayer;
@class CMPlayerItem;

/**
 播放模式选择

 - CMPlayerModeLoop: 顺序
 - CMPlayerModeOne: 单曲循环
 - CMPlayerModeShuffle: 乱序
 */
typedef NS_ENUM(NSUInteger, CMPlayerMode) {
    CMPlayerModeLoop,
    CMPlayerModeOne,
    CMPlayerModeShuffle,
};

@protocol CMPlayerDelegate <NSObject>

@optional

// 播放
- (void)musicPlayerStatusPlaying:(CMPlayer *)player musicPlayerItem:(CMPlayerItem *)item;
// 暂停
- (void)musicPlayerStatusPaused:(CMPlayer *)player musicPlayerItem:(CMPlayerItem *)item;
// 加载中
- (void)musicPlayerStatusLoading:(CMPlayer *)player musicPlayerItem:(CMPlayerItem *)item;
// 播放完成
- (void)musicPlayerStatusComplete:(CMPlayer *)player musicPlayerItem:(CMPlayerItem *)item;

// 下一首
- (void)musicPlayerStatusNext:(CMPlayer *)player musicPlayerItem:(CMPlayerItem *)item;
// 上一首
- (void)musicPlayerStatusPrev:(CMPlayer *)player musicPlayerItem:(CMPlayerItem *)item;
// 重播
- (void)musicPlayerStatusReplay:(CMPlayer *)player musicPlayerItem:(CMPlayerItem *)item;

// 进度监听，间隔1s
- (void)musicPlayerPlayingProgressCurrenSeconds:(NSTimeInterval)currentSec duration:(NSTimeInterval)durationSec buffer:(NSTimeInterval)bufferSec;

@end

@interface CMPlayer : AVPlayer

/**
 初始化播放器

 @param playList 播放列表
 @return 实例
 */
- (instancetype)initWithPlayList:(NSArray<CMPlayerItem *> *)playList NS_DESIGNATED_INITIALIZER;

/**
 播放模式
 */
@property (nonatomic, assign) CMPlayerMode playerMode;
/**
 播放器代理
 */
@property (nonatomic, weak) id<CMPlayerDelegate> delegate;

#pragma mark -

/**
 播放列表
 */
@property (nonatomic, strong) NSArray<CMPlayerItem *> *playList;
/**
 播放队列
 */
@property (nonatomic, readonly) NSArray<CMPlayerItem *> *currentPlayingQueue;
/**
 当前播放item
 */
@property (nonatomic, readonly) CMPlayerItem *currentMusicItem;

#pragma mark -
/**
 当前播放时长
 */
@property (nonatomic, readonly) NSTimeInterval currentSeconds;
/**
 放回当前播放item.duration
 */
@property (nonatomic, readonly) NSTimeInterval durationSeconds;

#pragma mark -
/**
 下一首
 */
- (void)next;
/**
 上一首
 */
- (void)prev;

@end

NS_ASSUME_NONNULL_END
