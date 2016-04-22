//
//  TimelineScene.m
//  Linus
//
//  Created by Regis Verdin on 2/17/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//
//
//
//
//

// NODE TREE NAMING STRUCTURE:

//_tracks
//    -"track1holder"
//        -"playhead"
//        -"track1"
//            -"gridmarker"
//              -"clip"
//            -"gridmarker"
//            ...
//            -"selectionBox"
//    -"track2holder"
//        -"playhead"
//        -"track2"
//            -"gridmarker"
//              -"clip"
//            -"gridmarker"
//            ...
//            -"selectionBox"



#import "TimelineScene.h"
#import "TimelineModel.h"
#import "TrackModel.h"
#import "Timepoint.h"

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
@property BOOL playing;

@property SKSpriteNode *selectionBox;
@property SKNode *selectedTrackNode;
@property NSMutableArray *selectedTimePoints;
@property NSMutableArray *deselectedNodes;
@property CGPoint touchBeganPosition;
@property NSMutableArray *selectedNodeStartLocations;

@end

static BOOL loopPlayback;
static BOOL selectMode;
static BOOL selectHoldMode;
static BOOL drawMode;
static BOOL clipMode;
static BOOL shiftMode;

static CGFloat trackWidth;
static double screenTime;
static double timeOffset;


@implementation TimelineScene


/////Class variable get/setters (sort of)////////

+ (void) setDrawMode:(BOOL)mode {
    drawMode = mode;
}

+ (BOOL) getDrawMode{
    return drawMode;
}

+ (void) setSelectMode:(BOOL)mode {
    selectMode = mode;
}

+ (BOOL) getSelectMode{
    return selectMode;
}

+ (void) setSelectHoldMode:(BOOL)mode {
    selectHoldMode = mode;
}

+ (BOOL) getSelectHoldMode{
    return selectHoldMode;
}

+ (void) setClipMode:(BOOL) mode {
    clipMode = mode;
}

+ (BOOL) getShiftMode{
    return shiftMode;
}

+ (void) setShiftMode:(BOOL) mode {
    shiftMode = mode;
}

+ (BOOL) getClipMode {
    return clipMode;
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

+ (void) setLoopPlayback:(BOOL)mode{
    loopPlayback = mode;
}

+ (BOOL) getLoopPlayback{
    return loopPlayback;
}

-(id)initWithSize:(CGSize)size {
    
    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        clipMode = NO; // start in grid mode
        
        self.tracks = [[NSMutableArray alloc] initWithCapacity:16];
        self.numTracks = 2;
        
        self.backgroundColor = [SKColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.0];
        self.gridMarkerHeight = 50;
        self.gridMarkerWidth = 2;
//        self.screenTime = 5.0;  //Screen (without scrolling or zooming) is 5 seconds long.
        self.timelineModel = [[TimelineModel alloc] init]; //Object for storing each track in the timeline
        
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
    [TimelineScene setScreenTime:2.0];
    [TimelineScene setTimeOffset:0.0];
    
    self.windowHeight = self.windowRect.size.height;
    self.trackWidth = self.windowWidth * 0.9;
    [TimelineScene setTrackWidth:self.trackWidth];
    self.trackInfoWidth = self.windowWidth * 0.1;
    self.trackHeight = self.windowHeight / 2.0;
    
    //Init the selection box to size 0
    _selectionBox = [[SKSpriteNode alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(0, 0)];
    _selectionBox.alpha = 0.5;
    _selectionBox.name = @"selectionBox";
    _selectedTimePoints = [[NSMutableArray alloc]init];
    _deselectedNodes = [[NSMutableArray alloc]init];
    _selectedNodeStartLocations = [[NSMutableArray alloc]init];
    
    //ADD TRACKS
    for (int i = 0; i < self.numTracks; i++) {
        
        // Add a track (each track is a parent node for its contents) to track array.
        SKSpriteNode *trackNode = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(self.trackWidth, 4)];
        trackNode.anchorPoint = CGPointMake(0,0);
        trackNode.position = CGPointMake(self.trackInfoWidth, self.windowHeight - (self.trackHeight * (i+1)) );
        NSString *trackHolderName = [NSString stringWithFormat:@"track%iholder", i];
        trackNode.name = trackHolderName;
        [self addChild:trackNode];
        self.tracks[i] = trackNode;
        
        //Add playhead at 0 time on each track.
        SKSpriteNode *playhead = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(1, self.trackHeight)];
        playhead.anchorPoint = CGPointMake(0,0);
        playhead.position = CGPointMake(0,0);
        playhead.name = @"playhead";
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
        
        [self addGridMarkerAtLocation:CGPointMake(0, 0) onTrackNode:trackTouchNode];
    }
    NSLog(@"Created scene");
    
}


