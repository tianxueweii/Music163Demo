//
//  CMPlayedStack.h
//  Music163Demo
//
//  Created by 田学为 on 2019/1/21.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CM_PLAYED_STACK_SIZE 5

NS_ASSUME_NONNULL_BEGIN

@class CMPlayerItem;

@interface CMPlayedStack : NSObject

#pragma mark - Function

/**
 进栈
 */
- (void)push:(CMPlayerItem *)item;
/**
 出栈
 */
- (CMPlayerItem *)pop;

/**
 栈内资源

 @return idx=0为栈底，idx=lastObjectIdx为栈顶
 */
- (NSArray *)stackSource;


@end

NS_ASSUME_NONNULL_END
