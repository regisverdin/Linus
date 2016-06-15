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

@property int selectedClipNumber;

//@property int gridClipMode;
//@property CGFloat windowWidth;
//@property double screenTime;
//@property double timeOffset;

+ (void) setDrawMode:(BOOL)mode;
+ (BOOL) getDrawMode;
+ (void) setSelectMode:(BOOL)mode;
+ (BOOL) getSelectMode;
+ (void) setSelectHoldMode:(BOOL)mode;
+ (BOOL) getSelectHoldMode;
+ (void) setClipMode:(BOOL)mode;
+ (BOOL) getClipMode;
+ (void) setShiftMode:(BOOL)mode;
+ (BOOL) getShiftMode;
+ (void) setLoopPlayback:(BOOL)mode;
+ (BOOL) getLoopPlayback;
+ (void) setScaleMode:(BOOL)mode;
+ (BOOL) getScaleMode;

+ (float) getTrackWidth;
+ (void) setTrackWidth:(float)width;
+ (double) getScreenTime;
+ (double) getTimeOffset;

- (void) play:(void(^)())callBack;
- (void) stop;
- (void) deleteSelection;
- (void) subdivideSelection;
- (void) changeTempo:(double)windowTime;
- (void) assignMidiNote:(int)noteNum toClipButton:(int)clipNum;

@end