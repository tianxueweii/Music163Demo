//
//  ViewController.m
//  Music163Demo
//
//  Created by 田学为 on 2019/1/16.
//  Copyright © 2019年 田学为. All rights reserved.
//

#import "ViewController.h"
#import "CMPlayerViewController.h"

@interface ViewController ()

/**
 唤醒播放器icon
 */
@property (nonatomic, strong) UIImageView *topBarPlayingIcon;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.contents = (__bridge id _Nullable)(UIImage(@"cm2_default_play_bg").CGImage);
    self.view.layer.contentsGravity = kCAGravityResizeAspectFill;

    [self viewTemplete];
    [self configConstraint];
    
    [self.topBarPlayingIcon startAnimating];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - Render

- (void)viewTemplete {
    [self.view addSubview:self.topBarPlayingIcon];
}

- (void)configConstraint {
    [self.topBarPlayingIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_statusBarHeight + 5);
        make.right.mas_equalTo(-CM_DEFAULT_MARGIN_HORIZONTAL);
    }];
}

#pragma mark - Get

- (UIImageView *)topBarPlayingIcon {
    if (!_topBarPlayingIcon) {
        
        _topBarPlayingIcon = [[UIImageView alloc] initWithImage:UIImage(@"cm2_topbar_icn_playing0")];
        
        // Animation
        NSMutableArray *animationImages = [NSMutableArray array];
        for (int i = 0; i <= 5; i++) {
            NSString *fileName = [NSString stringWithFormat:@"cm2_topbar_icn_playing%d", i];
            UIImage *image = UIImage(fileName);
            [animationImages addObject:image];
        }
        for (int i = 4; i >= 0; i--) {
            NSString *fileName = [NSString stringWithFormat:@"cm2_topbar_icn_playing%d", i];
            UIImage *image = UIImage(fileName);
            [animationImages addObject:image];
        }
        _topBarPlayingIcon.animationImages = animationImages;
        _topBarPlayingIcon.animationDuration = 0.8;
        
        // Gesture
        _topBarPlayingIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTopBarTapGesture:)];
        [_topBarPlayingIcon addGestureRecognizer:tap];
    }
    return _topBarPlayingIcon;
}

#pragma mark - Gesture

- (void)handleTopBarTapGesture:(UIGestureRecognizer *)ges {
    CMPlayerViewController *playerViewController = [CMPlayerViewController sharedPlayerViewController];
    [self.navigationController pushViewController:playerViewController animated:YES];
}

@end
