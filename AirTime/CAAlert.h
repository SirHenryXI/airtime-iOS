//
//  CAAlert.h
//  AirTime
//
//  Created by Chase Acton on 11/19/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAAlert : NSObject

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (void)requestFailedAlert;

@end