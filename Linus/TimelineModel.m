//
//  TimelineModel.m
//  Linus
//
//  Created by Regis Verdin on 3/7/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "TimelineModel.h"
#import "TimePoint.h"
#import "TrackModel.h"
#import <SpriteKit/SpriteKit.h>

@interface TimelineModel ()

@property NSMutableArray *tracks;   //holds all tracks (which contain arrays of timepoints)

@end


@implementation TimelineModel

- (id)init {
    self = [super init];
    if (self != nil) {
        self.tracks = [[NSMutableArray alloc] initWithCapacity: 50];
        
        //ADD TWO TRACKS TO ARRAY (this is temp for testing)
        for (int i =0; i < 2; i++){
            TrackModel *track = [[TrackModel alloc] init];
            [self.tracks insertObject:track atIndex:i];
        }
        
    }
    return self;
}


- (void) storeTimePointWithLocation:(float)loc withWindowWidth:(float)win withScreenTime:(double)screenT withTimeOffset:(double)tOffset withAmplitude:(float)amp fromNode:(SKSpriteNode*)n{
    
    //Get track number
    int trackIndex = (int)[[n.parent.name substringWithRange:NSMakeRange(5, 1)] integerValue];
    NSLog(@"parentname%@", n.parent.name);
    
    //Access trackmodel
    TrackModel *track = [self.tracks objectAtIndex:trackIndex]; //(need to handle "too many tracks" error somewhere)
    
    //call "addTimePoint" on correct trackModel.
    [track addTimePointWithLocation:loc windowWidth:win screenTime:screenT timeOffset:tOffset amplitude:amp node:n];
    NSLog(@"added to track %i", trackIndex);
}



@end
