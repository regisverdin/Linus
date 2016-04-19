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
#import "TheAmazingAudioEngine.h"

@interface TimelineModel ()

@property NSMutableArray *tracks;   //holds all tracks (which contain arrays of timepoints)

@end

static int selectedClipNumber;

@implementation TimelineModel


+ (void) setSelectedClipNumber:(int)clip {
    selectedClipNumber = clip;
}

+ (int) getSelectedClipNumber {
    return selectedClipNumber;
}



- (id)init {
    self = [super init];
    
    selectedClipNumber = 1;
    
    if (self != nil) {
        self.tracks = [[NSMutableArray alloc] initWithCapacity: 50];
        
        //ADD TWO TRACKS TO ARRAY (this is temp for testing)
        for (int i =0; i < 2; i++){
            TrackModel *track = [[TrackModel alloc] init];
            track.trackNum = i;
            [self.tracks insertObject:track atIndex:i];
        }
        
        
        //Setup Audio Controller
        @try {
            self.audioController = [[AudioController alloc] init];
//            [self.audioController start:NULL];
        }
        @catch (NSException *exception){
            NSLog(@"Audio not available!");
        }
        

    }
    return self;
}


- (void) storeTimePointWithLocation:(float)loc amplitude:(float)amp node:(SKSpriteNode*)n{
    float trackWidth = [TimelineScene getTrackWidth];
    float screenT = [TimelineScene getScreenTime];
    double tOffset = [TimelineScene getTimeOffset];
    
    double timeOfTouchLocation = ((loc/trackWidth) * screenT) + tOffset;
    
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
    
    
    //Update Audio Buffers (for all tracks)
    [_audioController updateAudioSchedule:_tracks];

//    int trackCounter = 0;
//    for (TrackModel *currentTrack in self.tracks) {
//        
//        NSMutableArray *trackEvents = [currentTrack getTrackEvents];
//        
//        //Pass each track model to the audio controller
//        [_audioController updateAudioSchedule:trackEvents forTrack:trackCounter];
//        trackCounter++;
//    }
}

- (NSMutableArray*)getNearestNodes:(CGPoint)touchLocation onTrack:(int)trackNum{
    float trackWidth = [TimelineScene getTrackWidth];
    float screenT = [TimelineScene getScreenTime];
    double tOffset = [TimelineScene getTimeOffset];
    
    double timeOfTouchLocation = ((touchLocation.x/trackWidth) * screenT) + tOffset;
    
    NSMutableArray *nodesAndIndices = [[self.tracks objectAtIndex:trackNum] getNearestNodesAndIndices:timeOfTouchLocation];
    
    return nodesAndIndices;
}

@end
