//
//  AppDelegate.h
//  SKAvPlayerDemo
//
//  Created by Shin-Kai Chen on 2016/4/25.
//  Copyright © 2016年 SK. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SKAvPlayer/SKAvListPlayer.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic, nonnull) UIWindow *window;
@property (nonatomic, strong, readonly, nonnull) SKAvListPlayer *player;

@end

