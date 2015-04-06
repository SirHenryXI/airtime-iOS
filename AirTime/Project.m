//
//  Project.m
//  AirTime
//
//  Created by Chase Acton on 11/12/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import "Project.h"

@implementation Project

@synthesize projectID, name, active, client;

-(id)initWithCoder:(NSCoder *)decoder {
    self.projectID = [decoder decodeObjectForKey:@"projectID"];
    self.name = [decoder decodeObjectForKey:@"name"];
    self.client = [decoder decodeObjectForKey:@"client"];
    self.active = [decoder decodeBoolForKey:@"active"];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.projectID forKey:@"projectID"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.client forKey:@"client"];
    [coder encodeBool:self.active forKey:@"active"];
}

@end