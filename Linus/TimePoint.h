//
//  TimePoint.h
//  Linus
//
//  Created by Regis Verdin on 3/7/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import <TheAmazingAudioEngine/AETime.h>

@interface TimePoint : NSObject

@property double time;
@property float amplitude;
@property int clipNumber;
@property int midiNoteNumber;
@property AESeconds clipDuration;
@property SKSpriteNode *node;

-(void)updateTime;

@end