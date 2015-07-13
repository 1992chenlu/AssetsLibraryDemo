//
//  MyTableViewController.m
//  MyAssetsLibraryDemo
//
//  Created by 鲁辰 on 7/8/15.
//  Copyright (c) 2015 ChenLu. All rights reserved.
//

#import "MyTableViewController.h"

@implementation MyTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated  {
    _videoTitleArray = [[NSMutableArray alloc] init];
    _videoURLArray = [[NSMutableArray alloc] init];
    _videoImageArray = [[NSMutableArray alloc] init];
    [self buildAssetsLibrary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    return _videoTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    NSString *stringForCell;
    stringForCell= [_videoTitleArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:stringForCell];
    cell.imageView.image = [_videoImageArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Show Video List Methods
- (void)buildAssetsLibrary
{
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    ALAssetsLibrary *notificationSender = nil;
    
    NSString *minimumSystemVersion = @"4.1";
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion compare:minimumSystemVersion options:NSNumericSearch] != NSOrderedAscending)
        notificationSender = _assetsLibrary;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryDidChange:) name:ALAssetsLibraryChangedNotification object:notificationSender];
    [self updateAssetsLibrary];
}

- (void)assetsLibraryDidChange:(NSNotification*)changeNotification
{
    [self updateAssetsLibrary];
}

- (void)updateAssetsLibrary
{
    ALAssetsLibrary *assetLibrary = _assetsLibrary;
    
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         if (group)
         {
             [group setAssetsFilter:[ALAssetsFilter allVideos]];
             //Please see: https://developer.apple.com/library/ios/documentation/AssetsLibrary/Reference/ALAssetsFilter_Class/
             //To get all assets (photos and videos), use allAssets as filter.
             
             [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
              {
                  if (asset)
                  {
                      ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
                      NSString *uti = [defaultRepresentation UTI];
                      NSURL *videoURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
                      
                      NSString *title = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Video", nil)];
                      [_videoTitleArray addObject:title];
                      [_videoURLArray addObject:videoURL];
                      
                      CGImageRef thumbnailImageRef = [asset thumbnail];
                      UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
                      [_videoImageArray addObject:thumbnail];
                      [self.tableView reloadData];
                  }
              } ];
         }
     }
                              failureBlock:^(NSError *error)
     {
         NSLog(@"error enumerating AssetLibrary groups %@\n", error);
     }];
}

@end
