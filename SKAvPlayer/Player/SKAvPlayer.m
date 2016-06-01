//
//  SKAvPlayer.m
//  SKAvPlayer
//
//  Created by Shin-Kai Chen on 2016/4/25.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKAvPlayer.h"

static const NSString *ItemStatusContext;

@interface SKAvPlayer ()

@property(nonatomic, strong, nullable) AVAsset *asset;
@property(nonatomic, strong, nullable) AVPlayer *avPlayer;
@property(nonatomic, strong, nullable) AVPlayerItem *item;
@property(nonatomic, copy, nullable) SKErrorCallback prepareCallback;

@end

@implementation SKAvPlayer

- (void)dealloc {
    [_avPlayer pause];
    
    if(_item) {
        [_item removeObserver:self forKeyPath:@"status"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_setDataSource:(nonnull id)source {
    if([source isKindOfClass:[AVAsset class]]) {
        _asset = source;
    } else if([source isKindOfClass:[NSURL class]]) {
        _asset = [AVAsset assetWithURL:source];
    } else if([source isKindOfClass:[NSString class]]) {
        [self _setDataSource:[NSURL URLWithString:source]];
    } else {
        NSLog(@"Non-supported source: %@", source);
    }
}

- (void)_prepare:(SKErrorCallback)callback {
    if(_item) {
        [_item removeObserver:self forKeyPath:@"status"];
    }
    
    NSString *tracksKey = @"tracks";
    
    [_asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:^{
        NSError *error;
        AVKeyValueStatus status = [_asset statusOfValueForKey:tracksKey error:&error];
        
        if (status == AVKeyValueStatusLoaded) {
            if([_asset isPlayable]) {
                _prepareCallback = callback;
                
                _item = [AVPlayerItem playerItemWithAsset:_asset];
                [_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:&ItemStatusContext];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(playerItemDidReachEnd:)
                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                           object:_item];
                
                _avPlayer = [AVPlayer playerWithPlayerItem:_item];
            } else {
                callback([NSError errorWithDomain:@"Item not playable" code:0 userInfo:nil]);
            }
        } else {
            callback([NSError errorWithDomain:@"Unable to load tracks" code:0 userInfo:nil]);
        }
    }];
}

- (void)_start:(SKErrorCallback)callback {
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

- (void)_getCurrentPosition:(SKTimeCallback)success failure:(SKErrorCallback)failure {
    success(CMTimeGetSeconds(_avPlayer.currentTime));
}

- (void)_getDuration:(SKTimeCallback)success failure:(SKErrorCallback)failure {
    success(CMTimeGetSeconds(_asset.duration));
}

- (void)_seekTo:(NSTimeInterval)time success:(SKTimeCallback)success failure:(SKErrorCallback)failure {
    [_avPlayer pause];
    [_avPlayer seekToTime:CMTimeMake(time, 1)];
    [_avPlayer play];
    success(time);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if(context == &ItemStatusContext) {
        if(_item.status==AVPlayerItemStatusReadyToPlay) {
            if(_prepareCallback) {
                _prepareCallback(nil);
                _prepareCallback = nil;
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self notifyCompletion:nil];
}

@end
