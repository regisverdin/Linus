//
//  AudioController.m
//  Linus
//
//  Created by Regis Verdin on 4/7/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "AudioController.h"
#import "TimePoint.h"
#import "AETime.h"


@interface AudioController ()
@property (nonatomic, strong) AEAudioUnitOutput *output;
@property (nonatomic, strong) AERenderer *renderer;
@property NSMutableArray *clipURLs;


@end


@implementation AudioController

- (instancetype) init {
    if (!(self = [super init]) ) return nil;
    
    _clipURLs = [[NSMutableArray alloc] initWithCapacity:16];
    
    _renderer = [AERenderer new];
    _output = [[AEAudioUnitOutput alloc] initWithRenderer:_renderer];
    
    return self;
}


- (void) updateAudioSchedule:(NSMutableArray*)trackEvents forTrack:(int)trackNum {
    //Make NSarray of players
    NSMutableArray *players;
    
    for (TimePoint *tp in trackEvents) {
        //Check for an assigned clip on the timepoint (i.e. clipnumber is not null)
        
        if (tp.clipNumber) {
            //Load url for clip number

            NSURL *url = [[NSBundle mainBundle] URLForResource:@"Loop" withExtension:@"mp3"];
            AEAudioFilePlayerModule *filePlayer = [[AEAudioFilePlayerModule alloc] initWithRenderer:_renderer URL:url error: NULL];
            filePlayer.loop = NO;
            [filePlayer playAtTime:tp.time];
            
            //Add fileplayers to NSMutableArray,
            [players addObject:filePlayer];
            
        }
    }
    
    AEArray * playersArray = [AEArray new];
    [playersArray updateWithContentsOfArray:players];
    
    
    _renderer.block = ^(const AERenderContext * _Nonnull context) {
        // Run all the players
        AEArrayEnumerateObjects(playersArray, AEAudioFilePlayerModule *, player, {
            if ( AEAudioFilePlayerModuleGetPlaying(player) ) {
                // Process
                AEModuleProcess(player, context);
                
                // Put on output
                AEBufferStackMixToBufferList(context->stack, 0, 0, YES, context->output);
                AEBufferStackPop(context->stack, 1);
            }
        });
    };

}


- (BOOL) start:(NSError *_Nullable *_Nullable)error {
    return [self.output start:error];
}


- (void) pause {
}

- (void) stop {
    return [self.output stop];
}

- (void) chooseClip:(NSURL*)url forIndex:(int)index {
    //make a property thats an array of clips and the buttons/indices they are assigned to. then in updateaudio, retrieve the url from that index.
    [_clipURLs replaceObjectAtIndex:index withObject:url];
    //question: how to load clips and display selection to user? in a good way... they should be able to see the clip name easily
}




@end