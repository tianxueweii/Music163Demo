//
//  CMPlayedStack.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/21.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "CMPlayedStack.h"
#import "CMPlayerItem.h"



@interface CMPlayedStack ()
@property (nonatomic, strong) NSMutableArray *stack;
@end

@implementation CMPlayedStack

- (instancetype)init {
    self = [super init];
    if (self) {
        _stack = [NSMutableArray array];
    }
    return self;
}

- (void)push:(CMPlayerItem *)item {
    [self.stack addObject:item];
    if (self.stack.count > CM_PLAYED_STACK_SIZE) {
        [self.stack removeObjectAtIndex:0];
    }
}

- (CMPlayerItem *)pop {
    if (!self.stack.count) {
        return nil;
    }
    CMPlayerItem *item = self.stack.lastObject;
    [self.stack removeLastObject];
    return item;
}

- (NSArray *)stackSource {
    return _stack.copy;
}

@end
