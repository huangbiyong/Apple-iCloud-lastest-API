//
//  AccountViewController.h
//  iCloud-Api
//
//  Created by huangbiyong on 2019/6/17.
//  Copyright © 2019 chase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYICloudApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccountViewController : UIViewController

@property (nonatomic, strong) BYICloudApi *icloudApi;

@end

NS_ASSUME_NONNULL_END
