//
//  Project.h
//  AirTime
//
//  Created by Chase Acton on 11/12/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Project : NSObject <NSCoding>

@property (nonatomic, retain) NSString *projectID, *name, *client;
@property (nonatomic, assign) BOOL active;

@end