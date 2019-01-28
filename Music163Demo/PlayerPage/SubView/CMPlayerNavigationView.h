//
//  CMPlayerNavigationView.h
//  Music163Demo
//
//  Created by 田学为 on 2019/1/20.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CMPlayerItem;

@interface CMPlayerNavigationView : UIView

/**
 返回按钮点击回调
 */
@property (nonatomic, copy) void (^backButtonClickBlock)(__weak UIButton *button);
/**
 根据当前播放item绘制导航

 @param playerItem CMPlayerItem
 */
- (void)renderNavigationViewWithPlayerItem:(CMPlayerItem *)playerItem;

@end

NS_ASSUME_NONNULL_END