- (SKSpriteNode *)newGridMarker {
    
    SKSpriteNode *gridMarker = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(self.gridMarkerWidth, self.gridMarkerHeight)];
    return gridMarker;
}


- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _touchBeganPosition = [touch locationInNode:self];
    
    if(selectMode){
        // Get track node and number
        _selectedTrackNode = [self nodeAtPoint:_touchBeganPosition];
        
        // Add selection box as child of tracknode
        [_selectionBox removeFromParent];
        [_selectedTrackNode addChild:_selectionBox];
        
        // Position the box (do the rest in touchesMoved)
        _selectionBox.anchorPoint = CGPointMake(0,0);
        _selectionBox.position = CGPointMake(_touchBeganPosition.x - _trackInfoWidth, 0);
        _selectionBox.size = CGSizeMake(1, _trackHeight);
    }
    
    if(shiftMode && ([_selectedTimePoints count] > 0)){
        // Get track node and number
        _selectedTrackNode = [self nodeAtPoint:_touchBeganPosition];
        
        //Get all starting points of selected items (for shifting)
        int i = 0;
        for(SKSpriteNode *currentNode in _selectedTimePoints) {
            CGPoint currentLocation = CGPointMake(currentNode.position.x, currentNode.position.y);
            [_selectedNodeStartLocations addObject:[NSValue valueWithCGPoint:currentLocation]];
            i++;
        }
    }
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInNode:self];
    
    if(selectMode) {
        // Resize selectionBox
        CGPoint touchLocation = [touch locationInNode:_selectedTrackNode];
        _selectionBox.size = CGSizeMake(touchLocation.x - _selectionBox.position.x, _trackHeight);
    }
    
    if(shiftMode && ([_selectedTimePoints count] > 0)) {
        int i = 0;
        for(SKSpriteNode *currentNode in _selectedTimePoints) {
            //Move all selected nodes (except node at 0 time)
            if(currentNode.position.x != 0) {
                CGPoint nodeStartPosition = [[_selectedNodeStartLocations objectAtIndex:i] CGPointValue];
                currentNode.position = CGPointMake(nodeStartPosition.x + (currentTouchPosition.x -_touchBeganPosition.x), 0);
                i++;
            }
        }
        // Update time property of each shifted timepoint
        for(TrackModel *tm in _timelineModel.tracks) {
            NSMutableArray *trackEvents = [[NSMutableArray alloc] init];
            trackEvents = [tm getTrackEvents];
            for(TimePoint *tp in trackEvents) {
                for(SKSpriteNode *selectedNode in _selectedTimePoints) {
                    if([tp.node isEqual:selectedNode]){
                        [tp updateTime];
                    }
                }
            }
        }
        
        //Update audiocontroller
        [_timelineModel.audioController updateAudioSchedule:_timelineModel.tracks];
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if(drawMode) {
        if(clipMode) {
            [self addClipOnTouch:touch];
        } else {
            [self addGridMarkerOnTouch:touch];
        }
    }
    
    if(selectMode) {
        //Get nodes in selection
        [_deselectedNodes removeAllObjects];
        SKNode *trackNode = _selectionBox.parent;
        NSArray *trackChildren = trackNode.children;
        
        
        
        // Clear current selection (always clear other track) (if hold is on, don't clear current track)
        int trackIndex = 0;
        for(SKNode *currentTrackHolder in _tracks) {

            SKNode *currentTrack = [currentTrackHolder childNodeWithName:[NSString stringWithFormat:@"track%i", trackIndex]];
            
            NSArray *currentTrackChildren = currentTrack.children;
            
            for(SKSpriteNode *currentNode in currentTrackChildren) {
                
                if([currentNode.name isEqualToString:@"gridMarker"] && ![trackNode.name isEqualToString:currentNode.parent.name]) {  //Clear other track, always
                    currentNode.color = [SKColor whiteColor];
                    [_selectedTimePoints removeObject:currentNode];
                }
                if([currentNode.name isEqualToString:@"gridMarker"] && ![TimelineScene getSelectHoldMode]) {  //If not select hold mode, clear current track too
                    currentNode.color = [SKColor whiteColor];
                    [_selectedTimePoints removeObject:currentNode];
                }
                if([TimelineScene getSelectHoldMode] && [_selectedTimePoints containsObject:currentNode] && [_selectionBox intersectsNode:currentNode]) { //If hold mode on and item already selected, deselect it.
                    currentNode.color = [SKColor whiteColor];
                    [_selectedTimePoints removeObject:currentNode];
                    [_deselectedNodes addObject:currentNode];
                }
            }
            trackIndex++;
        }
        
        
        //Change color of selected timepoints, and add to selectedTimePoints
        for(SKSpriteNode *currentNode in trackChildren) {
            if([currentNode.name isEqualToString:@"gridMarker"]) {
                
                if([_selectionBox intersectsNode:currentNode] && ![_deselectedNodes containsObject:currentNode]) {  //only select if not in deselect array
                    currentNode.color = [SKColor redColor];
                    [_selectedTimePoints addObject:currentNode];
                }
            }
        }
        //Hide the selection box
        _selectionBox.size = CGSizeMake(0,0);
    }
    
    if(shiftMode && ([_selectedTimePoints count] > 0)){
        [_selectedNodeStartLocations removeAllObjects];
    }
    
}


