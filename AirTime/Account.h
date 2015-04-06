//
//  Account.h
//  AirTime
//
//  Created by Chase Acton on 11/20/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

+ (NSString *)username;
+ (NSString *)password;
+ (NSString *)harvestUserID;

+ (BOOL)exists;
+ (BOOL)autoLogin;

+ (void)signOut;
+ (void)toggleAutoLogin;

@end