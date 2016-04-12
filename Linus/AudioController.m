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

//------
@property AEAudioFilePlayerModule *testPlayer;
@property double playTime;
@property AEArray * playersArray;
///-----

@end

static NSMutableArray *clipURLs;

@implementation AudioController

- (instancetype) init {
    if (!(self = [super init]) ) return nil;
    
    clipURLs = [[NSMutableArray alloc] initWithCapacity:16];
    
    _renderer = [AERenderer new];
    _output = [[AEAudioUnitOutput alloc] initWithRenderer:_renderer];
    _playersArray = [AEArray new];
    
    return self;
}


- (void) updateAudioSchedule:(NSMutableArray*)trackEvents forTrack:(int)trackNum {
    
    //Load test urls
    NSMutableArray *urls = [[NSMutableArray alloc]initWithCapacity:16];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"clap-808" withExtension:@"wav"];
    [urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"hihat-808" withExtension:@"wav"];
    [urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"kick-808" withExtension:@"wav"];
    [urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"perc-808" withExtension:@"wav"];
    [urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"snare-808" withExtension:@"wav"];
    [urls addObject:url];
    url =[[NSBundle mainBundle] URLForResource:@"tom-808" withExtension:@"wav"];
    [urls addObject:url];
    
    
//    Make NSarray of players
    NSMutableArray *players = [[NSMutableArray alloc]init];
    
    for (TimePoint *tp in trackEvents) {
        //Check for an assigned clip on the timepoint (i.e. clipnumber is not null)
        
        if (tp.clipNumber) {
            
            //Load url for current clip number
            NSURL *url = [urls objectAtIndex:tp.clipNumber];
            
            AEAudioFilePlayerModule *filePlayer = [[AEAudioFilePlayerModule alloc] initWithRenderer:_renderer URL:url error: NULL];

            double playTime = AECurrentTimeInHostTicks() + AEHostTicksFromSeconds(tp.time);
            [filePlayer playAtTime:playTime];
            
            //Add fileplayers to NSMutableArray,
            [players addObject:filePlayer];
            
        }
    }
    
    [_playersArray updateWithContentsOfArray:players];
    

//    
//    _testPlayer = [[AEAudioFilePlayerModule alloc] initWithRenderer:_renderer URL:url error:NULL];
//    AEAudioFilePlayerModule *testPlayer2 = [[AEAudioFilePlayerModule alloc] initWithRenderer:_renderer URL:url error:NULL];
//    
//    _playTime = AECurrentTimeInHostTicks() + AEHostTicksFromSeconds(0.0);
//    [_testPlayer playAtTime:_playTime];
//    
//    double playTime2 = AECurrentTimeInHostTicks() + AEHostTicksFromSeconds(3.0);
//    [testPlayer2 playAtTime:playTime2];
//    
//    NSMutableArray *playerArr = [[NSMutableArray alloc]initWithObjects:_testPlayer, testPlayer2, nil];
//    
//    [_playersArray updateWithContentsOfArray:playerArr];
//    
    

   
    

}


- (BOOL) start:(NSError *_Nullable *_Nullable)error {

    
    AEArray * finalPlayersArray = [AEArray new];
    finalPlayersArray = _playersArray;
    
    _renderer.block = ^(const AERenderContext * _Nonnull context) {
        //         Run all the players
        
        AEArrayEnumerateObjects(finalPlayersArray, AEAudioFilePlayerModule *, player, {
            if ( AEAudioFilePlayerModuleGetPlaying(player) ) {
                // Process
                
                AEModuleProcess(player, context);
                
                // Put on output
                AEBufferStackMixToBufferList(context->stack, 0, 0, YES, context->output);
                //                AEBufferStackPop(context->stack, 1);
            }
        });
        
        
    };
    
    return [self.output start:error];
}

- (void) stop {
    double time = AECurrentTimeInSeconds();
    NSLog(@"%f", time);
    return [self.output stop];
}

+ (void) assignClip:(NSURL*)url toIndex:(int)index {
    //make a property thats an array of clips and the buttons/indices they are assigned to. then in updateaudio, retrieve the url from that index.
    [clipURLs replaceObjectAtIndex:index withObject:url];
    //question: how to load clips and display selection to user? in a good way... they should be able to see the clip name easily
}




@end