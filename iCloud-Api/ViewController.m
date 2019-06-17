//
//  ViewController.m
//  iCloud-Api
//
//  Created by chhu02 on 2019/6/13.
//  Copyright © 2019 chase. All rights reserved.
//

#import "ViewController.h"

#import <AFNetworking.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *verifyTextF;

@property (strong, nonatomic) NSDictionary *trustDevice;

@property (strong, nonatomic) NSDictionary *allHeaderFields;

@property (assign, nonatomic) BOOL isPhoneCode; // 判断是哪种验证码

@end

@implementation ViewController

#warning 如果登陆失败，就需要自己填写cookies , 因为 apple 的NSURLSession有自动填充cookies 功能

- (IBAction)loginClick:(id)sender {
    [self signin];
}

- (IBAction)sendVerifyCode:(id)sender {
    [self sendVerifyC];
}

- (IBAction)sendPhoneVerifyCode:(id)sender {
    [self sendPhoneVerifyC];
}

- (IBAction)verifyClick:(id)sender {
    [self verityC];
}

#pragma mark - icloud api
// 登录接口1
- (void)signin {
    
    NSString *appid = @"";
    NSString *password = @"";
    
    if (appid.length == 0 || password.length == 0) {
        NSLog(@"请先填写你的appid 或 密码");
        return;
    }
    
    // 1. 参数
    NSDictionary *json = @{
                           @"accountName" : appid,
                           @"password" : password,
                           @"rememberMe" : @(0),
                           @"trustTokens" : @[]
                           };
    
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer = [AFJSONRequestSerializer serializer];
    [session.requestSerializer setValue:@"https://idmsa.apple.com" forHTTPHeaderField:@"Origin"];
    [session.requestSerializer setValue:@"https://idmsa.apple.com/appleauth/auth/signin?widgetKey=d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d&locale=zh_CN&font=sf&iframeId=0cf1e6ef-bd4d-4d70-bd86-f8ba8064dc57" forHTTPHeaderField:@"Referer"];
    [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [session.requestSerializer setValue:@"3" forHTTPHeaderField:@"X-Apple-Domain-Id"];
    [session.requestSerializer setValue:@"0cf1e6ef-bd4d-4d70-bd86-f8ba8064dc57" forHTTPHeaderField:@"X-Apple-Frame-Id"];
    [session.requestSerializer setValue:@"d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d" forHTTPHeaderField:@"X-Apple-Widget-Key"];
    
    [session POST:@"https://idmsa.apple.com/appleauth/auth/signin" parameters:json progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)task.response;
        NSLog(@"%@",r.allHeaderFields);
        
        if (r.statusCode == 409) {
            self.allHeaderFields = r.allHeaderFields;
            [self accountLogin];
        }
    }];
    
}

// 登录接口2
- (void)accountLogin {
    // 1. 参数
    // accountCountryCode  dsWebAuthToken 都是从 auth/signin 的响应头里面获取
    NSDictionary *json = @{
                           @"accountCountryCode" : self.allHeaderFields[@"X-Apple-ID-Account-Country"],
                           @"dsWebAuthToken" : self.allHeaderFields[@"X-Apple-Session-Token"],
                           @"clientBuildNumber" : @"1909Hotfix9",
                           @"clientId" : @"C8E9B7E9-B56F-4AEF-879F-BB533CFEABEC",
                           @"clientMasteringNumber" : @"1909Hotfix9"
                           };
    
    
    // 2. 请求头
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer = [AFJSONRequestSerializer serializer];
    [session.requestSerializer setValue:@"https://www.icloud.com" forHTTPHeaderField:@"Origin"];
    [session.requestSerializer setValue:@"https://www.icloud.com/" forHTTPHeaderField:@"Referer"];
    [session.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    
    
    [session POST:@"https://setup.icloud.com/setup/ws/1/accountLogin" parameters:json progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"accountLogin %@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"accountLogin error: %@",error);
    }];
}

