//
//  CATimeConverter.h
//  AirTime
//
//  Created by Chase Acton on 11/20/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CATimeConverter : NSObject

+ (NSString *)formatTime:(NSString *)input;
+ (NSString *)formatDate:(NSString *)input;

@end