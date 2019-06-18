# Apple-iCloud-lastest-API
最新的apple icloud api，亲测成功


1. 调用signin，使用appid 账号和 密码登陆
2.  调用accountLogin， 获取用户信息；
3.  获取已经绑定的设备列表，主要是用在获取 **短信验证码**
3.  发送验证码 或 短信验证码
4.  校验验证码
5.  刷新dsWebAuthToken， 重新调用accountLogin， 获取用户信息；


![image.png](https://upload-images.jianshu.io/upload_images/8533386-ba36eeaeb751ed4a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


```
- (void)setupAccount {

   NSString *appid = @"";
   NSString *password = @"";

   self.icloudApi = [[BYICloudApi alloc] initWithAppid:appid password:password];
}

```


- 如果登陆失败，就需要自己填写cookies , 因为 apple 的NSURLSession有自动填充cookies 功能
