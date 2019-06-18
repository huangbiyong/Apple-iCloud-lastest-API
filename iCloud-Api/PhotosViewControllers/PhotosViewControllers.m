//
//  PhotosViewControllers.m
//  iCloud-Api
//
//  Created by huangbiyong on 2019/6/18.
//  Copyright © 2019 chase. All rights reserved.
//

#import "PhotosViewControllers.h"
#import "PhotosCell.h"
#import <AFNetworking/UIKit+AFNetworking.h>
#import "NSString+Extension.h"
#import "MJRefresh.h"

@interface PhotosViewControllers ()

@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, assign) NSInteger photosCount;

@end

@implementation PhotosViewControllers

static NSString * const reuseIdentifier = @"PhotosCell";

-(instancetype)init{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(100, 100);
    // 设置最小行间距
    layout.minimumLineSpacing = 20;
    // 设置垂直间距
    layout.minimumInteritemSpacing = 20;
    // 设置边缘的间距，默认是{0，0，0，0}
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    return [self initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"相册";
    
    self.photos = [NSMutableArray array];
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    [self.collectionView registerClass:[PhotosCell class] forCellWithReuseIdentifier:reuseIdentifier];
    

    [self setupMJ];
    
    __weak PhotosViewControllers *weakSelf = self;
    [self.icloudApi getPhotosCountSuccess:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        
        NSArray *records = responseObject[@"records"];
        NSDictionary *record = records.firstObject;
        weakSelf.photosCount = [record[@"fields"][@"itemCount"][@"value"] integerValue];
        
        [weakSelf.collectionView.mj_header beginRefreshing];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        NSLog(@"%@", error);
        
    }];
}


- (void)setupMJ {
    
    __weak PhotosViewControllers *weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadPhotosList:0];
    }];

    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        if (weakSelf.photos.count >= weakSelf.photosCount) {
            [weakSelf.collectionView.mj_header endRefreshing];
            [weakSelf.collectionView.mj_footer endRefreshing];
            return;
        }
        [weakSelf loadPhotosList:self.photos.count];
        
    }];
}

- (void)loadPhotosList:(NSInteger)start {
    
    
    [self.icloudApi getPhotosListResultsLimit:100 start:start success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
        
        if (start == 0) {
            [self.photos removeAllObjects];
        }
        
        NSArray *records = responseObject[@"records"];
        for (NSInteger i=0; i<records.count; i++) {
            NSDictionary *record = records[i];
            if (record[@"fields"][@"resOriginalRes"]) {
                [self.photos addObject:record];
            }
        }
        
        [self.collectionView reloadData];
        

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
        
    }];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete implementation, return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of items
    return self.photos.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[PhotosCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    
    
    NSDictionary *record = self.photos[indexPath.row];
    
    NSDictionary *resJPEGThumbRes = record[@"fields"][@"resJPEGThumbRes"];
    
    
    NSString *downloadURL = resJPEGThumbRes[@"value"][@"downloadURL"];
    if (downloadURL) {
        
        /* 下载路径 */

        NSDictionary *filenameEnc = record[@"fields"][@"filenameEnc"];
        NSString *value = filenameEnc[@"value"];
        
        NSString *path = [NSString filePath:value];
        NSLog(@"%@", path);
        
        if ([path hasSuffix:@"mp4"] || [path hasSuffix:@"mov"] || [path hasSuffix:@"MOV"]) {
            cell.videoImgView.hidden = NO;
        } else {
            cell.videoImgView.hidden = YES;
        }
        
        if (![NSString exist:path]) {
            
            NSString * urlStr = [downloadURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return [NSURL fileURLWithPath:path];
                
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath1, NSError * _Nullable error) {
                [cell.imageView setImageWithURL:[NSURL fileURLWithPath:path]];
            }];
            [downloadTask resume];
        } else {
            [cell.imageView setImageWithURL:[NSURL fileURLWithPath:path]];
        }
        
    } else {
        cell.imageView.image = nil;
        cell.videoImgView.hidden = YES;
    }

    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

@end
