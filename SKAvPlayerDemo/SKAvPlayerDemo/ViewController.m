//
//  ViewController.m
//  SKAvPlayerDemo
//
//  Created by Shin-Kai Chen on 2016/4/25.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "ViewController.h"

@import SKAvPlayer;

static NSString *testUrl = @"http://192.168.2.100:5000/fbsharing/uRIN5LHo";

@interface ViewController ()

@property(nonatomic, strong, nonnull) SKAvPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _player = [[SKAvPlayer alloc] init];
        [_player setDataSource:testUrl];
        [_player prepare];
        [_player start];
    });
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
