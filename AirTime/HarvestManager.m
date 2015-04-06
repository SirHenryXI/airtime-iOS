//
//  HarvestManager.m
//  AirTime
//
//  Created by Chase Acton on 11/12/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import "HarvestManager.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Entry.h"
#import "Account.h"
#import "BeaconWebServices.h"
#import "CAValidator.h"
#import "NSDate+Utilities.h"
#import "AFURLRequestSerialization.h"
#import "CAAlert.h"

@implementation HarvestManager
@synthesize currentProjects, currentTasks, currentCompany, currentUser, currentProject, currentTask, currentEntries,runningTimer;

#pragma mark - Set Up Singleton -

+ (id)sharedInstance {
    static HarvestManager *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (id)init{
    self = [super init];
    if (self != nil){
        [[BeaconWebServices sharedInstance] getKnownBeacons:^(BOOL success){}];
        self.currentEntries = [[NSMutableArray alloc] init];
        currentEntriesTemp = [[NSMutableArray alloc] init];
        [self setDefaultTimes];
    }
    return self;
}

-(void)setDefaultTimes{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (![prefs objectForKey:@"arrivalTime"]){
        NSDate *today = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *weekdayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:today];
        [weekdayComponents setHour:9];
        NSDate *arrivalTime = [gregorian dateFromComponents:weekdayComponents];
        [prefs setObject:arrivalTime forKey:@"arrivalTime"];
    }
    
    if (![prefs objectForKey:@"departureTime"]){
        NSDate *today = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *weekdayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:today];
        [weekdayComponents setHour:17];
        NSDate *arrivalTime = [gregorian dateFromComponents:weekdayComponents];
        [prefs setObject:arrivalTime forKey:@"departureTime"];
    }
    
    if (![prefs objectForKey:@"lunchTime"]){
        NSDate *today = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *weekdayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:today];
        [weekdayComponents setHour:12];
        NSDate *arrivalTime = [gregorian dateFromComponents:weekdayComponents];
        [prefs setObject:arrivalTime forKey:@"lunchTime"];
    }
    
    [prefs synchronize];
}

#pragma mark - Login -

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL authenticated)) block{
    NSString *endpoint = @"/account/who_am_i";
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kWebServicesEndpoint,endpoint];
    NSLog(@"loginWithUsername: %@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        //                        NSLog(@"loginWithUsername: %@",JSON);
        
        //Save company info
        NSDictionary *companyJSON = [JSON objectForKey:@"company"];
        Company *company = [[Company alloc] init];
        company.base_uri = [NSString stringWithFormat:@"%@",[companyJSON objectForKey:@"base_uri"]];
        company.full_domain = [NSString stringWithFormat:@"%@",[companyJSON objectForKey:@"full_domain"]];
        company.name = [NSString stringWithFormat:@"%@",[companyJSON objectForKey:@"name"]];
        self.currentCompany = company;
        
        //Save user info
        NSDictionary *userJSON = [JSON objectForKey:@"user"];
        User *user = [[User alloc] init];
        
        NSString *imageURLToCheck = [NSString stringWithFormat:@"%@",[userJSON objectForKey:@"avatar_url"]];
        //If user has a default image, it will only return the URI of the URL. A custom profile image will return the full URL
        if ([CAValidator validURL:imageURLToCheck]){
            NSLog(@"valid");
            user.avatar_url = [NSString stringWithFormat:@"%@",[userJSON objectForKey:@"avatar_url"]];
        }else{
            NSLog(@"invalid");
            user.avatar_url = [NSString stringWithFormat:@"%@%@",kWebServicesEndpoint,[userJSON objectForKey:@"avatar_url"]];
        }
        
        NSLog(@"url: %@",user.avatar_url);
        
        user.email = [NSString stringWithFormat:@"%@",[userJSON objectForKey:@"email"]];
        user.first_name = [NSString stringWithFormat:@"%@",[userJSON objectForKey:@"first_name"]];
        user.last_name = [NSString stringWithFormat:@"%@",[userJSON objectForKey:@"last_name"]];
        user.userID = [NSString stringWithFormat:@"%@",[userJSON objectForKey:@"userID"]];
        self.currentUser = user;
        block(TRUE);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        block(FALSE);
    }];
}

#pragma mark - Recent Events -

