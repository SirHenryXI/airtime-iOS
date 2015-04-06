//
//  CAValidator.m
//  AirTime
//
//  Created by Chase Acton on 11/24/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import "CAValidator.h"

@implementation CAValidator

+ (BOOL)validURL:(NSString *)url{
    NSLog(@"checking: %@",url);
    NSString *urlRegEx =
    @"(http|https)://(?:([^:/?#]+):)?(?://([^/?#]*))?([^?#]*\\.(?:jpg|gif|png))(?:\\?([^#]*))?(?:#(.*))?";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:url];
}

@end