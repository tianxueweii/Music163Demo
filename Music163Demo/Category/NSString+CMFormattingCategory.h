//
//  NSString+CMFormattingCategory.h
//  Music163Demo
//
//  Created by 田学为 on 2019/1/20.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CMFormattingCategory)

+ (NSString *)cm_defaultFormattingWithTime:(NSTimeInterval)seconds;

@end

NS_ASSUME_NONNULL_END
