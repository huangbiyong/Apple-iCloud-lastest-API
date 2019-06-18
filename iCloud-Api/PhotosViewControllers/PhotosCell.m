//
//  PhotosCell.m
//  iCloud-Api
//
//  Created by chhu02 on 2019/6/18.
//  Copyright © 2019 chase. All rights reserved.
//

#import "PhotosCell.h"

@implementation PhotosCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [self addSubview:self.imageView];
        
        self.videoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(100-30, 100-30, 30, 30)];
        self.videoImgView.image = [UIImage imageNamed:@"video.jpg"];
        self.videoImgView.hidden = YES;
        [self addSubview:self.videoImgView];
    }
    return self;
}



@end
