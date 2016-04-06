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
@property CGRect windowRect;
@property CGFloat windowHeight;
@property CGFloat windowWidth;
@property CGFloat trackWidth;
@property CGFloat trackInfoWidth;
@property CGFloat trackHeight;
@property CGFloat gridMarkerWidth;
@property NSMutableArray *tracks;
@property int numTracks;

@end

static int gridClipMode;
static CGFloat trackWidth;
static double screenTime;
static double timeOffset;


@implementation TimelineScene


/////Class variables (sort of...)////////

+ (void) setGridClipMode:(int) mode {
    gridClipMode = mode;
}
+ (int) getGridClipMode {
    return gridClipMode;
}

+ (float) getTrackWidth {
    return trackWidth;
}

+ (void) setTrackWidth:(float)width {
    trackWidth = width;
}

+ (double) getScreenTime {
    return screenTime;
}

+ (void) setScreenTime:(double)time {
    screenTime = time;
}

+ (double) getTimeOffset {
    return timeOffset;
}

+ (void) setTimeOffset:(double)offset {
    timeOffset = offset;
}


-(id)initWithSize:(CGSize)size {
    
    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        gridClipMode = 0; // start in grid mode
        
        self.tracks = [[NSMutableArray alloc] initWithCapacity:16];
        self.numTracks = 2;
        
        self.backgroundColor = [SKColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.0];
        self.gridMarkerHeight = 50;
        self.gridMarkerWidth = 2;
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
    [TimelineScene setScreenTime:10.0];
    [TimelineScene setTimeOffset:0.0];
    
    self.windowHeight = self.windowRect.size.height;
    self.trackWidth = self.windowWidth * 0.9;
    [TimelineScene setTrackWidth:self.trackWidth];
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
    
        //ADD GRIDMARKERS AT 0 TIME
        
    }
    
}


- (SKSpriteNode *)newGridMarker {
    
    SKSpriteNode *gridMarker = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(self.gridMarkerWidth, self.gridMarkerHeight)];
    return gridMarker;
}



- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event {

}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if(gridClipMode == 0) {
        [self addGridMarkerOnTouch:touch];
    } else {
        [self addClipOnTouch:touch];
    }
}

- (void)addGridMarkerOnTouch:(UITouch*) touch {
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:touchLocation];
    
    if ([self getNodeTrackNumber:node] != -1){
            
            //Add grid marker to correct track
            CGPoint nodeTouchLocation = [touch locationInNode:node];
            CGPoint markerLocation  = CGPointMake(nodeTouchLocation.x, 0);
            int markerHeight = MAX(self.trackHeight*0.2, nodeTouchLocation.y);
            SKSpriteNode *gridMarker = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(self.gridMarkerWidth, markerHeight)];
            gridMarker.anchorPoint = CGPointMake(0,0);
            gridMarker.position = markerLocation;
            [node addChild:gridMarker];
        
            //Store timepoint and node in timeline
            double amplitude = nodeTouchLocation.y/self.trackHeight*0.2;
            [self.timelineModel storeTimePointWithLocation:markerLocation.x amplitude:amplitude node:gridMarker];
            NSLog(@"loc: %f", markerLocation.x);
    }
}


- (void)addClipOnTouch:(UITouch*) touch {
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:touchLocation];
    
    int trackNum = [self getNodeTrackNumber:node];
    
    if (trackNum != -1){
        
        //get closest previous and next timepoint nodes to tapped location
        CGPoint touchLocation = [touch locationInNode:node];
        
        NSMutableArray *nearestNodesAndIndices = [self.timelineModel getNearestNodes:touchLocation onTrack:trackNum];
        
        //get the nodes from those timepoints, and their positions.
        NSMutableArray *left = [nearestNodesAndIndices objectAtIndex:0];
        SKNode *leftNode = [left objectAtIndex:0];
        int leftNodePosition = leftNode.position.x;
        int leftNodeIndex = [[left objectAtIndex:1] intValue]; // convert from NSNumber
        
        [self.timelineModel addClipToTrack:trackNum atIndex:leftNodeIndex]; //Add a flag to the array with the clip number
        
        //make and place new node between those positions       NEED TO CHECK HERE FOR LENGTH OF CLIP, OR IF MIDI DO SOMETHING ELSE!

        if([nearestNodesAndIndices objectAtIndex:1]) {  //IF there is a right gridmarker...
            NSMutableArray *right = [nearestNodesAndIndices objectAtIndex:1];   //IF SECOND NODE IS NULL, WE ARE ON LAST NODE IN TIMELINE. ADD TO MAX LENGTH OF CLIP?
            SKNode *rightNode = [right objectAtIndex:0];
            int rightNodeIndex = [[right objectAtIndex:1] intValue]; //convert from NSNumber
            int rightNodePosition = rightNode.position.x;
            
            //Make and Display the clip node
            SKSpriteNode *clipNode = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(rightNodePosition - leftNodePosition - self.gridMarkerWidth, self.trackHeight*0.2)];
            clipNode.anchorPoint = CGPointMake(0,0);
            clipNode.position = CGPointMake(self.gridMarkerWidth,0);
            
            //Make clip node child of left gridmarker
            [leftNode addChild:clipNode];
            
        } else {
            CGFloat clipEndPosition = 300;
            
            SKSpriteNode *clipNode = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(clipEndPosition - leftNodePosition - self.gridMarkerWidth, self.trackHeight*0.2)];
            clipNode.anchorPoint = CGPointMake(0,0);
            clipNode.position = CGPointMake(self.gridMarkerWidth,0);
            
            //Make clip node child of left gridmarker
            [leftNode addChild:clipNode];
        }
    }
}


- (int)getNodeTrackNumber:(SKNode*) node {
    //Check if name=="track" + tracknum
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"track\\d" options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (node.name) {
        NSRange range = NSMakeRange(0, [node.name length]);
        Boolean  matches = [regex numberOfMatchesInString:node.name options:0 range:range] > 0;
//        NSLog(@"%i", matches);
        if(matches == 1){
            //get tracknumber here
            int trackNum = (int)[[node.name substringWithRange:NSMakeRange(5, 1)] integerValue];
//            NSLog(@"%i tracknum", trackNum);
            return trackNum;
        } else {
            return -1;  //if node is not a track
        }
    } else {
        return -1; // if node doesn't have a name
    }
}



- (void)updateSceneTime: (double) time {
    //change the scenes time properties,
}


@end