//
//  SKMopidyPlaybackTableViewController.m
//  SKMopidyDemo
//
//  Created by Shin-Kai Chen on 2016/4/21.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKAvPlaybackTableViewController.h"

#import "SKAvPlayerViewController.h"
#import "AppDelegate.h"

static NSString *testUrl1 = @"http://skchen.synology.me:5000/fbsharing/yeo83cAl";
static NSString *testUrl2 = @"http://skchen.synology.me:5000/fbsharing/aWGTK2Zo";
static NSString *testUrl3 = @"http://skchen.synology.me:5000/fbsharing/lqX5DllN";
static NSString *testUrl4 = @"http://skchen.synology.me:5000/fbsharing/lHHL48fb";

@interface SKAvPlaybackTableViewController ()

@property(nonatomic, strong, nullable) NSArray<AVAsset *> *resources;
@property(nonatomic, strong, nullable) NSMutableArray *refs;

@end

@implementation SKAvPlaybackTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _refs = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryAndShow];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_resources count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SKMopidyPlaybackTableViewCell"];
    
    AVAsset *asset = [_resources objectAtIndex:indexPath.row];
    NSString *name = [((AVURLAsset *)asset).URL.absoluteString lastPathComponent];
    
    [cell.textLabel setText:name];
    
    return cell;
}

#pragma mark - Misc

- (void)queryAndShow {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        AVAsset *asset1 = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:testUrl1] options:nil];
        AVAsset *asset2 = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:testUrl2] options:nil];
        AVAsset *asset3 = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:testUrl3] options:nil];
        AVAsset *asset4 = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:testUrl4] options:nil];
        _resources = @[asset1, asset2, asset3, asset4];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    SKAvPlayerViewController *destinationViewController = segue.destinationViewController;
    
    destinationViewController.list = _resources;
    destinationViewController.index = indexPath.row;
}

@end
