//
//  CMPlayerItem.h
//  Music163Demo
//
//  Created by 田学为 on 2019/1/16.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CMPlayerItem;

@protocol CMPlayItemDelegate <NSObject>

@optional

// 缓存进度
- (void)musicPlayerItem:(CMPlayerItem *)item bufferSeconds:(NSTimeInterval)seconds rate:(CGFloat)rate;
// item状态
- (void)musicPlayerItem:(CMPlayerItem *)item playItemStatus:(AVPlayerItemStatus)status;
// 完成播放
- (void)musicPlayerItemDidPlayToEndTime:(CMPlayerItem *)item;

@end

@interface CMPlayerItem : AVPlayerItem

/**
 名称
 */
@property (nonatomic, copy) NSString *musicName;
/**
 作者
 */
@property (nonatomic, copy) NSString *musicAuthor;
/**
 封面
 */
@property (nonatomic, strong) NSURL *musicCoverURL;

/**
 初始化

 @param URL 资源url
 @param name 媒体名称
 @param author 媒体作者
 @param coverURL 封面url
 @return 实例
 */
+ (instancetype)musicPlayItemWithURL:(NSURL *)URL name:(NSString *)name author:(NSString *)author coverURL:(NSURL *)coverURL;

/**
 缓存时长(s)
 */
@property (nonatomic, assign, readonly) NSTimeInterval bufferSeconds;
/**
 总时长(s)
 */
@property (nonatomic, assign, readonly) NSTimeInterval durationSeconds;

/**
 资源状态代理
 */
@property (nonatomic, weak) id<CMPlayItemDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
