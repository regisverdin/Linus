//
//  AudioController.h
//  Linus
//
//  Created by Regis Verdin on 4/7/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import "MidiBusClient.h"

@interface AudioController : NSObject <MidiBusClientDelegate>

@property (nonatomic) BOOL inputEnabled;

- (void) updateAudioSchedule:(NSMutableArray* _Nullable)tracks;
- (BOOL) start:(NSError *_Nullable *_Nullable)error;
- (void) stop;
- (void) startMidi;
- (void) stopMidi;
- (AESeconds)getTimeOfUrlAtIndex:(int)urlIndex;
+ (void) assignClip:(NSURL* _Nullable)url toIndex:(int)index;
- (void) assignMidiNote:(int)noteNum toClipButton:(int)clipNum;

@end