//
//  ViewController.m
//  iCloud-Api
//
//  Created by chhu02 on 2019/6/13.
//  Copyright © 2019 chase. All rights reserved.
//

#import "ViewController.h"

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
    
    NSString *accountName = @"";
    NSString *password = @"";
    
    if (accountName.length == 0 || password.length == 0) {
        NSLog(@"请先填写你的appid 或 密码");
        return;
    }
    
    // 1. 参数
    NSDictionary *json = @{
                           @"accountName" : accountName,
                           @"password" : password,
                           @"rememberMe" : @(0),
                           @"trustTokens" : @[]
                           };
    
    NSURL *url = [NSURL URLWithString:@"https://idmsa.apple.com/appleauth/auth/signin"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = @{
                                    @"Origin": @"https://idmsa.apple.com",
                                    @"Content-Type": @"application/json",
                                    @"Accept": @"application/json",
                                    @"Referer": @"https://idmsa.apple.com/appleauth/auth/signin?widgetKey=d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d&locale=zh_CN&font=sf&iframeId=0cf1e6ef-bd4d-4d70-bd86-f8ba8064dc57",
                                    @"X-Apple-Domain-Id": @"3",
                                    @"X-Apple-Frame-Id": @"0cf1e6ef-bd4d-4d70-bd86-f8ba8064dc57",
                                    @"X-Apple-Widget-Key": @"d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d"
                                    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    request.HTTPBody = data;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;

        NSLog(@"%@",r.allHeaderFields);
        
        if (r.statusCode == 409) {
            self.allHeaderFields = r.allHeaderFields;
            [self accountLogin];
        }
        
    }] resume];
    
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
    
    NSURL *url = [NSURL URLWithString:@"https://setup.icloud.com/setup/ws/1/accountLogin"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = @{
                                    @"Origin": @"https://www.icloud.com",
                                    @"Referer": @"https://www.icloud.com/",
                                    @"Accept": @"application/json",
                                    @"Content-Type": @"text/plain",
                
                                    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    request.HTTPBody = data;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
        NSLog(@"%@",response);
        
    }] resume];
}

// 发送验证码
- (void)sendVerifyC {
    // 发送普通验证码
    self.isPhoneCode = NO;
    
    NSURL *url = [NSURL URLWithString:@"https://idmsa.apple.com/appleauth/auth/verify/trusteddevice/securitycode"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    request.allHTTPHeaderFields = @{
                                    @"Accept": @"application/json",
                                    @"Content-Type": @"application/json",
                                    @"Origin": @"https://idmsa.apple.com",
                                    @"Referer": @"https://idmsa.apple.com/appleauth/auth/signin?widgetKey=d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d&locale=zh_CN&font=sf&iframeId=99160d32-7e60-4045-bfd8-efe6ec02e0a5",
                                    @"scnt": self.allHeaderFields[@"scnt"],
                                    
                                    @"X-Apple-Domain-Id":@"3",
                                    @"X-Apple-Frame-Id": @"da6b2571-aff6-4cfc-a020-3bc92b45ec2c",
                                    @"X-Apple-ID-Session-Id": self.allHeaderFields[@"X-Apple-ID-Session-Id"],
                                    @"X-Apple-Widget-Key": @"d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d",
                                    };
    
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSLog(@"%@",response);
        
    }] resume];
}

// 发送短信验证码
- (void)sendPhoneVerifyC {
    // 发送短信验证码
    self.isPhoneCode = YES;
    [self listDevices:^(NSNumber *deviceId, NSString *deviceType) {
        
        NSURL *url = [NSURL URLWithString:@"https://idmsa.apple.com/appleauth/auth/verify/phone"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"PUT";
        request.allHTTPHeaderFields = @{
                                        @"Accept": @"application/json",
                                        @"Content-Type": @"application/json",
                                        @"Origin": @"https://idmsa.apple.com",
                                        @"Referer": @"https://idmsa.apple.com/appleauth/auth/signin?widgetKey=d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d&locale=zh_CN&font=sf&iframeId=99160d32-7e60-4045-bfd8-efe6ec02e0a5",
                                        @"scnt": self.allHeaderFields[@"scnt"],
                                        
                                        @"X-Apple-Domain-Id":@"3",
                                        @"X-Apple-Frame-Id": @"da6b2571-aff6-4cfc-a020-3bc92b45ec2c",
                                        @"X-Apple-ID-Session-Id": self.allHeaderFields[@"X-Apple-ID-Session-Id"],
                                        @"X-Apple-Widget-Key": @"d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d",
                                        };
        
        NSDictionary *json = @{
                               @"mode" : @"sms",
                               @"phoneNumber" : @{@"id" : deviceId}
                               };
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
        
        request.HTTPBody = data;
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSLog(@"%@",response);
            
        }] resume];
    }];
}

