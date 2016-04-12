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

- (void)storeTimePointWithLocation:(float)loc amplitude:(float)amp node:(SKSpriteNode*)n;

- (void) addClipToTrack:(int)trackNum atIndex:(int)index;

- (NSMutableArray*)getNearestNodes:(CGPoint)touchLocation onTrack:(int)trackNum;

@end
