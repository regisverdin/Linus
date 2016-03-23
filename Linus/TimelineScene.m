//
//  TimelineScene.m
//  Linus
//
//  Created by Regis Verdin on 2/17/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "TimelineScene.h"
#import "TimelineModel.h"

@interface TimelineScene ()

@property BOOL contentCreated;
@property CGFloat gridMarkerHeight;
@property TimelineModel *timelineModel;
@property CGRect windowRect;
@property CGFloat windowHeight;
@property CGFloat windowWidth;
@property CGFloat trackWidth;
@property CGFloat trackInfoWidth;
@property CGFloat trackHeight;
@property NSMutableArray *tracks;
@property int numTracks;

@end

@implementation TimelineScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.tracks = [[NSMutableArray alloc] initWithCapacity:16];
        self.numTracks = 2;
        
        self.backgroundColor = [SKColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.0];
        self.gridMarkerHeight = 50;
        self.screenTime = 5.0;  //screen (without scrolling or zooming) is 5 seconds long.
        self.timelineModel = [[TimelineModel alloc] init]; //This is the data structure for storing each timepoint on timeline.
        
    }
    return self;
}

- (void)didMoveToView: (SKView *) view {
    
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents {
    // Get window size (move to initwithsize?)
    self.windowRect = super.view.frame;
    self.windowWidth = self.windowRect.size.width;
    self.windowHeight = self.windowRect.size.height;
    self.trackWidth = self.windowWidth * 0.9;
    self.trackInfoWidth = self.windowWidth * 0.1;
    self.trackHeight = self.windowHeight / 2.0;
    
    
    //ADD TRACKS
    for (int i = 0; i < self.numTracks; i++) {
        
        // Add a track (each track is a parent node for its contents) to track array.
        SKSpriteNode *trackNode = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(self.trackWidth, 4)];
        trackNode.anchorPoint = CGPointMake(0,0);
        trackNode.position = CGPointMake(self.trackInfoWidth, self.windowHeight - (self.trackHeight * (i+1)) );
        [self addChild:trackNode];
        self.tracks[i] = trackNode;
        
        //Add playhead at 0 time on each track.
        SKSpriteNode *playhead = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(1, self.trackHeight)];
        playhead.anchorPoint = CGPointMake(0,0);
        playhead.position = CGPointMake(0,0);
        [self.tracks[i] addChild:playhead];
        
        //Add rectangular nodes for detecting touch on a track
        SKSpriteNode *trackTouchNode = [[SKSpriteNode alloc] initWithColor:[SKColor orangeColor] size:CGSizeMake(self.trackWidth, self.trackHeight * 0.75)];
        trackTouchNode.anchorPoint = CGPointMake(0,0);
        trackTouchNode.position = CGPointMake(0, 0);
        trackTouchNode.zPosition = -1;
        NSString *trackName = [NSString stringWithFormat:@"track%i", i];
        trackTouchNode.name = trackName;
        [self.tracks[i] addChild:trackTouchNode];
    }

}


- (SKSpriteNode *)newGridMarker {
    
    SKSpriteNode *gridMarker = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(2, self.gridMarkerHeight)];
    return gridMarker;
}



- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event {

}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:touchLocation];
    
    //use regex to determine if name==track + num
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"track\\d" options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (node.name) {
        
        NSRange range = NSMakeRange(0, [node.name length]);
        Boolean  matches = [regex numberOfMatchesInString:node.name options:0 range:range] > 0;
        NSLog(@"%i", matches);
        if(matches == 1){
                //get track number
//            NSString * trackNum = [node.name substringWithRange:NSMakeRange(5, 1)];
//            int trackInt = [trackNum integerValue];
//            NSLog(@"%i", trackInt);
            
            //Add grid marker to correct track
            CGPoint nodeTouchLocation = [touch locationInNode:node];
            CGPoint markerLocation  = CGPointMake(nodeTouchLocation.x, 0);
            int markerHeight = MAX(self.trackHeight*0.2, nodeTouchLocation.y);
            SKSpriteNode *gridMarker = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(2, markerHeight)];
            gridMarker.anchorPoint = CGPointMake(0,0);
            gridMarker.position = markerLocation;
            [node addChild:gridMarker];
            
            
            //Store timepoint and node in array
            double amplitude = self.trackHeight*0.2
            [self.timelineModel storeTimePointWithLocation:touchLocation.x withWindowWidth:self.windowWidth withScreenTime:self.screenTime withTimeOffset:self.timeOffset withAmplitude:amplitude fromNode:gridMarker];

        }
    }
    
    
//    
//    // Get touch location
//    UITouch *touch = [touches anyObject];
//    CGPoint touchLocation = [touch locationInNode:self];
//    CGPoint markerLocation  = CGPointMake(touchLocation.x, 0);
//    self.gridMarkerHeight = touchLocation.y * 2;    //Awkward, but *2 because position is based on center of sprite.
//    double amplitude = (touchLocation.y / self.windowHeight) * 2;
//    
//    NSLog(@"x: %f", touchLocation.x);
//    NSLog(@"y: %f", touchLocation.y);
//    
//    //Add sprite node
//    SKSpriteNode *gridMarker = [self newGridMarker];
//    gridMarker.position = markerLocation;
//    [self addChild:gridMarker];
//    
//    
//    //Store timepoint and node in array
//    [self.timelineModel storeTimePointWithLocation:touchLocation.x withWindowWidth:self.windowWidth withScreenTime:self.screenTime withTimeOffset:self.timeOffset withAmplitude:amplitude fromNode:gridMarker];
//    
    
//     print length
//    NSLog(@"%i", self.timelineModel.length);
    
}



//- (void)updateSceneContents:(NSMutableArray *) timeline{
//    
//    //Based on start time of current view, change position of sprites. also...add or delete sprites from tree (is this necessary? save for later, with a check for ranges)
//    for(int i = 0; i <= self.timelineModel.length; i++) {
//        //get sprite position
//        
//        break;
//    }
//}


- (void)updateSceneTime: (double) time {
    //change the scenes time properties,
}





@end