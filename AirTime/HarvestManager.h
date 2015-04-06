//
//  HarvestManager.h
//  AirTime
//
//  Created by Chase Acton on 11/12/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Company.h"
#import "Project.h"
#import "Task.h"
#import "Timer.h"

@interface HarvestManager : NSObject{
    NSMutableArray *currentEntriesTemp;
}

+ (id)sharedInstance;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL authenticated)) block;
- (void)saveProject:(Project *)project;
- (void)saveTask:(Task *)task;
- (void)addTimer:(Timer *)timer completion:(void (^)(BOOL success)) block;
- (void)batch:(void (^)(BOOL success)) block;

@property (nonatomic, retain) NSArray *currentProjects, *currentTasks, *currentEntries;

@property (nonatomic, retain) Company *currentCompany;
@property (nonatomic, retain) User *currentUser;
@property (nonatomic, retain) Project *currentProject;
@property (nonatomic, retain) Task *currentTask;
@property (nonatomic, retain) Timer *runningTimer;

@end