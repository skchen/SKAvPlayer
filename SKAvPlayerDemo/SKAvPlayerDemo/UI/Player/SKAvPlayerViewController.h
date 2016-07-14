//
//  SKMopidyPlayerViewController.h
//  SKMopidyDemo
//
//  Created by Shin-Kai Chen on 2016/4/20.
//  Copyright © 2016年 SK. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SKAvPlayer/SKAvPlayer.h>
@import AVFoundation;

@interface SKAvPlayerViewController : SKListPlayerViewController

@property(nonatomic, strong, nullable) NSArray<AVAsset *> *list;
@property(nonatomic, assign) NSUInteger index;

@end

