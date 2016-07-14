//
//  SKAvListPlayer.m
//  SKAvListPlayer
//
//  Created by Shin-Kai Chen on 2016/4/26.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKAvListPlayer.h"

#import "SKAvPlayer.h"

@implementation SKAvListPlayer

- (instancetype)init {
    SKPlayer *innerPlayer = [[SKAvPlayer alloc] init];
    self = [super initWithPlayer:innerPlayer];
    return self;
}

@end
