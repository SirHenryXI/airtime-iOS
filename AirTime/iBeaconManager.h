//
//  iBeaconManager.h
//  AirTime
//
//  Created by Chase Acton on 11/19/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface iBeaconManager : NSObject <CLLocationManagerDelegate, CBCentralManagerDelegate>

+ (id)sharedInstance;

- (NSString *)locationsNearby;
- (BOOL)bluetoothOn;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CBCentralManager *bluetoothManager;

@property CLProximity lastProximity;
@property (strong) NSArray *beaconsFound;

@end