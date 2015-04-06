//
//  Entry.h
//  AirTime
//
//  Created by Chase Acton on 11/12/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Entry : NSObject

@property (nonatomic, retain) NSString *entryID, *project, *task, *client, *hours, *date;

@end