//
//  CMPlayer.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/16.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "CMPlayer.h"
#import "CMPlayerItem.h"
#import "CMPlayedStack.h"
#import <MediaPlayer/MediaPlayer.h>

#define CM_PLAYQUEUE_PREV_SOURCE    0
#define CM_PLAYQUEUE_PLAYING_SOURCE 1
#define CM_PLAYQUEUE_NEXT_SOURCE    2
#define CM_PLAYQUEUE_SIZE           3

@interface CMPlayer ()

/** 播放（过）栈 */
@property (nonatomic, strong) CMPlayedStack *playedStack;
/** 播放队列 */
@property (nonatomic, strong) NSMutableArray *playQueue;
/** 监听 */
@property (nonatomic, strong) id timeObserver;
@end


@implementation CMPlayer

#pragma mark - Init

- (instancetype)initWithPlayList:(NSArray<CMPlayerItem *> *)playList {
    self = [super init];
    if (self) {
        [self setPlayerMode:CMPlayerModeLoop];
        self.playList = playList;
        
        // 创建状态监听
        [self addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
        
        [self addPeridodicTimeObserver];
        [self handleRemoteControlEvent];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleInterreptionNotification:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:[AVAudioSession sharedInstance]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification
                                                   object:[AVAudioSession sharedInstance]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDidPlayToEndTimeNotification:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        
        [self play];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"timeControlStatus" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removePeridodicTimeObserver];
}


#pragma mark - Play Action Interface

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter {
    [super seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter];
    // 重新添加TimeObserver
    [self removePeridodicTimeObserver];
    [self addPeridodicTimeObserver];
}

- (void)play {
    if (!self.playList.count) return;
    [super play];
    
    NSLog(@"播放队列：%@", self.playQueue);
    NSLog(@"完成栈：%@", self.playedStack.stackSource);
}

/**
 重播
 */
- (void)replay {
    if (!self.playList.count) return;
    [self seekToTime:kCMTimeZero];
    [self play];
    if ([self.delegate respondsToSelector:@selector(musicPlayerStatusReplay:musicPlayerItem:)]) {
        [self.delegate musicPlayerStatusReplay:self musicPlayerItem:self.currentMusicItem];
    }
}

/**
 下一首
 */
- (void)next {
    if (!self.playList.count) return;
    // 暂停
    [self pause];
    // 将进度重置
    [self seekToTime:kCMTimeZero];
    // 操作播放队列
    [self.playedStack push:self.playQueue[CM_PLAYQUEUE_PREV_SOURCE]];
    [self.playQueue removeObjectAtIndex:CM_PLAYQUEUE_PREV_SOURCE];
    [self.playQueue addObject:[self nextResourceWithPlayingItem:self.playQueue[CM_PLAYQUEUE_PLAYING_SOURCE]]];
    
    // 更新播放器资源
    [self replaceCurrentItemWithPlayerItem:self.playQueue[CM_PLAYQUEUE_PLAYING_SOURCE]];
    [self replay];
    
    // 回调
    if ([self.delegate respondsToSelector:@selector(musicPlayerStatusNext:musicPlayerItem:)]) {
        [self.delegate musicPlayerStatusNext:self musicPlayerItem:self.currentMusicItem];
    }
}
/**
 上一首
 */
- (void)prev {
    if (!self.playList.count) return;
    // 暂停
    [self pause];
    // 将进度重置
    [self seekToTime:kCMTimeZero];
    // 操作播放队列
    [self.playQueue removeLastObject];
    CMPlayerItem *prevItem = [self.playedStack pop];
    if (!prevItem) {
        prevItem = [self prevResourceWithPlayingItem:self.playQueue[CM_PLAYQUEUE_PREV_SOURCE]];
    }
    [self.playQueue insertObject:prevItem atIndex:CM_PLAYQUEUE_PREV_SOURCE];
    
    // 更新播放器资源
    [self replaceCurrentItemWithPlayerItem:self.playQueue[CM_PLAYQUEUE_PLAYING_SOURCE]];
    [self replay];
    
    // 回调
    if ([self.delegate respondsToSelector:@selector(musicPlayerStatusPrev:musicPlayerItem:)]) {
        [self.delegate musicPlayerStatusPrev:self musicPlayerItem:self.currentMusicItem];
    }
}

#pragma mark - Message Getting

/**
 获取当前播放时长（s）
 */
- (NSTimeInterval)currentSeconds {
    return CMTimeGetSeconds(self.currentTime);
}

- (CMPlayerItem *)currentMusicItem {
    return self.playQueue[CM_PLAYQUEUE_PLAYING_SOURCE];
}

- (NSArray *)currentPlayingQueue {
    return self.playQueue.copy;
}

- (NSTimeInterval)durationSeconds {
    return self.currentMusicItem.durationSeconds;
}

#pragma mark - Observe

- (void)addPeridodicTimeObserver {
    weakDef(self)
    // 避免闪烁，0.01秒后再添加监听
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.timeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            // 更新远程播放控制器
            [weak_self configNowPlayingInfoCenter];
            if ([weak_self.delegate respondsToSelector:@selector(musicPlayerPlayingProgressCurrenSeconds:duration:buffer:)]) {
                [weak_self.delegate musicPlayerPlayingProgressCurrenSeconds:CMTimeGetSeconds(time) duration:weak_self.currentMusicItem.durationSeconds buffer:weak_self.currentMusicItem.bufferSeconds];
            }
        }];
    });
}

