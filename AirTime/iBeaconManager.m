//
//  iBeaconManager.m
//  AirTime
//
//  Created by Chase Acton on 11/19/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import "iBeaconManager.h"
#import <UIKit/UIKit.h>
#import "CAStopwatch.h"
#import "Constants.h"
#import "CABeaconIdentifier.h"
#import "NSDate+Utilities.h"

@implementation iBeaconManager
@synthesize locationManager, lastProximity, beaconsFound, bluetoothManager;

#pragma mark - Set Up Singleton -

+ (id)sharedInstance {
    static iBeaconManager *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (id)init{
    self = [super init];
    if (self != nil){
        NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:kBeaconUUID];
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:@"AirTimeBeacons"];
        
        self.locationManager = [[CLLocationManager alloc] init];
        
        //iOS 8 request for Always Authorization, required for iBeacons to work!
        if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        self.locationManager.delegate = self;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        [self.locationManager startMonitoringForRegion:beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
        [self.locationManager startUpdatingLocation];
        [self detectBluetooth];
    }
    return self;
}

- (void)detectBluetooth{
    if(!self.bluetoothManager){
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
}

- (BOOL)bluetoothOn{
    switch(bluetoothManager.state){
        case CBCentralManagerStateResetting: return FALSE; break;
        case CBCentralManagerStateUnsupported: return FALSE; break;
        case CBCentralManagerStateUnauthorized: return FALSE; break;
        case CBCentralManagerStatePoweredOff: return FALSE; break;
        case CBCentralManagerStatePoweredOn: return TRUE; break;
        default: return FALSE; break;
    }
}

-(void)sendNotification:(NSString*)message{
    NSLog(@"Notification: %@",message);
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = message;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    self.beaconsFound = beacons;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"beaconsFound" object:self];
    
    NSInteger lastBeaconCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastBeaconCount"];
    NSLog(@"Beacon Count Now: %zd, Last: %zd",beacons.count,lastBeaconCount);
    
    if(beacons.count > 0){
        //        NSLog(@"did detect beacon");
        if (lastBeaconCount == 0){
            //User entered beacon range
            
            //Check when user last entered range
            NSDate *dateLastEntered = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastEntered"];
            if ([dateLastEntered isToday]){
                //Intraday arrival
                //User has already been within range of beacons today
                if ([[CAStopwatch sharedInstance] isRunning]){
                    //User left office with timer running
                    [self sendNotification:@"Back from a meeting? Record your notes, your timer is still going."];
                }else{
                    //User returned to office during the day
                    [self sendNotification:@"Back from lunch? Open to start a recent timer"];
                }
            }else{
                //Initial arrival
                if ([[CAStopwatch sharedInstance] isRunning]){
                    //Timer is running, they must have left it on overnight
                    [self sendNotification:@"Did you pull an all-nighter or just forget to stop your timer?"];
                }else{
                    //First time entering beacon range for the day
                    [self sendNotification:@"Welcome to the office. Open to start a timer."];
                }
            }
            
            //Log last time user entered beacon range
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastEntered"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
        CLBeacon *nearestBeacon = beacons.firstObject;
        if(nearestBeacon.proximity == self.lastProximity ||
           nearestBeacon.proximity == CLProximityUnknown) {
            //            return;
        }
        self.lastProximity = nearestBeacon.proximity;
        
        /*
         Immediate: Within a few centimeters
         Near: Within a couple of meters
         Far: Greater than 10 meters away
         */
    } else{
        if (lastBeaconCount > 0){
            //User left range of beacons
            if ([[CAStopwatch sharedInstance] isRunning]){
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"departureTime"]){
                    
                    //Current time
                    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
                    NSDate *now = [[NSCalendar currentCalendar] dateFromComponents:components];
                    
                    //Departure time
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"hh:mm a"];
                    NSDate *departureTimeRaw = [[NSUserDefaults standardUserDefaults] objectForKey:@"departureTime"];
                    NSString *ccc = [dateFormatter stringFromDate:departureTimeRaw];
                    NSDate *departureTime = [dateFormatter dateFromString:ccc];
                    departureTime = [departureTime dateByAddingMinutes:30]; //30 minute window from departure time
                    
                    //Compare time components only
                    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:departureTime];
                    NSDate *dateTwo = [[NSCalendar currentCalendar] dateFromComponents:components2];
                    NSLog(@"now: %@ departure: %@",[now description], [dateTwo description]);
                    
                    NSInteger hour1 = [components hour];
                    NSInteger minute1 = [components minute];
                    //now1: 18:53 now2: 15:31
                    NSInteger hour2 = [components2 hour];
                    NSInteger minute2 = [components2 minute];
                    
                    if (hour1 > hour2){
                        [self sendNotification:@"Finished for the day? Turn off your active timer."];
                    }else if (hour1 < hour2){
                        [self sendNotification:@"Going to Lunch or a Meeting? Stop or switch timers."];
                    }else if (hour1 == hour2){
                        if (minute1 > minute2){
                            [self sendNotification:@"Finished for the day? Turn off your active timer."];
                        }else{
                            [self sendNotification:@"Going to Lunch or a Meeting? Stop or switch timers."];
                        }
                    }else{
                        //Something went really, really wrong
                    }
                    
                    NSLog(@"now1: %i:%i now2: %i:%i",hour1,minute1,hour2,minute2);
                }else{
                    //No departure saved, so assume this is their first time leaving
                    [self sendNotification:@"Going to Lunch or a Meeting? Stop or switch timers."];
                }
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:beacons.count forKey:@"lastBeaconCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)locationsNearby{
    NSMutableString *locationsMutableString = [NSMutableString new];
    for (CLBeacon *beacon in self.beaconsFound){
        if (beacon.proximity == CLProximityNear || beacon.proximity == CLProximityImmediate){
            [locationsMutableString appendString:[NSString stringWithFormat:@"%@, ",[CABeaconIdentifier minorNameForBeacon:beacon]]];
        }
    }
    if ([[locationsMutableString copy] length] > 0){
        return [NSString stringWithFormat:@"Location: %@",[[locationsMutableString copy] substringToIndex:locationsMutableString.length-2]];
    }else{
        return @"No Beacons Nearby";
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [self.locationManager startUpdatingLocation];
    
    NSLog(@"You entered the beacon region");
    
    
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    //    [manager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    //    [self.locationManager stopUpdatingLocation];
    
    NSLog(@"You exited the region.");
    //    [self sendNotification:@"You exited the region."];
}

@end