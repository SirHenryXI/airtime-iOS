//
//  CABeaconIdentifier.m
//  AirTime
//
//  Created by Chase Acton on 11/21/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import "CABeaconIdentifier.h"
#import "BeaconWebServices.h"
#import "Beacon.h"

@implementation CABeaconIdentifier

/*
 Here, we are matches beacons the devices finds with known beacons in our database. 
 By comparing the major or minor numbers of these beacons, we can get their names as stored on our server.
 */

+ (NSString *)majorNameForBeacon:(CLBeacon *)beacon{
    BeaconWebServices *beaconWebServices = [BeaconWebServices sharedInstance];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"major == %i", beacon.major.integerValue];
    NSArray *filteredArray = [beaconWebServices.knownBeacons filteredArrayUsingPredicate:predicate];
    Beacon *firstFoundObject = nil;
    firstFoundObject =  filteredArray.count > 0 ? filteredArray.firstObject : nil;
    return firstFoundObject.major_name;
}

+ (NSString *)minorNameForBeacon:(CLBeacon *)beacon{
    BeaconWebServices *beaconWebServices = [BeaconWebServices sharedInstance];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"minor == %i", beacon.minor.integerValue];
    NSArray *filteredArray = [beaconWebServices.knownBeacons filteredArrayUsingPredicate:predicate];
    Beacon *firstFoundObject = nil;
    firstFoundObject =  filteredArray.count > 0 ? filteredArray.firstObject : nil;
    return firstFoundObject.minor_name;
}

@end