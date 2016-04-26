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

@property(nonatomic, strong, nullable) AVPlayer *avPlayer;
@property(nonatomic, strong, nullable) AVPlayerItem *item;
@property(nonatomic, copy) dispatch_semaphore_t semaphore;
@property(nonatomic, strong, nullable) NSError *error;

@end

@implementation SKAvPlayer

- (void)dealloc {
    [_avPlayer pause];
    
    if(_item) {
        [_item removeObserver:self forKeyPath:@"status"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSError *)_setDataSource:(AVAsset *)source {
    return nil;
}

- (NSError *)_prepare {
    if(_item) {
        [_item removeObserver:self forKeyPath:@"status"];
    }
    
    _semaphore = dispatch_semaphore_create(0);
    _error = nil;
    
    NSString *tracksKey = @"tracks";
    
    [self.source loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(), ^{
             NSError *error;
             AVKeyValueStatus status = [self.source statusOfValueForKey:tracksKey error:&error];
             
             if (status == AVKeyValueStatusLoaded) {
                 if([self.source isPlayable]) {
                     _item = [AVPlayerItem playerItemWithAsset:self.source];
                     [_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:&ItemStatusContext];
                     
                     [[NSNotificationCenter defaultCenter] addObserver:self
                                                              selector:@selector(playerItemDidReachEnd:)
                                                                  name:AVPlayerItemDidPlayToEndTimeNotification
                                                                object:_item];
                     
                     _avPlayer = [AVPlayer playerWithPlayerItem:_item];
                 } else {
                     _error = [NSError errorWithDomain:@"Item not playable" code:0 userInfo:nil];
                     dispatch_semaphore_signal(_semaphore);
                 }
             } else {
                 NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                 _error = [NSError errorWithDomain:@"Unable to load tracks" code:0 userInfo:nil];
                 dispatch_semaphore_signal(_semaphore);
             }
         });
     }];
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    return _error;
}

- (NSError *)_start {
    [_avPlayer play];
    return nil;
}

- (NSError *)_pause {
    [_avPlayer pause];
    return nil;
}

- (NSError *)_stop {
    [_avPlayer seekToTime:CMTimeMake(0, 1)];
    [_avPlayer pause];
    
    return nil;
}

- (int)getCurrentPosition {
    return (int)round(CMTimeGetSeconds(_avPlayer.currentTime)*1000);
}

- (int)getDuration {
    return (int)round(CMTimeGetSeconds(self.source.duration)*1000);
}

- (NSError *)_seekTo:(int)msec {
    [_avPlayer pause];
    [_avPlayer seekToTime:CMTimeMake(msec, 1000)];
    [_avPlayer play];
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if(context == &ItemStatusContext) {
        if(_item.status==AVPlayerItemStatusReadyToPlay) {
            dispatch_semaphore_signal(_semaphore);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self notifyCompletion];
}

@end
