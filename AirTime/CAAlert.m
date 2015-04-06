//
//  CAAlert.m
//  AirTime
//
//  Created by Chase Acton on 11/19/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import "CAAlert.h"
#import <UIKit/UIKit.h>

@implementation CAAlert

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}

+ (void)requestFailedAlert{
    //Alert to be displayed when a network request fails
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not retrieve data from server. Please try again." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}

@end