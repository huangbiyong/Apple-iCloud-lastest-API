//
//  NSString+Extension.h
//  iCloud-Api
//
//  Created by chhu02 on 2019/6/18.
//  Copyright © 2019 chase. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extension)

- (NSString *)decodeBase64;

+ (NSString *)filePath:(NSString *)filenameEnc;

+ (BOOL)exist:(NSString *)filenameEnc;

@end

NS_ASSUME_NONNULL_END
