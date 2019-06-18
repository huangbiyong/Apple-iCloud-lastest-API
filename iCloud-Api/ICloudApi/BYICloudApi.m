//
//  BYICloudApi.m
//  iCloud-Api
//
//  Created by huangbiyong on 2019/6/18.
//  Copyright © 2019 chase. All rights reserved.
//

#import "BYICloudApi.h"

#import <AFNetworking.h>

@interface BYICloudApi ()

@property (nonatomic, strong) NSString *appid;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSDictionary *account;

@property (nonatomic, strong) NSDictionary *contacts;

@end

@implementation BYICloudApi

- (instancetype)initWithAppid:(NSString *)appid password:(NSString *)password {
    self = [super init];
    if (self) {
        self.appid = appid;
        self.password = password;
    }
    return self;
}




#pragma mark - icloud api
// 登录接口1
- (void)signinWithSuccess:(nullable Success)success failure:(nullable Failure)failure {
    
    NSString *appid = self.appid;
    NSString *password = self.password;
    
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
        
        if (success) {
            success(task, responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)task.response;
        //NSLog(@"%@",r.allHeaderFields);
        
        if (failure) {
            failure(task, error);
        }
        
        if (r.statusCode == 409) {
            self.allHeaderFields = r.allHeaderFields;
            [self accountLoginWithSuccess:nil failure:nil];
        }
    }];
    
}

// 登录接口2
- (void)accountLoginWithSuccess:(nullable Success)success failure:(nullable Failure)failure {
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
        
        //NSLog(@"accountLogin %@",responseObject);
        
        self.account = responseObject;
        
        if (success) {
            success(task, responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //NSLog(@"accountLogin error: %@",error);
        if (failure) {
            failure(task, error);
        }
    }];
}

// 发送验证码
- (void)sendVerifyCodeWithSuccess:(Success)success failure:(Failure)failure {
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
        
        //NSLog(@"普通验证码: %@", responseObject);
        
        if (success) {
            success(task, responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //NSLog(@"普通验证码 error: %@", error);
        if (failure) {
            failure(task, error);
        }
        
    }];
}

