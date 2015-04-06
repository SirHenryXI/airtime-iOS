//
//  BeaconWebServices.m
//  AirTime
//
//  Created by Chase Acton on 11/21/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import "BeaconWebServices.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "Beacon.h"
#import "Account.h"

@implementation BeaconWebServices
@synthesize knownBeacons;

#pragma mark - Set Up Singleton -

+ (id)sharedInstance {
    static BeaconWebServices *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (id)init{
    self = [super init];
    if (self != nil){
    }
    return self;
}

-(void)getKnownBeacons:(void (^)(BOOL success)) block{
    NSString *endpoint = [NSString stringWithFormat:@"/beacons/%@",kBeaconUUID];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kBeaconAPIEndpoint,endpoint];
    NSLog(@"getKnownBeacons: %@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:[Account username] password:[Account password]];
    [manager.requestSerializer setValue:kAPIToken forHTTPHeaderField:@"X-Airtime-Token"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
//                        NSLog(@"getKnownBeacons: %@",JSON);
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSDictionary *beaconsDict in [JSON objectForKey:@"beacons"]){
            Beacon *beacon = [[Beacon alloc] init];
            beacon.uuid = [NSString stringWithFormat:@"%@",[beaconsDict objectForKey:@"uuid"]];
            beacon.major_name = [NSString stringWithFormat:@"%@",[beaconsDict objectForKey:@"major_name"]];
            beacon.minor_name = [NSString stringWithFormat:@"%@",[beaconsDict objectForKey:@"minor_name"]];
            beacon.major =  [[beaconsDict objectForKey:@"major"] integerValue];
            beacon.minor =  [[beaconsDict objectForKey:@"minor"] integerValue];
            [tempArray addObject:beacon];
        }
        self.knownBeacons = [[NSArray alloc] initWithArray:tempArray];
        block(TRUE);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        block(FALSE);
    }];
}

@end