//
//  AudioController.h
//  Linus
//
//  Created by Regis Verdin on 4/7/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"


@interface AudioController : NSObject


@property (nonatomic) BOOL inputEnabled;


- (void) updateAudioSchedule:(NSMutableArray* _Nullable)trackEvents forTrack:(int)trackNum;

- (BOOL) start:(NSError *_Nullable *_Nullable)error;

//- (void) pause;

- (void) stop;

+ (void) assignClip:(NSURL* _Nullable)url toIndex:(int)index;

@end