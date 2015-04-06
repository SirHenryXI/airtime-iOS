//
//  Task.m
//  AirTime
//
//  Created by Chase Acton on 11/12/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import "Task.h"

@implementation Task

@synthesize taskID, name;

-(id)initWithCoder:(NSCoder *)decoder {
    self.taskID = [decoder decodeObjectForKey:@"taskID"];
    self.name = [decoder decodeObjectForKey:@"name"];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.taskID forKey:@"taskID"];
    [coder encodeObject:self.name forKey:@"name"];
}

@end