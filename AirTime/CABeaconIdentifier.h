//
//  CABeaconIdentifier.h
//  AirTime
//
//  Created by Chase Acton on 11/21/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CABeaconIdentifier : NSObject

+ (NSString *)majorNameForBeacon:(CLBeacon *)beacon;
+ (NSString *)minorNameForBeacon:(CLBeacon *)beacon;

@end