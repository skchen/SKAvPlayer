//
//  SKMopidyPlayerViewController.m
//  SKMopidyDemo
//
//  Created by Shin-Kai Chen on 2016/4/19.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKAvPlayerViewController.h"

#import "AppDelegate.h"

@interface SKAvPlayerViewController () <SKPlayerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation SKAvPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    self.player = app.player;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak __typeof(self.listPlayer) weakListPlayer = self.listPlayer;
    
    [self.listPlayer setSource:_list atIndex:_index callback:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"Unable to set source: %@", error);
        } else {
            [weakListPlayer start:^(NSError * _Nullable error) {
                if(error) {
                    NSLog(@"Unable to play source: %@", error);
                }
            }];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.listPlayer stop:^(NSError * _Nullable error) {
        NSLog(@"stop error: %@", error);
    }];
}

- (void)updateTitle {
    AVAsset *asset = [self.listPlayer.source objectAtIndex:self.listPlayer.index];
    NSString *name = [((AVURLAsset *)asset).URL.absoluteString lastPathComponent];
    [_nameLabel setText:name];
}

#pragma mark - SKPlayerDelegate

- (void)playerDidChangeSource:(SKPlayer *)player {
    [super playerDidChangeSource:player];
    [self updateTitle];
}

@end
