//
//  TrackModel.m
//  Linus
//
//  Created by Regis Verdin on 3/23/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "TrackModel.h"
#import "TimePoint.h"

@interface TrackModel()

@property NSMutableArray *trackEvents;

@end

@implementation TrackModel


- (id)init {
    self = [super init];
    if (self) {
        _trackEvents = [[NSMutableArray alloc] initWithCapacity:500];
    }
    return self;
}

- (void)addTimePointWithLocation:(float)loc windowWidth:(float)win screenTime:(double)screenT timeOffset:(double)tOffset amplitude:(double)amp node:(SKSpriteNode*)n {
    
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
    NSLog(@"Insertion Index : %i", i);
    [self.tracks insertObject:point atIndex:i];
    self.length++;

    for(TimePoint *tp in self.events) {
        float a = [tp time];
        NSLog(@"%f", a);
    }
}



- (int) findInsertionIndex:(float)insertionTime{
    //RETURNS AN INDEX FOR TIMEPOINT TO BE INSERTED BEFORE (i.e. shift everything from index to end right, insert timepoint at index)
    
    if(self.length == 0) return 0;
    if([[self.events objectAtIndex:0] time] > insertionTime) {  //edge case for adding to front of array (lazy fix for alg below)
        return 0;
    }
    
    //Sorted insert, using bisection
    int i = 0;
    int start = 0;
    int end = self.length - 1;
    int midPoint;
    
    while(i < self.length){
        midPoint = (start+end)/2;
        float midPointTime = [[self.events objectAtIndex:midPoint] time];
        
        if(midPointTime < insertionTime) {
            start = midPoint;
        } else {
            end = midPoint;
        }
        
        if(end-start <= 1) {
            float endTime = [[self.events objectAtIndex:end] time];
            if(insertionTime > endTime) return end + 1; // edge case for adding to end of array
            else return end;
        }
        i++;
    }
    
    return -1;
}




@end
