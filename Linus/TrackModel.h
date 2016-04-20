//
//  TrackModel.h
//  Linus
//
//  Created by Regis Verdin on 3/23/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface TrackModel : NSObject

@property int length;
@property int trackNum;


- (void)addTimePointWithTime:(double)time amplitude:(double)amp node:(SKSpriteNode*)n;

- (void)addClip:(int)clipNum atIndex:(int)index;

- (void)deleteTimePointWithNode:(SKSpriteNode*)node;

- (void)deleteClipOnTimePointNode:(SKSpriteNode*)node;

- (int) findInsertionIndex:(float)insertionTime;

- (NSMutableArray*) getNearestNodesAndIndices:(double)time;

- (NSMutableArray*) getTrackEvents;

@end