// 校验验证码
- (void)verityC {
    // 校验验证码
    
    if (!self.isPhoneCode) { // 普通验证码验证
        NSURL *url = [NSURL URLWithString:@"https://idmsa.apple.com/appleauth/auth/verify/trusteddevice/securitycode"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        request.allHTTPHeaderFields = @{
                                        @"Accept": @"application/json",
                                        @"Content-Type": @"application/json",
                                        @"Origin": @"https://idmsa.apple.com",
                                        @"Referer": @"https://idmsa.apple.com/appleauth/auth/signin?widgetKey=d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d&locale=zh_CN&font=sf&iframeId=99160d32-7e60-4045-bfd8-efe6ec02e0a5",
                                        @"scnt": self.allHeaderFields[@"scnt"],
                                        
                                        @"X-Apple-Domain-Id":@"3",
                                        @"X-Apple-Frame-Id": @"da6b2571-aff6-4cfc-a020-3bc92b45ec2c",
                                        @"X-Apple-ID-Session-Id": self.allHeaderFields[@"X-Apple-ID-Session-Id"],
                                        @"X-Apple-Widget-Key": @"d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d",
                                        };
        
        NSDictionary *json = @{
                               @"securityCode" : @{@"code": self.verifyTextF.text},
                               };
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
        request.HTTPBody = data;
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            
            NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
            NSLog(@"%@",response);
            
            // 校验成功后， 重新登录
            if (r.statusCode < 300) {
                self.allHeaderFields = r.allHeaderFields;
                [self accountLogin];
            }
            
            
        }] resume];
    } else { //短信验证码验证
        
        NSURL *url = [NSURL URLWithString:@"https://idmsa.apple.com/appleauth/auth/verify/phone/securitycode"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        request.allHTTPHeaderFields = @{
                                        @"Accept": @"application/json",
                                        @"Content-Type": @"application/json",
                                        @"Origin": @"https://idmsa.apple.com",
                                        @"Referer": @"https://idmsa.apple.com/appleauth/auth/signin?widgetKey=d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d&locale=zh_CN&font=sf&iframeId=99160d32-7e60-4045-bfd8-efe6ec02e0a5",
                                        @"scnt": self.allHeaderFields[@"scnt"],
                                        
                                        @"X-Apple-Domain-Id":@"3",
                                        @"X-Apple-Frame-Id": @"da6b2571-aff6-4cfc-a020-3bc92b45ec2c",
                                        @"X-Apple-ID-Session-Id": self.allHeaderFields[@"X-Apple-ID-Session-Id"],
                                        @"X-Apple-Widget-Key": @"d39ba9916b7251055b22c7f910e2ea796ee65e98b2ddecea8f5dde8d9d1a815d",
                                        };
        
        NSDictionary *json = @{
                               @"mode" : @"sms",
                               @"phoneNumber" : @{@"id" : self.trustDevice[@"deviceId"]},
                               @"securityCode" : @{@"code": self.verifyTextF.text}
                               };
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
        request.HTTPBody = data;
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            
            NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
            NSLog(@"%@",response);
            
            // 校验成功后， 重新登录
            if (r.statusCode < 300) {
                self.allHeaderFields = r.allHeaderFields;
                [self accountLogin];
            }
            
        }] resume];
        
    }
}


#pragma mark - get bind list device
// 获取设备列表
- (void)listDevices:(void(^) (NSNumber *deviceId, NSString *deviceType))block {

    
    NSURL *url = [NSURL URLWithString:@"https://setup.icloud.com/setup/ws/1/listDevices?clientBuildNumber=1909Hotfix9&clientId=0BFB27A5-3FA1-434C-8FBF-25A19A6FDC79&clientMasteringNumber=1909Hotfix9"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.allHTTPHeaderFields = @{
                                    @"Origin": @"https://www.icloud.com",
                                    @"Referer": @"https://www.icloud.com/",
                                    @"Content-Type": @"application/json",
                                    };
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSLog(@"%@",response);
        
        id   responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSLog(@"listDevices %@",responseObject);
        NSDictionary *device = ((NSArray *)responseObject[@"devices"]).firstObject;
        
        if (device) {
            self.trustDevice = device;
            block(device[@"deviceId"], device[@"deviceType"]);
        }
        
    }] resume];
}


@end
