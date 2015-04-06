//
//  CAStopwatch.m
//  Chrometa
//
//  Created by Chase Acton on 10/15/14.
//  Copyright (c) 2014 Chrometa. All rights reserved.
//

#import "CAStopwatch.h"

@implementation CAStopwatch

+ (id)sharedInstance {
    static CAStopwatch *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (id)init{
    self = [super init];
    if (self != nil){
        running = FALSE;
        elapsed = 0;
        startTime = 0;
    }
    return self;
}

#pragma mark - Stopwatch -

- (void)reset{
    running = FALSE;
    elapsed = 0;
}

- (void)startPause{
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    if (running == FALSE){
        startTime = currentTime;
    }else{
        elapsed += (currentTime - startTime);
    }
    running = !running;
}

- (void)pause{
    //Called when out of range of iBeacons
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    elapsed += (currentTime - startTime);
    running = FALSE;
}

- (NSTimeInterval)runningTime{
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval totalTime = (currentTime - startTime) + elapsed;
    return totalTime;
}

- (BOOL)isRunning{
    return running;
}

@end