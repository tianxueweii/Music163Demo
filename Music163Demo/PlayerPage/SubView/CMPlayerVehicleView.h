//
//  CMPlayerVehicleView.h
//  Music163Demo
//
//  Created by 田学为 on 2019/1/19.
//  Copyright © 2019年 田学为. All rights reserved.
//
//  播放条
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CMPlayer;

@interface CMPlayerVehicleView : UIView

- (instancetype)initWithPlayer:(CMPlayer *)player;

@end

NS_ASSUME_NONNULL_END