-(void)batch:(void (^)(BOOL success)) block{
    [currentEntriesTemp removeAllObjects];
    
    // Create a dispatch group
    dispatch_group_t group = dispatch_group_create();
    
    // Enter the group for each request we create
    dispatch_group_enter(group);
    [self getEntriesForDay:[[NSDate date] dayInYear] completion:^(BOOL success) {
        if (success){
            dispatch_group_leave(group);
        }else{
            [CAAlert requestFailedAlert];
            dispatch_group_leave(group);
            block(false);
        }
    }];
    
    dispatch_group_enter(group);
    [self getEntriesForDay:[[NSDate date] dayInYear]-1 completion:^(BOOL success) {
        if (success){
            dispatch_group_leave(group);
        }else{
            [CAAlert requestFailedAlert];
            dispatch_group_leave(group);
            block(false);
        }
    }];
    
    dispatch_group_enter(group);
    [self getEntriesForDay:[[NSDate date] dayInYear]-2 completion:^(BOOL success) {
        if (success){
            dispatch_group_leave(group);
        }else{
            [CAAlert requestFailedAlert];
            dispatch_group_leave(group);
            block(false);
        }
    }];
    
    dispatch_group_enter(group);
    [self getEntriesForDay:[[NSDate date] dayInYear]-3 completion:^(BOOL success) {
        if (success){
            dispatch_group_leave(group);
        }else{
            [CAAlert requestFailedAlert];
            dispatch_group_leave(group);
            block(false);
        }
    }];
    
    dispatch_group_enter(group);
    [self getEntriesForDay:[[NSDate date] dayInYear]-4 completion:^(BOOL success) {
        if (success){
            dispatch_group_leave(group);
        }else{
            [CAAlert requestFailedAlert];
            dispatch_group_leave(group);
            block(false);
        }
    }];
    
    dispatch_group_enter(group);
    [self getEntriesForDay:[[NSDate date] dayInYear]-5 completion:^(BOOL success) {
        if (success){
            dispatch_group_leave(group);
        }else{
            [CAAlert requestFailedAlert];
            dispatch_group_leave(group);
            block(false);
        }
    }];
    
    dispatch_group_enter(group);
    [self getEntriesForDay:[[NSDate date] dayInYear]-6 completion:^(BOOL success) {
        if (success){
            dispatch_group_leave(group);
        }else{
            [CAAlert requestFailedAlert];
            dispatch_group_leave(group);
            block(false);
        }
    }];
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //Sort entries by date descending
        NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:FALSE];
        [currentEntriesTemp sortUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
        self.currentEntries = [[NSArray alloc] initWithArray:currentEntriesTemp];
        block(TRUE);
    });
}

