//
//  BeaconWebServices.h
//  AirTime
//
//  Created by Chase Acton on 11/21/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconWebServices : NSObject

+ (id)sharedInstance;

-(void)getKnownBeacons:(void (^)(BOOL success)) block;

@property (nonatomic, retain) NSArray *knownBeacons;

@end