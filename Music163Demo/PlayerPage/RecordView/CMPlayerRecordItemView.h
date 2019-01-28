//
//  CMPlayerRecordItemView.h
//  Music163Demo
//
//  Created by 田学为 on 2019/1/20.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CMPlayerItem;

@interface CMPlayerRecordItemView : UIView

/**
 封面
 */
@property (nonatomic, readonly) UIImageView *coverImageView;


/**
 下一首唱片视图
 */
@property (nonatomic, weak, nullable) CMPlayerRecordItemView *nextView;
/**
 上一首唱片视图
 */
@property (nonatomic, weak, nullable) CMPlayerRecordItemView *prevView;

/**
 重置当前唱片
 */
- (void)cleanUp;
/**
 根据item渲染当前唱片

 @param playerItem CMPlayerItem
 */
- (void)renderRecordCellWithPlayerItem:(CMPlayerItem *)playerItem;

@end

NS_ASSUME_NONNULL_END
