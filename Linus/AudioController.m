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
@import AVFoundation;


@interface AudioController ()
@property (nonatomic, strong) AEAudioUnitOutput *output;
@property (nonatomic, strong) AERenderer *renderer;

//------
@property AEAudioFilePlayerModule *testPlayer;
@property double playTime;
@property AEArray * playersArray;
@property NSMutableArray *players;

@property (nonatomic) BOOL playingThroughSpeaker;
@property NSMutableArray *trackEvents;
///-----

@end

static NSMutableArray *clipURLs;

@implementation AudioController

- (instancetype) init {
    if (!(self = [super init]) ) return nil;
    
    clipURLs = [[NSMutableArray alloc] initWithCapacity:16];
    
    _players = [[NSMutableArray alloc]init];
    
    _renderer = [AERenderer new];
    _output = [[AEAudioUnitOutput alloc] initWithRenderer:_renderer];
    _playersArray = [AEArray new];
    
    _inputEnabled = NO;
    
    return self;
}


- (void) updateAudioSchedule:(NSMutableArray*)trackEvents forTrack:(int)trackNum {
    
    if (trackNum == 0) {
        _trackEvents = trackEvents; //If passing first track, we reset trackEvents
    } else {
        [_trackEvents addObjectsFromArray:trackEvents]; // else add to current trackEvents
    }
    

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


- (BOOL)start:(NSError *__autoreleasing *)error {
    // Request a 128 frame hardware duration, for minimal latency
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setPreferredIOBufferDuration:128.0/session.sampleRate error:NULL];
    
    // Start the session
    if ( ![self setAudioSessionCategory:error] || ![session setActive:YES error:error] ) {
        return NO;
    }

    //Load test urls
    NSMutableArray *urls = [[NSMutableArray alloc]initWithCapacity:16];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Low Tom0005" withExtension:@"aif"];
    [urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"KickDrum0017" withExtension:@"aif"];
    [urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"Closed Hihat0001" withExtension:@"aif"];
    [urls addObject:url];

    
    //    Make NSarray of players

    
    for (TimePoint *tp in _trackEvents) {
        //Check for an assigned clip on the timepoint (i.e. clipnumber is not null)
        
        if (tp.clipNumber) {
            
            //Load url for current clip number
            NSURL *url = [urls objectAtIndex:tp.clipNumber];
            
            AEAudioFilePlayerModule *filePlayer = [[AEAudioFilePlayerModule alloc] initWithRenderer:_renderer URL:url error: NULL];
            
            double playTime = AECurrentTimeInHostTicks() + AEHostTicksFromSeconds(tp.time);
            [filePlayer playAtTime:playTime];
            
            //Add fileplayers to NSMutableArray,
            [_players addObject:filePlayer];
            
        }
    }
    
    
    [_playersArray updateWithContentsOfArray:_players];
    
    AEArray * finalPlayersArray = [AEArray new];
    finalPlayersArray = _playersArray;
    
    
    _renderer.block = ^(const AERenderContext * _Nonnull context) {
        //         Run all the players
        
        AEArrayEnumerateObjects(finalPlayersArray, AEAudioFilePlayerModule *, player, {
            if ( AEAudioFilePlayerModuleGetPlaying(player) ) {
                
                AEModuleProcess(player, context);
                
                // Put on output
                AEBufferStackMixToBufferList(context->stack, 0, 0, YES, context->output);
                AEBufferStackPop(context->stack, 1);
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
    //make a property that's an array of clips and the buttons/indices they are assigned to. then in updateaudio, retrieve the url from that index.
    [clipURLs replaceObjectAtIndex:index withObject:url];
    //question: how to load clips and display selection to user? in a good way... they should be able to see the clip name easily
}


- (BOOL)setAudioSessionCategory:(NSError **)error {
    NSError * e;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    if ( ![session setCategory:self.inputEnabled ? AVAudioSessionCategoryPlayAndRecord : AVAudioSessionCategoryPlayback
                   withOptions:(self.inputEnabled ? AVAudioSessionCategoryOptionDefaultToSpeaker : 0)
           | AVAudioSessionCategoryOptionMixWithOthers
                         error:&e] ) {
        NSLog(@"Couldn't set category: %@", e.localizedDescription);
        if ( error ) *error = e;
        return NO;
    }
    return YES;
}


- (void)updatePlayingThroughSpeaker {
    AVAudioSession * session = [AVAudioSession sharedInstance];
    AVAudioSessionRouteDescription *currentRoute = session.currentRoute;
    self.playingThroughSpeaker =
    [currentRoute.outputs filteredArrayUsingPredicate:
     [NSPredicate predicateWithFormat:@"portType = %@", AVAudioSessionPortBuiltInSpeaker]].count > 0;
}



@end