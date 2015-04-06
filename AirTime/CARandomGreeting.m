//
//  CARandomGreeting.m
//  AirTime
//
//  Created by Chase Acton on 11/20/14.
//  Copyright (c) 2014 Chase Acton. All rights reserved.
//

#import "CARandomGreeting.h"

@implementation CARandomGreeting

+ (NSString *)greeting{
    NSArray *greetings = [[NSArray alloc] initWithObjects:@"Aloha", @"Ahoy", @"Bonjour", @"G'day", @"Hello", @"Hey", @"Hi", @"Hola", @"Howdy", @"Sup", @"Yo", nil];
    NSUInteger randomIndex = arc4random() % [greetings count];
    return [greetings objectAtIndex:randomIndex];
}

@end