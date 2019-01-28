//
//  CMPlayerItem.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/16.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "CMPlayerItem.h"

@implementation CMPlayerItem

+ (instancetype)musicPlayItemWithURL:(NSURL *)URL name:(NSString *)name author:(NSString *)author coverURL:(NSURL *)coverURL {
    CMPlayerItem *item = [self playerItemWithURL:URL];
    item.musicName = name;
    item.musicAuthor = author;
    item.musicCoverURL = coverURL;
    
    [item addObserver:item forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:item forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:item forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:item forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:item selector:@selector(handleDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    return item;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"status" context:nil];
    [self removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [self removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
    [self removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Interface

- (NSTimeInterval)durationSeconds {
    return CMTimeGetSeconds(self.duration);
}

- (NSTimeInterval)bufferSeconds {
    CMTimeRange timeRange = [self.loadedTimeRanges.firstObject CMTimeRangeValue];
    return CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
}

#pragma mark -

/**
 播放完成回调
 */
- (void)handleDidPlayToEndTimeNotification:sender {
    if ([self.delegate respondsToSelector:@selector(musicPlayerItemDidPlayToEndTime:)]) {
        [self.delegate musicPlayerItemDidPlayToEndTime:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (!self.delegate) return;
    // 监听资源状态
    if ([keyPath isEqualToString:@"status"]) {
        if ([self.delegate respondsToSelector:@selector(musicPlayerItem:playItemStatus:)]) {
            [self.delegate musicPlayerItem:self playItemStatus:self.status];
        }
    // 监听资源下载进度
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        if ([self.delegate respondsToSelector:@selector(musicPlayerItem:bufferSeconds:rate:)]) {
            [self.delegate musicPlayerItem:self bufferSeconds:self.bufferSeconds rate:self.bufferSeconds / self.durationSeconds];
        }
    // 监听缓冲数据的状态
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        NSLog(@"缓冲不足暂停了");
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        NSLog(@"缓冲达到可播放程度了");
    }
}

@end
