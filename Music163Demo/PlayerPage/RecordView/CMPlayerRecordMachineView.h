//
//  CMPlayerRecordMachineView.h
//  Music163Demo
//
//  Created by 田学为 on 2019/1/20.
//  Copyright © 2019年 田学为. All rights reserved.
//
//  唱片机视图
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CMPlayer;

typedef NSArray *(^CMPlayerRecordActionBlock)(void);

@interface CMPlayerRecordMachineView : UIView

/**
 初始化器
 */
- (instancetype)initWithPlayer:(CMPlayer *)player;

#pragma mark -

/**
 拖拽下一首完成
 */
@property (nonatomic, copy) CMPlayerRecordActionBlock nextDragActionComp;
/**
 拖拽上一首完成
 */
@property (nonatomic, copy) CMPlayerRecordActionBlock prevDragActionComp;

/**
 手动触发下一首
 */
- (void)nextActionComp:(CMPlayerRecordActionBlock)comp;
/**
 手动触发上一首
 */
- (void)prevActionComp:(CMPlayerRecordActionBlock)comp;

#pragma mark -

/**
 播放动画
 */
- (void)playAction;
/**
 暂停动画
 */
- (void)pauseAction;

/**
 手动刷新唱片

 @param queue 播放队列
 */
- (void)renderRecordItemsWithPlayQueue:(NSArray *)queue;

@end

NS_ASSUME_NONNULL_END
