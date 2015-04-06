//
//  CAStopwatch.h
//  Chrometa
//
//  Created by Chase Acton on 10/15/14.
//  Copyright (c) 2014 Chrometa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAStopwatch : NSObject{
    
    NSTimeInterval startTime, elapsed;
    bool running;
    
}

+ (id)sharedInstance;

- (void)reset;
- (void)startPause;
- (void)pause;
- (NSTimeInterval)runningTime;
- (BOOL)isRunning;

@end