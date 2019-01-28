//
//  NSString+CMFormattingCategory.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/20.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "NSString+CMFormattingCategory.h"

@implementation NSString (CMFormattingCategory)

+ (NSString *)cm_defaultFormattingWithTime:(NSTimeInterval)seconds {
    // FIXME: 超过1小时资源可能有问题
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    return [formatter stringFromDate:date];
}

@end