- (void)getEntriesForDay:(NSInteger)day completion:(void (^)(BOOL success)) block{
    NSString *endpoint = [NSString stringWithFormat:@"/daily/%zd/%zd", day,[[NSDate date] year]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kWebServicesEndpoint,endpoint];
    NSLog(@"getRecentEntries: %@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:[Account username] password:[Account password]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        //NSLog(@"getRecentEntries: %@",JSON);
        NSArray *entries = [JSON objectForKey:@"day_entries"];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
        //Get Entries
        for (NSDictionary *entryDict in entries){
            Entry *entry = [[Entry alloc] init];
            entry.entryID = [NSString stringWithFormat:@"%@",[entryDict objectForKey:@"id"]];
            entry.project = [NSString stringWithFormat:@"%@",[entryDict objectForKey:@"project"]];
            entry.task = [NSString stringWithFormat:@"%@",[entryDict objectForKey:@"task"]];
            entry.client = [NSString stringWithFormat:@"%@",[entryDict objectForKey:@"client"]];
            entry.hours = [NSString stringWithFormat:@"%@",[entryDict objectForKey:@"hours"]];
            entry.date = [NSString stringWithFormat:@"%@",[entryDict objectForKey:@"spent_at"]];
            [tempArray addObject:entry];
        }
        
        NSMutableArray *tempArrayProjects = [[NSMutableArray alloc] init];
        
        //Get Projects
        NSArray *projects = [JSON objectForKey:@"projects"];
        for (NSDictionary *projectDict in projects){
//            NSLog(@"%@",projectDict);
            Project *project = [[Project alloc] init];
            project.projectID = [NSString stringWithFormat:@"%@",[projectDict objectForKey:@"id"]];
            project.name = [NSString stringWithFormat:@"%@",[projectDict objectForKey:@"name"]];
            project.client = [NSString stringWithFormat:@"%@",[projectDict objectForKey:@"client"]];
            [tempArrayProjects addObject:project];
            self.currentProjects = [[NSArray alloc] initWithArray:tempArrayProjects];
            
            //Set current project
            if ([self savedProjectExists]){
                NSString *idToCompare = [self savedProject].projectID;
                BOOL containsObject = FALSE;
                for (Project *project in self.currentProjects){
                    if ([project.projectID isEqualToString:idToCompare]){
                        containsObject = TRUE;
                        break;
                    }
                }
                if (!containsObject){
                    [self saveProject:[self.currentProjects firstObject]];
                }
            }else{
                [self saveProject:[self.currentProjects firstObject]];
            }
            self.currentProject = [self savedProject];
            
            NSMutableArray *tempArrayTasks = [[NSMutableArray alloc] init];

            NSArray *tasks = [projectDict objectForKey:@"tasks"];
            //Get tasks for the project
            for (NSDictionary *taskDict in tasks){
                Task *task = [[Task alloc] init];
                task.taskID = [NSString stringWithFormat:@"%@",[taskDict objectForKey:@"id"]];
                task.name = [NSString stringWithFormat:@"%@",[taskDict objectForKey:@"name"]];
                [tempArrayTasks addObject:task];
            }
            self.currentTasks = [[NSArray alloc] initWithArray:tempArrayTasks];
            NSLog(@"tasks: %i",self.currentTasks.count);
            
            //Set current task
            if ([self savedTaskExists]){
                NSString *idToCompare = [self savedTask].taskID;
                BOOL containsObject = FALSE;
                for (Task *task in self.currentTasks){
                    if ([task.taskID isEqualToString:idToCompare]){
                        containsObject = TRUE;
                        break;
                    }
                }
                if (!containsObject){
                    [self saveTask:[self.currentTasks firstObject]];
                }
            }else{
                [self saveTask:[self.currentTasks firstObject]];
            }
            self.currentTask = [self savedTask];
        }
        block(TRUE);
        
        [currentEntriesTemp addObjectsFromArray:tempArray];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        block(FALSE);
    }];
}

#pragma mark - Projects -

-(BOOL)savedProjectExists{
    return (BOOL)[[NSUserDefaults standardUserDefaults] objectForKey:@"savedProject"];
}

- (void)saveProject:(Project *)project{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:project];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"savedProject"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.currentProject = [self savedProject];
}

- (Project *)savedProject{
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedProject"];
    Project *project = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return project;
}

#pragma mark - Tasks -

-(BOOL)savedTaskExists{
    return (BOOL)[[NSUserDefaults standardUserDefaults] objectForKey:@"savedTask"];
}

- (void)saveTask:(Task *)task{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:task];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"savedTask"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.currentTask = [self savedTask];
}

- (Task *)savedTask{
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedTask"];
    Task *task = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return task;
}

#pragma mark - Save Timer to Harvest -

- (void)addTimer:(Timer *)timer completion:(void (^)(BOOL success)) block{
    NSLog(@"addTimer");
    NSString *endpoint = @"/daily/add";
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kWebServicesEndpoint,endpoint];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:[Account username] password:[Account password]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"application/json"]];
    
    [manager POST:urlString parameters:[self jsonDict] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        block(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        block(false);
    }];
}

-(NSString *)timerDuration{
    NSDate *date1 = self.runningTimer.date;
    NSDate *date2 = [NSDate date]; //now
    NSTimeInterval interval = [date2 timeIntervalSinceDate:date1];
    int hours = (int)interval / 3600;             // integer division to get the hours part
    int minutes = (interval - (hours*3600)) / 60; // interval minus hours part (in seconds) divided by 60 yields minutes
    NSString *timeDiff;
    if (minutes < 1){
        timeDiff = @"0:01";
    }else{
        timeDiff = [NSString stringWithFormat:@"%d:%02d", hours, minutes];
    }
    return timeDiff;
}

- (NSMutableDictionary*)jsonDict{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [formatter stringFromDate:self.runningTimer.date];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    result[@"project_id"] = self.currentProject.projectID;
    result[@"task_id"] = self.currentTask.taskID;
    result[@"spent_at"] = stringFromDate;
    result[@"hours"] = [self timerDuration];
    return result;
}

@end