- (void)addGridMarkerAtLocation:(CGPoint)location onTrackNode:(SKSpriteNode*)trackNode {
    if ([self getNodeTrackNumber:trackNode] != -1){
        
        //Add grid marker to correct track
//        CGPoint nodeTouchLocation = [touch locationInNode:trackNode];
        CGPoint markerLocation  = CGPointMake(location.x, 0);
        int markerHeight = MAX(self.trackHeight*0.2, location.y);
        SKSpriteNode *gridMarker = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(self.gridMarkerWidth, markerHeight)];
        gridMarker.name = @"gridMarker";
        gridMarker.anchorPoint = CGPointMake(0,0);
        gridMarker.position = markerLocation;
        [trackNode addChild:gridMarker];
        
        //Store timepoint and node in timeline
        double amplitude = location.y/self.trackHeight*0.2;
        [self.timelineModel storeTimePointWithLocation:markerLocation.x amplitude:amplitude node:gridMarker];
//        NSLog(@"loc: %f", markerLocation.x);
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
            gridMarker.name = @"gridMarker";
            gridMarker.anchorPoint = CGPointMake(0,0);
            gridMarker.position = markerLocation;
            [node addChild:gridMarker];
        
            //Store timepoint and node in timeline
            double amplitude = nodeTouchLocation.y/self.trackHeight*0.2;
            [self.timelineModel storeTimePointWithLocation:markerLocation.x amplitude:amplitude node:gridMarker];
//            NSLog(@"loc: %f", markerLocation.x);
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

        if([nearestNodesAndIndices count] > 1) {  //IF there is a right gridmarker...
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
            clipNode.name = @"clip";
            
        } else {
//            int clipNum = [TimelineModel getSelectedClipNumber];
//            CGFloat clipSize = [TimelineModel getClipLength:clipNum];
            //Clip end position should reflect length of audio file
//            if ((leftNodePosition + clipSize) > _trackWidth) {
//                CGFloat rightNodePosition = _trackWidth;
//            } else {
//                
//            }
            
            CGFloat clipEndPosition = (leftNodePosition + 200) > _trackWidth ? _trackWidth : leftNodePosition + 200;
            
            SKSpriteNode *clipNode = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(clipEndPosition - leftNodePosition - self.gridMarkerWidth, self.trackHeight*0.2)];
            clipNode.anchorPoint = CGPointMake(0,0);
            clipNode.position = CGPointMake(self.gridMarkerWidth,0);
            
            //Make clip node child of left gridmarker
            [leftNode addChild:clipNode];
            clipNode.name = @"clip";
        }
    }
}


- (void)deleteSelection {
    
    for(SKSpriteNode *currentNode in _selectedTimePoints){
        int trackNum = [self getNodeTrackNumber:currentNode.parent];
        
        
        if(clipMode || currentNode.position.x == 0){                                    //Check for clipmode YES, or first marker
            [_timelineModel deleteClipOnTimePointNode:currentNode onTrack:trackNum];    //Delete the clip, but not the marker
            [currentNode removeAllChildren];
        } else {

            [_timelineModel deleteTimePointWithNode:currentNode onTrack:trackNum];
            [currentNode removeFromParent];
        }
    }
    
    [_selectedTimePoints removeAllObjects];
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
    //change the scenes time properties
}


- (void) play {
    [self.timelineModel.audioController start:NULL];
    _playing = YES;

    SKAction *movePlayhead = [SKAction moveToX:_trackWidth duration:[TimelineScene getScreenTime]];
    for(SKSpriteNode* currentTrack in _tracks){
        SKNode *playhead = [currentTrack childNodeWithName:@"playhead"];
        [playhead runAction:movePlayhead];
    }

//
//    while(_playing){
//        //Move playhead forward
//        for(SKSpriteNode* currentTrack in _tracks){
//            SKNode *playhead = [currentTrack childNodeWithName:@"playhead"];
//            playhead.position = CGPointMake(_trackWidth * ((AECurrentTimeInSeconds()-startTime) / screenTime), 0);
//        }
//    }
}

- (void) stop {
    [self.timelineModel.audioController stop];
    _playing = NO;
    for(SKSpriteNode* currentTrack in _tracks){
        SKNode *playhead = [currentTrack childNodeWithName:@"playhead"];
        [playhead removeAllActions];
        playhead.position = CGPointMake(0, 0);
    }
}


@end