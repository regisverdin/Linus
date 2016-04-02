//
//  TimelineModel.h
//  Linus
//
//  Created by Regis Verdin on 3/7/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface TimelineModel : NSObject

- (void)storeTimePointWithLocation:(float)loc windowWidth:(float)win screenTime:(double)screenT timeOffset:(double)tOffset amplitude:(float)amp node:(SKSpriteNode*)n;

- (void) setClipNumber:(NSString*) clipNum;

@end
