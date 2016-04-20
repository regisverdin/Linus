//
//  TimelineModel.h
//  Linus
//
//  Created by Regis Verdin on 3/7/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

@class TimelineScene;

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "AudioController.h"

@interface TimelineModel : NSObject

@property AudioController *audioController;

+ (void)setSelectedClipNumber:(int)clip;

+ (int)getSelectedClipNumber;

- (void)storeTimePointWithLocation:(float)loc amplitude:(float)amp node:(SKSpriteNode*)n;

- (void) addClipToTrack:(int)trackNum atIndex:(int)index;

- (void)deleteTimePointWithNode:(SKSpriteNode*)node onTrack:(int)trackNum;

- (void)deleteClipOnTimePointNode:(SKSpriteNode*)node onTrack:(int)trackNum;

- (NSMutableArray*)getNearestNodes:(CGPoint)touchLocation onTrack:(int)trackNum;

@end
