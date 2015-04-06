//
//  Timer.h
//  AirTime
//
//  Created by Chase Acton on 11/24/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject

@property (nonatomic,retain) NSString *projectID, *taskID, *projectName, *taskName;
@property (nonatomic,retain) NSDate *date;

@end