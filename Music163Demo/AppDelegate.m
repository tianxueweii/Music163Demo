//
//  AppDelegate.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/16.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskID;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:ViewController.new];
    [self.window makeKeyAndVisible];
    
    // 设置并激活音频会话类别
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    // 允许应用程序接收远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    // 设置后台任务ID
    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    if (newTaskId != UIBackgroundTaskInvalid && self.backgroundTaskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
    }
    self.backgroundTaskID = newTaskId;
}


@end