// 发送短信验证码
- (void)sendPhoneVerifyCodeWithSuccess:(Success)success failure:(Failure)failure {
    // 发送短信验证码
    self.isPhoneCode = YES;
    [self listDevicesWithSuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        NSDictionary *device = ((NSArray *)responseObject[@"devices"]).firstObject;
        if (!device) {
            return ;
        }
        self.trustDevice = device;
        
        
        NSDictionary *json = @{
                               @"mode" : @"sms",
                               @"phoneNumber" : @{@"id" : device[@"deviceId"]}
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
            
            //NSLog(@"短信验证码: %@", responseObject);
            
            if (success) {
                success(task, responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //NSLog(@"短信验证码 error: %@", error);
            
            if (failure) {
                failure(task, error);
            }
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure) {
            failure(task, error);
        }
        
    }];
}

// 校验验证码
- (void)verityCode:(NSString *)code success:(nullable Success)success failure:(nullable Failure)failure {
    // 校验验证码
    
    if (!self.isPhoneCode) { // 普通验证码验证
        
        NSDictionary *json = @{
                               @"securityCode" : @{@"code": code},
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
            
            if (r.statusCode < 300) {
                self.allHeaderFields = r.allHeaderFields;
                [self accountLoginWithSuccess:success failure:failure];
            } else {
                if (failure) {
                    failure(task, nil);
                }
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //NSLog(@"%@",error);
            if (failure) {
                failure(task, error);
            }
            
        }];
        
        
    } else { //短信验证码验证
        
        NSDictionary *json = @{
                               @"mode" : @"sms",
                               @"phoneNumber" : @{@"id" : self.trustDevice[@"deviceId"]},
                               @"securityCode" : @{@"code": code}
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
            
            if (r.statusCode < 300) {
                self.allHeaderFields = r.allHeaderFields;
                [self accountLoginWithSuccess:success failure:failure];
            } else {
                if (failure) {
                    failure(task, nil);
                }
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //NSLog(@"%@",error);
            
            if (failure) {
                failure(task, error);
            }
        }];
        
    }
}


#pragma mark - get bind list device
// 获取设备列表
- (void)listDevicesWithSuccess:(nullable Success)success failure:(nullable Failure)failure {
    
    
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
        
        if (success) {
            success(task, responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //NSLog(@"listDevices error: %@",error);
        
        if (failure) {
            failure(task, error);
        }
        
    }];
    
}

#pragma mark - 获取联系人
- (void)getContactsListPrefToken:(nullable NSString *)prefToken syncToken:(nullable NSString *)syncToken  WithSuccess:(Success)success failure:(Failure)failure {
    
    NSDictionary *json = @{
                           @"clientBuildNumber" : @"1909Hotfix9",
                           @"clientId" : @"0BFB27A5-3FA1-434C-8FBF-25A19A6FDC79",
                           @"clientMasteringNumber" : @"1909Hotfix9",
                           @"order": @"last,first",
                           @"locale": @"zh_CN",
                           @"clientVersion": @"2.1",
                           @"dsid": self.account[@"dsInfo"][@"dsid"]
                           
                           };
    
    NSMutableDictionary *newJson = [NSMutableDictionary dictionaryWithDictionary:json];
    if (prefToken) {
        newJson[@"prefToken"] = prefToken;
    }
    if (syncToken) {
        newJson[@"syncToken"] = syncToken;
    }
    
    // 2. 请求头
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer = [AFJSONRequestSerializer serializer];
    [session.requestSerializer setValue:@"https://www.icloud.com" forHTTPHeaderField:@"Origin"];
    [session.requestSerializer setValue:@"https://www.icloud.com/" forHTTPHeaderField:@"Referer"];
    [session.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    
    NSString *url = self.account[@"webservices"][@"contacts"][@"url"];
    NSArray *urls = [url componentsSeparatedByString:@":"];
    if (urls.count >= 2) {
        NSMutableArray *newUrls = [NSMutableArray arrayWithArray:urls];
        [newUrls removeLastObject];
        url = [newUrls componentsJoinedByString:@":"];
    }
    
    [session GET:[NSString stringWithFormat:@"%@/co/startup", url] parameters:newJson progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@", responseObject);
        
        self.contacts = responseObject;
        
        if (success) {
            success(task, responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);
        
        if (failure) {
            failure(task, error);
        }
        
    }];
    
}


- (void)getZoneListSuccess:( Success)success failure:(Failure)failure {
    NSDictionary *json = @{
                           @"clientId" : @"0BFB27A5-3FA1-434C-8FBF-25A19A6FDC79",
                           
                           @"dsid": self.account[@"dsInfo"][@"dsid"],
                           @"remapEnums": @"true",
                           @"ckjsBuildVersion": @"1910ProjectDev32",
                           @"ckjsVersion": @"2.6.1",
                           @"getCurrentSyncToken": @"true",
                           @"clientBuildNumber": @"1909Hotfix9",
                           @"clientMasteringNumber" : @"1910B30",
                           };
    
    
    
    __block NSString *url = self.account[@"webservices"][@"ckdatabasews"][@"url"];
    NSArray *urls = [url componentsSeparatedByString:@":"];
    if (urls.count >= 2) {
        NSMutableArray *newUrls = [NSMutableArray arrayWithArray:urls];
        [newUrls removeLastObject];
        url = [newUrls componentsJoinedByString:@":"];
    }
    
    url = [NSString stringWithFormat:@"%@/database/1/com.apple.photos.cloud/production/private/zones/list?", url];
    
    
    NSMutableArray *keyValues = [NSMutableArray array];
    [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [keyValues addObject:[NSString stringWithFormat:@"%@=%@" ,key,obj]];
    }];
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer = [AFJSONRequestSerializer serializer];
    [session.requestSerializer setValue:@"https://www.icloud.com" forHTTPHeaderField:@"Origin"];
    [session.requestSerializer setValue:@"https://www.icloud.com/applications/photos/current/zh-cn/index.html?rootDomain=www" forHTTPHeaderField:@"Referer"];
    [session.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    
    
    [session GET:[NSString stringWithFormat:@"%@%@",url, [keyValues componentsJoinedByString:@"&"]] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            success(task, responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];
    
}


- (void)getPhotosCountSuccess:(Success)success failure:(Failure)failure {
    
    [self getZoneListSuccess:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        NSDictionary *json = @{
                               @"clientId" : @"0BFB27A5-3FA1-434C-8FBF-25A19A6FDC79",
                               
                               @"dsid": self.account[@"dsInfo"][@"dsid"],
                               @"remapEnums": @"true",
                               @"ckjsBuildVersion": @"1910ProjectDev32",
                               @"ckjsVersion": @"2.6.1",
                               @"getCurrentSyncToken": @"true",
                               @"clientBuildNumber": @"1909Hotfix9",
                               @"clientMasteringNumber" : @"1910B30",
                               };
        
        
        NSString *url = self.account[@"webservices"][@"ckdatabasews"][@"url"];
        NSArray *urls = [url componentsSeparatedByString:@":"];
        if (urls.count >= 2) {
            NSMutableArray *newUrls = [NSMutableArray arrayWithArray:urls];
            [newUrls removeLastObject];
            url = [newUrls componentsJoinedByString:@":"];
        }
        
        NSMutableArray *newJsons = [NSMutableArray array];
        [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [newJsons addObject:[NSString stringWithFormat:@"%@=%@", key,obj]];
        }];
        
        
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.requestSerializer = [AFJSONRequestSerializer serializer];
        [session.requestSerializer setValue:@"https://www.icloud.com" forHTTPHeaderField:@"Origin"];
        [session.requestSerializer setValue:@"https://www.icloud.com/applications/photos/current/zh-cn/index.html?rootDomain=www" forHTTPHeaderField:@"Referer"];
        [session.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self photosParameters:@"photosCountParameter"]];
        
        NSArray *zones = responseObject[@"zones"];
        if (zones && zones.count >=1) {
            NSDictionary *zoneID = ((NSDictionary *)zones.firstObject)[@"zoneID"];
            parameters[@"zoneID"] = zoneID;
        }
        
        [session POST:[NSString stringWithFormat:@"%@/database/1/com.apple.photos.cloud/production/private/records/query?%@", url, [newJsons componentsJoinedByString:@"&"]] parameters:parameters progress:nil success:
         ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             if (success) {
                 success(task, responseObject);
             }
             
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             
             if (failure) {
                 failure(task, error);
             }
         }];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        if (failure) {
            failure(task, error);
        }
    }];
}


