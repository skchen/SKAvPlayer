//
//  SKAvPlayer.m
//  SKAvPlayer
//
//  Created by Shin-Kai Chen on 2016/4/25.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKAvPlayer.h"

static const NSString * ItemStatusContext;

static NSString * const kKeyTracks = @"tracks";
static NSString * const kKeyStatus = @"status";

@interface SKAvPlayer ()

@property(nonatomic, strong, nullable) AVPlayer *avPlayer;
@property(nonatomic, strong, nullable) AVPlayerItem *item;

@end

@implementation SKAvPlayer

- (void)dealloc {
    [_avPlayer pause];
    
    if(_item) {
        [_item removeObserver:self forKeyPath:@"status"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Abstract

- (void)_start:(SKErrorCallback)callback {
    if(_item) {
        [_item removeObserver:self forKeyPath:@"status"];
    }
    
    AVAsset *asset = (AVAsset *)_source;
    
    if(asset) {
        [asset loadValuesAsynchronouslyForKeys:@[kKeyTracks] completionHandler:^{
            NSError *error;
            AVKeyValueStatus status = [asset statusOfValueForKey:kKeyTracks error:&error];
            
            if (status == AVKeyValueStatusLoaded) {
                if([asset isPlayable]) {
                    _item = [AVPlayerItem playerItemWithAsset:asset];
                    [_item addObserver:self forKeyPath:kKeyStatus options:NSKeyValueObservingOptionInitial context:&ItemStatusContext];
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(playerItemDidReachEnd:)
                                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                                               object:_item];
                    
                    _avPlayer = [AVPlayer playerWithPlayerItem:_item];
                    
                    [self _resume:callback];
                } else {
                    [self notifyErrorMessage:@"Item not playable" callback:callback];
                }
            } else {
                [self notifyErrorMessage:@"Unable to load tracks" callback:callback];
            }
        }];
    } else {
        [self notifyErrorMessage:@"Source not found" callback:callback];
    }
}

- (void)_resume:(SKErrorCallback)callback {
    [_avPlayer play];
    callback(nil);
}

- (void)_pause:(SKErrorCallback)callback {
    [_avPlayer pause];
    callback(nil);
}

- (void)_stop:(SKErrorCallback)callback {
    [_avPlayer seekToTime:CMTimeMake(0, 1)];
    [_avPlayer pause];
    callback(nil);
}

- (void)_setSource:(nonnull id)source callback:(nullable SKErrorCallback)callback {
    AVAsset *asset = nil;
    
    if([source isKindOfClass:[AVAsset class]]) {
        asset = source;
    } else if([source isKindOfClass:[NSURL class]]) {
        asset = [AVAsset assetWithURL:source];
    } else if([source isKindOfClass:[NSString class]]) {
        asset = [AVAsset assetWithURL:[NSURL URLWithString:source]];
    } else {
        [self notifyErrorMessage:@"Source not supported" callback:callback];
    }
    
    if(asset) {
        [self changeSource:asset callback:callback];
    }
}

- (void)_seekTo:(NSTimeInterval)time success:(SKTimeCallback)success failure:(SKErrorCallback)failure {
    [_avPlayer pause];
    [_avPlayer seekToTime:CMTimeMake(time, 1)];
    [_avPlayer play];
    success(time);
}

- (void)getProgress:(nonnull SKTimeCallback)success failure:(nullable SKErrorCallback)failure {
    success(CMTimeGetSeconds(_avPlayer.currentTime));
}

- (void)getDuration:(SKTimeCallback)success failure:(SKErrorCallback)failure {
    AVAsset *asset = (AVAsset *)_source;
    
    if(asset) {
        success(CMTimeGetSeconds(asset.duration));
    } else {
        [self notifyErrorMessage:@"Source not found" callback:failure];
    }
}

#pragma mark - Notification

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self playbackDidComplete:_source];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if(context == &ItemStatusContext) {
        if(_item.status==AVPlayerItemStatusReadyToPlay) {
            // Prepared
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