- (void)removePeridodicTimeObserver {
    [self removeTimeObserver:self.timeObserver];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"timeControlStatus"]) {
        
        switch (self.timeControlStatus) {
            case AVPlayerTimeControlStatusPlaying:
                if ([self.delegate respondsToSelector:@selector(musicPlayerStatusPlaying:musicPlayerItem:)]) {
                    [self.delegate musicPlayerStatusPlaying:self musicPlayerItem:self.currentMusicItem];
                }
                break;
            case AVPlayerTimeControlStatusPaused: {
                if ([self.delegate respondsToSelector:@selector(musicPlayerStatusPaused:musicPlayerItem:)]) {
                    [self.delegate musicPlayerStatusPaused:self musicPlayerItem:self.currentMusicItem];
                }
                break;
            }
            case AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate:
                if ([self.delegate respondsToSelector:@selector(musicPlayerStatusLoading:musicPlayerItem:)]) {
                    [self.delegate musicPlayerStatusLoading:self musicPlayerItem:self.currentMusicItem];
                }
                break;
            default:
                break;
        }
    }
}



#pragma mark - Get

- (void)setPlayList:(NSArray<CMPlayerItem *> *)playList {
    _playList = playList;
//    [_playList makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
    if (_playList.count) {
        [self playedStack];
        [self playQueue];
        [self replaceCurrentItemWithPlayerItem:self.playQueue[CM_PLAYQUEUE_PLAYING_SOURCE]];
    }
}

- (NSMutableArray *)playQueue {
    if (!_playQueue) {
        // 初始化播放内容
        _playQueue = [NSMutableArray array];
        // 插入第一首播放曲目
        [_playQueue addObject:self.playList[0]];
        // 插入上一首
        [_playQueue insertObject:[self prevResourceWithPlayingItem:self.playList[0]] atIndex:0];
        // 插入下一首
        [_playQueue addObject:[self nextResourceWithPlayingItem:self.playList[0]]];
    }
    return _playQueue;
}

- (CMPlayedStack *)playedStack {
    if (!_playedStack) {
        _playedStack = [[CMPlayedStack alloc] init];
    }
    return _playedStack;
}

#pragma mark - Orginaze Resources

