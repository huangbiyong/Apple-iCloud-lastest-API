//
//  ICloudApi.h
//  iCloud-Api
//
//  Created by chhu02 on 2019/6/17.
//  Copyright © 2019 chase. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^Success)(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject);
typedef void(^Failure)(NSURLSessionDataTask * _Nullable task,  NSError * _Nullable error);

@interface ICloudApi : NSObject

@property (strong, nonatomic) NSDictionary *trustDevice; // 信任设备列表

@property (strong, nonatomic) NSDictionary *allHeaderFields; // 请求头

@property (assign, nonatomic) BOOL isPhoneCode; // 判断是哪种验证码


- (instancetype)initWithAppid:(NSString *)appid password:(NSString *)password;

// 登陆
- (void)signinWithSuccess:(nullable Success)success failure:(nullable Failure)failure;
- (void)accountLoginWithSuccess:(nullable Success)success failure:(nullable Failure)failure;


// 发送验证码
- (void)sendVerifyCodeWithSuccess:(nullable Success)success failure:(nullable Failure)failure;

// 发送短信验证码
- (void)sendPhoneVerifyCodeWithSuccess:(nullable Success)success failure:(nullable Failure)failure;

// 校验验证码
- (void)verityCode:(NSString *)code success:(nullable Success)success failure:(nullable Failure)failure;

// 获取设备绑定列表
- (void)listDevicesWithSuccess:(nullable Success)success failure:(nullable Failure)failure;

// 获取联系人列表
- (void)getContactsListPrefToken:(nullable NSString *)prefToken syncToken:(nullable NSString *)syncToken  WithSuccess:(Success)success failure:(Failure)failure;


// 获取相册和视频总数
- (void)getPhotosCountSuccess:(Success)success failure:(Failure)failure;

// 获取相册
- (void)getPhotosListresultsLimit:(NSInteger)resultsLimit start:(NSInteger)start success:(Success)success failure:(Failure)failure;

- (NSDictionary *)photosParameters:(NSInteger)resultsLimit;

@end

NS_ASSUME_NONNULL_END