// 发送验证码
- (void)sendVerifyC {
    // 发送普通验证码
    self.isPhoneCode = NO;
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer = [AFJSONRequestSerializer serializer];
    [session.requestSerializer setValue:@"https://idmsa.apple.com" forHTTPHeaderField:@"Origin"];
    [session.requestSerializer setValue:@"https://idmsa.apple.com/appleauth/auth/signin?widgetKey=d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d&locale=zh_CN&font=sf&iframeId=99160d32-7e60-4045-bfd8-efe6ec02e0a5" forHTTPHeaderField:@"Referer"];
    [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [session.requestSerializer setValue:self.allHeaderFields[@"scnt"] forHTTPHeaderField:@"scnt"];
    [session.requestSerializer setValue:@"3" forHTTPHeaderField:@"X-Apple-Domain-Id"];
    [session.requestSerializer setValue:@"0cf1e6ef-bd4d-4d70-bd86-f8ba8064dc57" forHTTPHeaderField:@"X-Apple-Frame-Id"];
    [session.requestSerializer setValue:self.allHeaderFields[@"X-Apple-ID-Session-Id"] forHTTPHeaderField:@"X-Apple-ID-Session-Id"];
    [session.requestSerializer setValue:@"d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d" forHTTPHeaderField:@"X-Apple-Widget-Key"];
    
    [session PUT:@"https://idmsa.apple.com/appleauth/auth/verify/trusteddevice/securitycode" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"普通验证码: %@", responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"普通验证码 error: %@", error);
    }];
}

// 发送短信验证码
- (void)sendPhoneVerifyC {
    // 发送短信验证码
    self.isPhoneCode = YES;
    [self listDevices:^(NSNumber *deviceId, NSString *deviceType) {
        
        NSDictionary *json = @{
                               @"mode" : @"sms",
                               @"phoneNumber" : @{@"id" : deviceId}
                               };
        
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.requestSerializer = [AFJSONRequestSerializer serializer];
        [session.requestSerializer setValue:@"https://idmsa.apple.com" forHTTPHeaderField:@"Origin"];
        [session.requestSerializer setValue:@"https://idmsa.apple.com/appleauth/auth/signin?widgetKey=d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d&locale=zh_CN&font=sf&iframeId=99160d32-7e60-4045-bfd8-efe6ec02e0a5" forHTTPHeaderField:@"Referer"];
        [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [session.requestSerializer setValue:self.allHeaderFields[@"scnt"] forHTTPHeaderField:@"scnt"];
        [session.requestSerializer setValue:@"3" forHTTPHeaderField:@"X-Apple-Domain-Id"];
        [session.requestSerializer setValue:@"0cf1e6ef-bd4d-4d70-bd86-f8ba8064dc57" forHTTPHeaderField:@"X-Apple-Frame-Id"];
        [session.requestSerializer setValue:self.allHeaderFields[@"X-Apple-ID-Session-Id"] forHTTPHeaderField:@"X-Apple-ID-Session-Id"];
        [session.requestSerializer setValue:@"d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d" forHTTPHeaderField:@"X-Apple-Widget-Key"];
        
        [session PUT:@"https://idmsa.apple.com/appleauth/auth/verify/phone" parameters:json success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSLog(@"短信验证码: %@", responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"短信验证码 error: %@", error);
        }];
        
    }];
}

