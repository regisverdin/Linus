//
//  TimelineModel.m
//  Linus
//
//  Created by Regis Verdin on 3/7/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "TimelineModel.h"
#import "TimePoint.h"
#import <SpriteKit/SpriteKit.h>

@interface TimelineModel ()

@property NSMutableArray *events;

@end


@implementation TimelineModel

- (id)init {
    self = [super init];
    if (self != nil) {
        self.events = [[NSMutableArray alloc] init];
        self.length = self.events.count;
    }
    return self;
}


- (void) storeTimePointWithLocation:(float)loc withWindowWidth:(float)win withScreenTime:(double)screenT withTimeOffset:(double)tOffset withAmplitude:(float)amp fromNode:(SKSpriteNode*)n {
    //TODO: find correct insertion position in array (keep array sorted).
    
    
    //Make new TimePoint with these params
    TimePoint *point = [[TimePoint alloc] init];
    
    point.amplitude = amp;
    point.node = n;
    
    //Calculate time for point
    point.time = ((loc/win) * screenT) + tOffset;
    
//    NSLog(@"%f", loc);
//    NSLog(@"%f", win);
//    NSLog(@"%f", screenT);
//    NSLog(@"%f", tOffset);
//    NSLog(@"%f", amp);
    
    //Insert into event array
    int i = [self findInsertionIndex:point.time];
    if(i)
    [self.events insertObject:point atIndex:i];
    self.length++;
    
    
    for(TimePoint *tp in self.events) {
        float a = [tp time];
        NSLog(@"%f", a);
    }
    
    
}

- (int) findInsertionIndex:(float)t {
    //RETURNS AN INDEX FOR TIMEPOINT TO BE INSERTED BEFORE (i.e. shift everything from index to end right, insert timepoint at index)
    
    if(self.length == 0) return 0;
    
    //Sorted insert, using bisection
    int i = 0;
    int start = 0;
    int end = self.length - 1;
    int midPoint;

    while(i < self.length){
        midPoint = (start+end)/2;
        float midPointTime = [[self.events objectAtIndex:i] time];
        
        if(midPointTime < t) {
            start = midPointTime;
        } else {
            end = midPointTime;
        }
        
        if(end-start <= 1) {
            if(t > end) return end + 1; // edge case
            else return end;
        }
        i++;
    }
    
    return -1;
}


@end
