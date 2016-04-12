//
//  TimelineScene.h
//  Linus
//
//  Created by Regis Verdin on 2/21/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//


@class TimelineModel;

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "TimelineModel.h"

@interface TimelineScene : SKScene

@property (nonatomic) double screenTime;
@property (nonatomic) double timeOffset;
@property TimelineModel *timelineModel;

//@property int gridClipMode;
//@property CGFloat windowWidth;
//@property double screenTime;
//@property double timeOffset;


+ (void) setGridClipMode:(int) mode;
+ (int) getGridClipMode;
+ (float) getTrackWidth;
+ (void) setTrackWidth:(float)width;
+ (double) getScreenTime;
+ (double) getTimeOffset;

- (void) play;
- (void) stop;

@end