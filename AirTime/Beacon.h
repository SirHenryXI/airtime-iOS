//
//  Beacon.h
//  AirTime
//
//  Created by Chase Acton on 11/21/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Beacon : NSObject

@property (nonatomic, retain) NSString *uuid, *major_name, *minor_name;
@property (nonatomic, assign) NSInteger major, minor;

@end