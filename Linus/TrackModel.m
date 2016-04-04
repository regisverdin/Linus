//
//  TrackModel.m
//  Linus
//
//  Created by Regis Verdin on 3/23/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//
//  Holds a single array of timepoints for a track

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

- (void)addTimePointWithTime:(double)t amplitude:(double)amp node:(SKSpriteNode*)n {
    
    //Make new TimePoint with these params
    TimePoint *point = [[TimePoint alloc] init];
    point.amplitude = amp;
    point.node = n;
    point.time = t;

    //Insert into event array
    int i = [self findInsertionIndex:point.time];
    NSLog(@"Insertion Index : %i", i);
    [self.trackEvents insertObject:point atIndex:i];

    for(TimePoint *tp in self.trackEvents) {
        float a = [tp time];
        NSLog(@"%f", a);
    }
}

- (void)addClip:(int)clipNum atIndex:(int)index{
    TimePoint *tp = [self.trackEvents objectAtIndex:index];
    tp.clipNumber = clipNum;
}


- (NSMutableArray*) getNearestNodesAndIndices:(double)time {

    int leftIndex = [self findInsertionIndex:time];
    SKNode *leftNode = [[self.trackEvents objectAtIndex:leftIndex] node];
    
    NSMutableArray *nodesAndIndices = [[NSMutableArray alloc] initWithCapacity: 2];
    NSMutableArray *leftNodeAndIndex = [[NSMutableArray alloc] initWithObjects:leftNode, [NSNumber numberWithInt:leftIndex], nil];  //using nsnumber because nsarray can't hold primitive types
    [nodesAndIndices insertObject:leftNodeAndIndex atIndex:0];
    
    if(leftIndex != self.trackEvents.count) {   //Check if a right node exists (i.e. we aren't at end of timepoint array)
        int rightIndex = leftIndex + 1;
        SKNode *rightNode = [[self.trackEvents objectAtIndex:rightIndex] node];
        NSMutableArray *rightNodeAndIndex = [[NSMutableArray alloc] initWithObjects:rightNode, [NSNumber numberWithInt:rightIndex], nil];
        [nodesAndIndices insertObject:rightNodeAndIndex atIndex:1];
    }
    
    return nodesAndIndices;
}


- (int) findInsertionIndex:(float)insertionTime{
    //RETURNS AN INDEX FOR TIMEPOINT TO BE INSERTED BEFORE (i.e. shift everything from index to end right, insert timepoint at index)
    
    int len = (int)[self.trackEvents count];
    
    if(len == 0) return 0;
    if([[self.trackEvents objectAtIndex:0] time] > insertionTime) {  //edge case for adding to front of array (lazy fix for alg below?)
        return 0;
    }
    
    //Sorted insert, using bisection
    int i = 0;
    int start = 0;
    int end = len - 1;
    int midPoint;
    float midPointTime;
    
    while(i < len){
        midPoint = (start+end)/2;
        midPointTime = [[self.trackEvents objectAtIndex:midPoint] time];
        
        if(midPointTime < insertionTime) {
            start = midPoint;
        } else {
            end = midPoint;
        }
        
        if(end-start <= 1) {
            float endTime = [[self.trackEvents objectAtIndex:end] time];
            if(insertionTime > endTime) return end + 1; // edge case for adding to end of array
            else return end;
        }
        i++;
    }
    
    return -1;
}




@end
