//
//  Account.m
//  AirTime
//
//  Created by Chase Acton on 11/20/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import "Account.h"
#import "SSKeychain.h"

@implementation Account

+ (NSString *)username{
    //Return user's email address from NSUserDefaults
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"HarvestEmail"];
}

+ (NSString *)password{
    //cub+aPruce6apEcujed=
    //Use the saved email address from NSUserDefaults to query keychain for the password
    return [SSKeychain passwordForService:@"Harvest" account:[self username]];
}

+ (BOOL)exists{
    //Check NSUserDefaults to see if we've stored an email address before. If so, a saved used exists
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HarvestEmail"]){
        return TRUE;
    }
    return FALSE;
}

+ (void)signOut{
    //Remove saved password from Keychain
    [SSKeychain deletePasswordForService:@"Harvest" account:[self username]];

    //Remove saved username from NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HarvestEmail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)harvestUserID{
    return nil;
}

+ (BOOL)autoLogin{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"autoLogin"];
}

+ (void)toggleAutoLogin{
    [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:@"autoLogin"] forKey:@"autoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"%@",[self autoLogin] ? @"On" : @"Off");
}

@end