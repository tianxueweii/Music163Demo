//
//  CMPlayerProgressView.h
//  Music163Demo
//
//  Created by 田学为 on 2019/1/20.
//  Copyright © 2019年 田学为. All rights reserved.
//
//  进度条
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CMPlayerProgressDragCompleteBlock)(NSTimeInterval seconds, CGFloat rate);

@interface CMPlayerProgressView : UIView

/**
 拖拽完成block
 */
@property (nonatomic, copy) CMPlayerProgressDragCompleteBlock dragCompleteBlock;
/**
 是否拖拽中
 */
@property (nonatomic, assign) BOOL isDragging;

/**
 渲染进度条

 @param curSec 当前进度
 @param durSec 总进度
 @param bufferSec 缓存进度
 */
- (void)renderViewWithCurrentSeconds:(NSTimeInterval)curSec durationSeconds:(NSTimeInterval)durSec buffer:(NSTimeInterval)bufferSec;

@end

NS_ASSUME_NONNULL_END
