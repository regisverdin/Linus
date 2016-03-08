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

@property int length;

- (void)storeTimePointWithLocation:(float)loc withWindowWidth:(float)win withScreenTime:(double)screenT withTimeOffset:(double)tOffset withAmplitude:(float)amp fromNode:(SKSpriteNode*)n;

@end
