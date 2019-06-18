//
//  NSString+Extension.m
//  iCloud-Api
//
//  Created by huangbiyong on 2019/6/18.
//  Copyright © 2019 chase. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (NSString *)decodeBase64
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    return string;
}

+ (NSString *)filePath:(NSString *)filenameEnc {
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *value = filenameEnc;
    NSString *filePath = [path stringByAppendingPathComponent:[value decodeBase64]];
    
    return filePath;
}

+ (BOOL)exist:(NSString *)filePath {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) return true;
    return false;
}

@end
