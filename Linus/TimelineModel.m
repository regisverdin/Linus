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
#import "TimelineScene.h"

@interface TimelineModel ()

@property NSMutableArray *tracks;   //holds all tracks (which contain arrays of timepoints)

@end

static int selectedClipNumber;

@implementation TimelineModel


+ (void) setSelectedClipNumber:(int)clip {
    selectedClipNumber = clip;
}




- (id)init {
    self = [super init];
    
    selectedClipNumber = 1;
    
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


- (void) storeTimePointWithLocation:(float)loc amplitude:(float)amp node:(SKSpriteNode*)n{
    float win = [TimelineScene getWindowWidth];
    float screenT = [TimelineScene getScreenTime];
    double tOffset = [TimelineScene getTimeOffset];
    
    double timeOfTouchLocation = ((loc/win) * screenT) + tOffset;
    
    //Get track number
    int trackIndex = (int)[[n.parent.name substringWithRange:NSMakeRange(5, 1)] integerValue];
//    NSLog(@"parentname%@", n.parent.name);
    
    //Access trackmodel
    TrackModel *track = [self.tracks objectAtIndex:trackIndex]; //(need to handle "too many tracks" error somewhere)
    
    //call "addTimePoint" on correct trackModel.
    [track addTimePointWithTime:timeOfTouchLocation amplitude:amp node:n];
//    NSLog(@"added to track %i", trackIndex);
   
}

- (void) addClipToTrack:(int)trackNum atIndex:(int)index{
    
    TrackModel *track = [self.tracks objectAtIndex:trackNum];
    [track addClip:selectedClipNumber atIndex:index];
}

- (NSMutableArray*)getNearestNodes:(CGPoint)touchLocation onTrack:(int)trackNum{
    float win = [TimelineScene getWindowWidth];
    float screenT = [TimelineScene getScreenTime];
    double tOffset = [TimelineScene getTimeOffset];
    
    double timeOfTouchLocation = ((touchLocation.x/win) * screenT) + tOffset;
    
    NSMutableArray *nodesAndIndices;
    nodesAndIndices = [[self.tracks objectAtIndex:trackNum] getNearestNodesAndIndices:timeOfTouchLocation];
    
    return nodesAndIndices;
}



@end