- (void)getPhotosListResultsLimit:(NSInteger)resultsLimit start:(NSInteger)start success:(Success)success failure:(Failure)failure {
    
    [self getZoneListSuccess:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        NSDictionary *json = @{
                               @"clientId" : @"0BFB27A5-3FA1-434C-8FBF-25A19A6FDC79",
                               
                               @"dsid": self.account[@"dsInfo"][@"dsid"],
                               @"remapEnums": @"true",
                               @"ckjsBuildVersion": @"1910ProjectDev32",
                               @"ckjsVersion": @"2.6.1",
                               @"getCurrentSyncToken": @"true",
                               @"clientBuildNumber": @"1909Hotfix9",
                               @"clientMasteringNumber" : @"1910B30",
                               };
        
        
        NSString *url = self.account[@"webservices"][@"ckdatabasews"][@"url"];
        NSArray *urls = [url componentsSeparatedByString:@":"];
        if (urls.count >= 2) {
            NSMutableArray *newUrls = [NSMutableArray arrayWithArray:urls];
            [newUrls removeLastObject];
            url = [newUrls componentsJoinedByString:@":"];
        }
        
        NSMutableArray *newJsons = [NSMutableArray array];
        [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [newJsons addObject:[NSString stringWithFormat:@"%@=%@", key,obj]];
        }];
        
        
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.requestSerializer = [AFJSONRequestSerializer serializer];
        [session.requestSerializer setValue:@"https://www.icloud.com" forHTTPHeaderField:@"Origin"];
        [session.requestSerializer setValue:@"https://www.icloud.com/applications/photos/current/zh-cn/index.html?rootDomain=www" forHTTPHeaderField:@"Referer"];
        [session.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self photosParameters:@"photosParameter" start:start]];
        parameters[@"resultsLimit"] = @(resultsLimit);
        
        
        NSArray *zones = responseObject[@"zones"];
        if (zones && zones.count >=1) {
            NSDictionary *zoneID = ((NSDictionary *)zones.firstObject)[@"zoneID"];
            parameters[@"zoneID"] = zoneID;
        }
        
        
        
        [session POST:[NSString stringWithFormat:@"%@/database/1/com.apple.photos.cloud/production/private/records/query?%@", url, [newJsons componentsJoinedByString:@"&"]] parameters:parameters progress:nil success:
         ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             //NSLog(@"%@",responseObject);
             
             if (success) {
                 success(task, responseObject);
             }
             
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             //NSLog(@"请求失败--%@",error);
             if (failure) {
                 failure(task, error);
             }
         }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        if (failure) {
            failure(task, error);
        }
    }];
    
}


- (NSDictionary *)photosParameters:(NSString *)filename {
    
    NSString *pathBundle = [[NSBundle mainBundle]pathForResource:filename ofType:nil];
    NSData *data = [[NSData alloc]initWithContentsOfFile:pathBundle];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return dict;
}

- (NSDictionary *)photosParameters:(NSString *)filename start:(NSInteger)start {
    
    NSString *pathBundle = [[NSBundle mainBundle]pathForResource:filename ofType:nil];
    NSData *data = [[NSData alloc]initWithContentsOfFile:pathBundle];
    
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dataStr = [[dataStr componentsSeparatedByString:@"yyy"] componentsJoinedByString:[NSString stringWithFormat:@"%ld",start]];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    return dict;
}


@end
