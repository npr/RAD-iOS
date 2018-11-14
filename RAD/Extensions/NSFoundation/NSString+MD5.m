//
//  NSString+MD5.m
//  RAD
//
//  Copyright 2018 NPR
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use
//  this file except in compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MD5)

- (NSString *)md5 {
    const char *buffer = [self UTF8String];
    if (buffer == nil) {
        return nil;
    }

    unsigned char md5Result[CC_MD5_DIGEST_LENGTH];

    CC_MD5(buffer, (CC_LONG) strlen(buffer), md5Result);

    NSMutableString *result =
    [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH];

    for (int index = 0; index < CC_MD5_DIGEST_LENGTH; ++index) {
        [result appendFormat:@"%02x", md5Result[index]];
    }

    return result;
}

@end
