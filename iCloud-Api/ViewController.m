//
//  ViewController.m
//  iCloud-Api
//
//  Created by huangbiyong on 2019/6/13.
//  Copyright © 2019 chase. All rights reserved.
//

#import "ViewController.h"

#import "BYICloudApi.h"
#import "AccountViewController.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *verifyTextF;

@property (strong, nonatomic) NSDictionary *trustDevice;

@property (strong, nonatomic) NSDictionary *allHeaderFields;

@property (assign, nonatomic) BOOL isPhoneCode; // 判断是哪种验证码

@property (nonatomic, strong) BYICloudApi *icloudApi;

@end

@implementation ViewController

#warning 如果登陆失败，就需要自己填写cookies , 因为 apple 的NSURLSession有自动填充cookies 功能

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *appid = @"";
    NSString *password = @"";
    
    self.icloudApi = [[BYICloudApi alloc] initWithAppid:appid password:password];
    
}


- (IBAction)loginClick:(id)sender {
    
    [self.icloudApi signinWithSuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@" ,task.response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@" ,error);
    }];
}

- (IBAction)sendVerifyCode:(id)sender {
    
    [self.icloudApi sendVerifyCodeWithSuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@" ,task.response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@" ,error);
    }];
}

- (IBAction)sendPhoneVerifyCode:(id)sender {
    [self.icloudApi sendPhoneVerifyCodeWithSuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@" ,task.response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@" ,error);
    }];
}

- (IBAction)verifyClick:(id)sender {
    
    [self.icloudApi verityCode:self.verifyTextF.text success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@" , responseObject);
        
        AccountViewController *account = [[AccountViewController alloc] initWithNibName:nil bundle:nil];
        account.icloudApi = self.icloudApi;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:account];
        [self presentViewController:nav animated:YES completion:nil];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@" ,error);
    }];
}

@end