- (CMPlayerItem *)nextResourceWithPlayingItem:(CMPlayerItem *)item {
    CMPlayerItem *resultItem;
    NSInteger index = [self.playList indexOfObject:item];
    
    // 根据mode获取
    switch (_playerMode) {
        case CMPlayerModeShuffle: {
            resultItem = [self shuffleResourceWithPlayingItem:item];
            break;
        }
        default: {
            if (index + 1 < self.playList.count) {
                resultItem = self.playList[index + 1];
            } else {
                resultItem = self.playList[0];
            }
        }
    }
    return resultItem;
}

- (CMPlayerItem *)prevResourceWithPlayingItem:(CMPlayerItem *)item {
    CMPlayerItem *resultItem;
    NSInteger index = [self.playList indexOfObject:item];

    switch (_playerMode) {
        case CMPlayerModeShuffle: {
            resultItem = [self shuffleResourceWithPlayingItem:item];
            break;
        }
        default: {
            if (index > 0) {
                resultItem = self.playList[index - 1];
            } else {
                resultItem = self.playList.lastObject;
            }
        }
    }
    return resultItem;
}

- (CMPlayerItem *)shuffleResourceWithPlayingItem:(CMPlayerItem *)item {
    // 获取播放列表
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.playList];
    [tempArr removeObject:item];
    if (!tempArr.count) {
        return item;
    }
    NSInteger shuffleIdx = (arc4random() % (tempArr.count));
    return tempArr[shuffleIdx];
}


#pragma mark - NSNotification

/**
 播放线路切换通知
 */
- (void)handleRouteChangeNotification:(NSNotification *)noti {
    NSDictionary *info = noti.userInfo;
    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    // 旧设备不可用
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        // 获取线路更换早先设备
        AVAudioSessionRouteDescription *previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *previousOutput = previousRoute.outputs[0];
        NSString *portType = previousOutput.portType;
        // 如果早先设备类型为耳麦
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
            [self pause];
        }
    }
}

/**
 播放中断通知
 */
- (void)handleInterreptionNotification:(NSNotification *)noti {
    if ([noti.userInfo[AVAudioSessionInterruptionTypeKey] integerValue] == AVAudioSessionInterruptionTypeBegan) {
        // 当发生中断将播放器暂停，暂不做差异化处理
        [self pause];
    }
}

/**
 播放完成通知
 */
- (void)handleDidPlayToEndTimeNotification:(NSNotification *)noti {
    if ([self.delegate respondsToSelector:@selector(musicPlayerStatusComplete:musicPlayerItem:)]) {
        [self.delegate musicPlayerStatusComplete:self musicPlayerItem:self.currentMusicItem];
    }
    switch (self.playerMode) {
        case CMPlayerModeOne:
            [self replay];
            break;
        default:
            [self next];
            break;
    }
}

#pragma mark - Remote Control

- (void)handleRemoteControlEvent {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    // 播放
    [commandCenter.playCommand addTarget:self action:@selector(play)];
    // 暂停
    [commandCenter.pauseCommand addTarget:self action:@selector(pause)];
    // 上一首
    [commandCenter.previousTrackCommand addTarget:self action:@selector(prev)];
    // 下一首
    [commandCenter.nextTrackCommand addTarget:self action:@selector(next)];
    // 为耳机的按钮操作添加相关的响应事件
    [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (self.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
            [self pause];
        } else {
            [self play];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

/**
 更新远程播放器
 */
- (void)configNowPlayingInfoCenter {
    NSMutableDictionary *nowPlayInfo = [[NSMutableDictionary alloc] init];
    // 歌曲名称
    [nowPlayInfo setObject:self.currentMusicItem.musicName forKey:MPMediaItemPropertyTitle];
    // 演唱者
    [nowPlayInfo setObject:self.currentMusicItem.musicAuthor forKey:MPMediaItemPropertyArtist];
    // 音乐剩余时长
    [nowPlayInfo setObject:@(self.currentMusicItem.durationSeconds) forKey:MPMediaItemPropertyPlaybackDuration];
    // 音乐当前播放时间
    [nowPlayInfo setObject:@(self.currentSeconds) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayInfo];
}

@end
