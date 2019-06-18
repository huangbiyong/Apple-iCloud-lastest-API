//
//  PhotosViewControllers.h
//  iCloud-Api
//
//  Created by chhu02 on 2019/6/18.
//  Copyright © 2019 chase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICloudApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotosViewControllers : UICollectionViewController

@property (nonatomic, strong) ICloudApi *icloudApi;

@end

NS_ASSUME_NONNULL_END
