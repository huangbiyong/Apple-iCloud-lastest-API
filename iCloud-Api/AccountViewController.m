//
//  AccountViewController.m
//  iCloud-Api
//
//  Created by chhu02 on 2019/6/17.
//  Copyright © 2019 chase. All rights reserved.
//

#import "AccountViewController.h"
#import "ContactsViewController.h"
#import "PhotosViewControllers.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)contactsList:(id)sender {
    
    ContactsViewController *vc = [[ContactsViewController alloc] init];
    vc.icloudApi = self.icloudApi;
    [self.navigationController pushViewController:vc animated:YES];

}

- (IBAction)photosList:(id)sender {

    PhotosViewControllers *vc = [[PhotosViewControllers alloc] init];
    vc.icloudApi = self.icloudApi;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)logout:(id)sender {
    
}

@end
