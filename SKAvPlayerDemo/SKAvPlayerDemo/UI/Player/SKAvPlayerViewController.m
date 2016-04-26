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

@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
- (IBAction)onPlayPauseButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
- (IBAction)onStopButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
- (IBAction)onPreviousButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
- (IBAction)onNextButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
- (IBAction)onProgressSliderValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong, nonnull) SKAvListPlayer *player;

@end

@implementation SKAvPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    _player = app.player;
    _player.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self resetProgress];
    [self updatePlayPauseButton];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_player setDataSource:_list atIndex:_index];
        [_player prepare];
        [_player start];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_player stop];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPlayPauseButtonPressed:(id)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([_player isPlaying]) {
            [_player pause];
        } else {
            [_player start];
        }
        
        [self updatePlayPauseButton];
        [self updateProgressLater];
    });
}

- (IBAction)onStopButtonPressed:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_player stop];
        
        [self resetProgress];
        [self updatePlayPauseButton];
    });
}

- (IBAction)onProgressSliderValueChanged:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_player seekTo:_progressSlider.value];
    });
}

- (void)updatePlayPauseButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([_player isPlaying]) {
            [_playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        } else {
            [_playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
        }
    });
}

- (void)resetProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressSlider setValue:0];
        [_progressLabel setText:@"-"];
    });
}

- (void)updateProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        int progress = [_player getCurrentPosition];
        [_progressSlider setValue:progress];
        [_progressLabel setText:[NSString stringWithFormat:@"%@", @(progress)]];
    });
}

- (void)updateDuration {
    dispatch_async(dispatch_get_main_queue(), ^{
        int duration = [_player getDuration];
        [_progressSlider setMaximumValue:duration];
        [_durationLabel setText:[NSString stringWithFormat:@"%@", @(duration)]];
    });
}

- (void)updateProgressLater {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if([_player isPlaying]) {
            [self updateProgress];
            [self updateProgressLater];
        }
    });
}

- (IBAction)onPreviousButtonPressed:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_player previous];
    });
}

- (IBAction)onNextButtonPressed:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_player next];
    });
}

#pragma mark - SKPlayerDelegate

- (void)onPlayerStarted:(nonnull SKPlayer *)player atPosition:(int)position {
    AVAsset *asset = [_list objectAtIndex:_player.index];
    NSString *name = [((AVURLAsset *)asset).URL.absoluteString lastPathComponent];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_nameLabel setText:name];
    });
    
    [self updatePlayPauseButton];
    [self updateDuration];
    [self updateProgressLater];
}

@end