// 校验验证码
- (void)verityC {
    // 校验验证码
    
    if (!self.isPhoneCode) { // 普通验证码验证
        
        NSDictionary *json = @{
                               @"securityCode" : @{@"code": self.verifyTextF.text},
                               };
        
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.requestSerializer = [AFJSONRequestSerializer serializer];
        [session.requestSerializer setValue:@"https://idmsa.apple.com" forHTTPHeaderField:@"Origin"];
        [session.requestSerializer setValue:@"https://idmsa.apple.com/appleauth/auth/signin?widgetKey=d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d&locale=zh_CN&font=sf&iframeId=99160d32-7e60-4045-bfd8-efe6ec02e0a5" forHTTPHeaderField:@"Referer"];
        [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [session.requestSerializer setValue:self.allHeaderFields[@"scnt"] forHTTPHeaderField:@"scnt"];
        [session.requestSerializer setValue:@"3" forHTTPHeaderField:@"X-Apple-Domain-Id"];
        [session.requestSerializer setValue:@"0cf1e6ef-bd4d-4d70-bd86-f8ba8064dc57" forHTTPHeaderField:@"X-Apple-Frame-Id"];
        [session.requestSerializer setValue:self.allHeaderFields[@"X-Apple-ID-Session-Id"] forHTTPHeaderField:@"X-Apple-ID-Session-Id"];
        [session.requestSerializer setValue:@"d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d" forHTTPHeaderField:@"X-Apple-Widget-Key"];
        
        [session POST:@"https://idmsa.apple.com/appleauth/auth/verify/trusteddevice/securitycode" parameters:json progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSHTTPURLResponse *r = (NSHTTPURLResponse *)task.response;
            NSLog(@"%@",r);
            if (r.statusCode < 300) {
                self.allHeaderFields = r.allHeaderFields;
                [self accountLogin];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
        
        
    } else { //短信验证码验证
        
        NSDictionary *json = @{
                               @"mode" : @"sms",
                               @"phoneNumber" : @{@"id" : self.trustDevice[@"deviceId"]},
                               @"securityCode" : @{@"code": self.verifyTextF.text}
                               };
        
        
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.requestSerializer = [AFJSONRequestSerializer serializer];
        [session.requestSerializer setValue:@"https://idmsa.apple.com" forHTTPHeaderField:@"Origin"];
        [session.requestSerializer setValue:@"https://idmsa.apple.com/appleauth/auth/signin?widgetKey=d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d&locale=zh_CN&font=sf&iframeId=99160d32-7e60-4045-bfd8-efe6ec02e0a5" forHTTPHeaderField:@"Referer"];
        [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [session.requestSerializer setValue:self.allHeaderFields[@"scnt"] forHTTPHeaderField:@"scnt"];
        [session.requestSerializer setValue:@"3" forHTTPHeaderField:@"X-Apple-Domain-Id"];
        [session.requestSerializer setValue:@"0cf1e6ef-bd4d-4d70-bd86-f8ba8064dc57" forHTTPHeaderField:@"X-Apple-Frame-Id"];
        [session.requestSerializer setValue:self.allHeaderFields[@"X-Apple-ID-Session-Id"] forHTTPHeaderField:@"X-Apple-ID-Session-Id"];
        [session.requestSerializer setValue:@"d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d" forHTTPHeaderField:@"X-Apple-Widget-Key"];
        
        [session POST:@"https://idmsa.apple.com/appleauth/auth/verify/phone/securitycode" parameters:json progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSHTTPURLResponse *r = (NSHTTPURLResponse *)task.response;
            NSLog(@"%@",r);
            if (r.statusCode < 300) {
                self.allHeaderFields = r.allHeaderFields;
                [self accountLogin];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
        
    }
}


#pragma mark - get bind list device
// 获取设备列表
- (void)listDevices:(void(^) (NSNumber *deviceId, NSString *deviceType))block {

    
    NSDictionary *json = @{
                           @"clientBuildNumber" : @"1909Hotfix9",
                           @"clientId" : @"0BFB27A5-3FA1-434C-8FBF-25A19A6FDC79",
                           @"clientMasteringNumber" : @"1909Hotfix9",
                           };
    
    // 2. 请求头
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer = [AFJSONRequestSerializer serializer];
    [session.requestSerializer setValue:@"https://www.icloud.com" forHTTPHeaderField:@"Origin"];
    [session.requestSerializer setValue:@"https://www.icloud.com/" forHTTPHeaderField:@"Referer"];
    [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    [session GET:@"https://setup.icloud.com/setup/ws/1/listDevices" parameters:json progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"listDevices %@",responseObject);
        NSDictionary *device = ((NSArray *)responseObject[@"devices"]).firstObject;
        self.trustDevice = device;
        block(device[@"deviceId"], device[@"deviceType"]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"listDevices error: %@",error);
    }];
}


@end
