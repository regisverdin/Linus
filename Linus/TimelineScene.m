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


@end

@implementation TimelineScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
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
    self.windowRect = self.view.frame;
    self.windowWidth = self.windowRect.size.width;
    self.windowHeight = self.windowRect.size.height;
    
    //Add playhead at 0 time
    SKSpriteNode *playhead = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(2, self.windowHeight)];
    playhead.position = CGPointMake(1, 0);
    [self addChild:playhead];
}



- (SKSpriteNode *)newGridMarker {
    
    SKSpriteNode *gridMarker = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(2, self.gridMarkerHeight)];
    return gridMarker;
}



- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event {

}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    // Get touch location
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    CGPoint markerLocation  = CGPointMake(touchLocation.x, 0);
    self.gridMarkerHeight = touchLocation.y * 2;    //Awkward, but *2 because position is based on center of sprite.
    double amplitude = (touchLocation.y / self.windowHeight) * 2;
    
    
    //Add sprite node
    SKSpriteNode *gridMarker = [self newGridMarker];
    gridMarker.position = markerLocation;
    [self addChild:gridMarker];
    
    
    //Store timepoint and node in array
    [self.timelineModel storeTimePointWithLocation:touchLocation.x withWindowWidth:self.windowWidth withScreenTime:self.screenTime withTimeOffset:self.timeOffset withAmplitude:amplitude fromNode:gridMarker];
    
    
    //print length
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