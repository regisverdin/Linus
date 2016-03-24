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


- (void)addTimePointWithLocation:(float)loc windowWidth:(float)win screenTime:(double)screenT timeOffset:(double)tOffset amplitude:(double)amp node:(SKSpriteNode*)n;

- (int) findInsertionIndex:(float)insertionTime;

@end
