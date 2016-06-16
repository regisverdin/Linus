//
//  AudioController.m
//  Linus
//
//  Created by Regis Verdin on 4/7/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "AudioController.h"
#import "TimePoint.h"
#import "TheAmazingAudioEngine/AETime.h"
#import "TrackModel.h"
@import AVFoundation;

@interface AudioController ()

@property (nonatomic, strong) AEAudioUnitOutput *output;
@property (nonatomic, strong) AERenderer *renderer;
@property NSMutableArray *urls;
@property NSMutableDictionary *midiNoteMap;

//------
@property AEAudioFilePlayerModule *testPlayer;
@property double playTime;
@property AEArray * playersArray;
@property NSMutableArray *players;

@property (nonatomic) BOOL playingThroughSpeaker;
@property NSMutableArray *audioTrackEvents;
///-----

@end

static NSMutableArray *clipURLs;

@implementation AudioController

- (instancetype) init {
    if (!(self = [super init]) ) return nil;
    
    clipURLs = [[NSMutableArray alloc] initWithCapacity:16];
    _urls = [[NSMutableArray alloc]initWithCapacity:16];
    _renderer = [AERenderer new];
    _output = [[AEAudioUnitOutput alloc] initWithRenderer:_renderer];
    _playersArray = [AEArray new];
    _inputEnabled = NO;
    [self loadAudioURLs];
    [MidiBusClient startWithApp:@"Linus" andDelegate:self];
    _midiNoteMap = [[NSMutableDictionary alloc]init];
    
    
    return self;
}


- (void) updateAudioSchedule:(NSMutableArray*)tracks {

    //MAKE DEEP COPY OF TIMEPOINTS INTO AUDIOTRACKEVENTS
    
    _audioTrackEvents = [[NSMutableArray alloc] init];
    
    //Loop through tracks
    int trackCounter = 0;
    for (int i = 0; i < [tracks count]; i++){
        
        NSMutableArray *currentTrack = [[tracks objectAtIndex:i] getTrackEvents];   //Old track
        
        //Loop through track timepoints
        for (int j = 0; j < [currentTrack count]; j++) {
            TimePoint *timepoint = [currentTrack objectAtIndex:j]; //Old Timepoint
            TimePoint *timepointCopy = [[TimePoint alloc] init];   //New Timepoint
            timepointCopy.amplitude = timepoint.amplitude;
            timepointCopy.clipNumber = timepoint.clipNumber;
            timepointCopy.time = timepoint.time;
            timepointCopy.clipDuration = timepoint.clipDuration;
            timepointCopy.node = timepoint.node;

            timepointCopy.midiNoteNumber = [_midiNoteMap objectForKey:[NSString stringWithFormat:@"%i", timepoint.clipNumber]] ? [[_midiNoteMap objectForKey:[NSString stringWithFormat:@"%i", timepoint.clipNumber]]integerValue] : timepoint.midiNoteNumber;

            
            //Add copy of timepoint to new 1d array
            [_audioTrackEvents addObject:timepointCopy];
        }
        trackCounter++;
    }
    
    [_audioTrackEvents sortUsingComparator:^NSComparisonResult(TimePoint *obj1, TimePoint *obj2) {
        
        if (obj1.time > obj2.time) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (obj1.time < obj2.time) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];

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
    NSLog(@"here");
}

- (void)loadAudioURLs {

    NSURL *url;
    url = [[NSBundle mainBundle] URLForResource:@"KickDrum0001" withExtension:@"aif"];
    [_urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"KickDrum0003" withExtension:@"aif"];
    [_urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"KickDrum0022" withExtension:@"aif"];
    [_urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"Low Tom0005" withExtension:@"aif"];
    [_urls addObject:url];
    
    url = [[NSBundle mainBundle] URLForResource:@"Closed Hihat0001" withExtension:@"aif"];
    [_urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"Closed Hihat0002" withExtension:@"aif"];
    [_urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"Closed Hihat0003" withExtension:@"aif"];
    [_urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"Closed Hihat0004" withExtension:@"aif"];
    [_urls addObject:url];
    
    url = [[NSBundle mainBundle] URLForResource:@"SnareDrum0001" withExtension:@"aif"];
    [_urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"SnareDrum0003" withExtension:@"aif"];
    [_urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"SnareDrum0004" withExtension:@"aif"];
    [_urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"Mid Conga0001" withExtension:@"aif"];
    [_urls addObject:url];
    
    url = [[NSBundle mainBundle] URLForResource:@"Open Hihat0001" withExtension:@"aif"];
    [_urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"Open Hihat0002" withExtension:@"aif"];
    [_urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"Open Hihat0003" withExtension:@"aif"];
    [_urls addObject:url];
    url = [[NSBundle mainBundle] URLForResource:@"Open Hihat0004" withExtension:@"aif"];
    [_urls addObject:url];

}

- (AESeconds)getTimeOfUrlAtIndex:(int)urlIndex {
    AEAudioFilePlayerModule *tempFilePlayer = [[AEAudioFilePlayerModule alloc] initWithRenderer:_renderer
                                                                                            URL:[_urls objectAtIndex:urlIndex]
                                                                                          error:NULL
                                               ];
    return tempFilePlayer.duration;
}


- (BOOL)start:(NSError *__autoreleasing *)error {
    // Request a 128 frame hardware duration, for minimal latency
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setPreferredIOBufferDuration:128.0/session.sampleRate error:NULL];
    
    // Start the session
    if ( ![self setAudioSessionCategory:error] || ![session setActive:YES error:error] ) {
        return NO;
    }
    
    //    Make NSarray of players
    
    _players = [[NSMutableArray alloc]init];
    for (TimePoint *tp in _audioTrackEvents) {
        //Check for an assigned clip on the timepoint (i.e. clipnumber is not null)
        
        if (tp.clipNumber > -3) {    //Check if the gridmarker has an assigned clip... (-3 is init value for clipnumber)
            
            //Load url for current clip number
            NSURL *url = [_urls objectAtIndex:tp.clipNumber];
            
            AEAudioFilePlayerModule *filePlayer = [[AEAudioFilePlayerModule alloc] initWithRenderer:self.output.renderer URL:url error: NULL];
            
            double playTime = AECurrentTimeInHostTicks() + AEHostTicksFromSeconds(tp.time);
            [filePlayer playAtTime:playTime];
            
            //Add fileplayers to NSMutableArray,
            [_players addObject:filePlayer];
            
        }
    }
    
    
    [_playersArray updateWithContentsOfArray:_players];
    
    AEArray * finalPlayersArray = [AEArray new];
    finalPlayersArray = _playersArray;
    
    //FOR PAUSE: ADD A CONDITIONAL BASED ON BOOL FLAG
    
    _output.renderer.block = ^(const AERenderContext * _Nonnull context) {
        //         Run all the players
        
        AEArrayEnumerateObjects(finalPlayersArray, AEAudioFilePlayerModule *, player) {
            if ( AEAudioFilePlayerModuleGetPlaying(player) ) {
                
                AEModuleProcess(player, context);
                
                // Put on output
                AEBufferStackMixToBufferList(context->stack, 0,context->output);
                AEBufferStackPop(context->stack, 1);
            }
        };
        
        
    };
    
    return [self.output start:error];
}

- (void) stop {
    double time = AECurrentTimeInSeconds();
    return [self.output stop];
}

- (void) startMidi {
    double startTime = AECurrentTimeInSeconds();
    for (TimePoint *tp in _audioTrackEvents) {
        if(tp.midiNoteNumber >= 0) {
            while(AECurrentTimeInSeconds() - startTime < tp.time) {
                continue;
            }
    //        end previous midi event
    //        
    //        start new midi event
    //        
    //         create an event and initialise it
            MIDIBUS_MIDI_EVENT* event = [MidiBusClient setupSmallEvent];
            
            int r = arc4random_uniform(127);
            
            // populate the message
            event->timestamp = 0;         // send immediately or you can stamp in the future
            event->length = 3;            // length of MIDI message
            event->data[0] = 0x91;        // note on channel 1
//            event->data[1] = tp.midiNoteNumber;        // note on value
            event->data[1] = r;        // note on value
            event->data[2] = 0x40;        // velocity
            
            // send it
            eMidiBusStatus status = [MidiBusClient sendMidiBusEvent:1 withEvent:event];
            // probably wise to check the status
            
            // clean up message if finished with it
            [MidiBusClient disposeSmallEvent:event];
        }
    }
    
}

- (void) stopMidi {
    
}

+ (void) assignClip:(NSURL*)url toIndex:(int)index {
    //make a property that's an array of clips and the buttons/indices they are assigned to. then in updateaudio, retrieve the url from that index.
    [clipURLs replaceObjectAtIndex:index withObject:url];
    //question: how to load clips and display selection to user? in a good way... they should be able to see the clip name easily
}

- (void) assignMidiNote:(int)noteNum toClipButton:(int)clipNum {
    NSNumber *noteNumber = [NSNumber numberWithInt:noteNum];
    [_midiNoteMap setObject:noteNumber forKey:[NSString stringWithFormat:@"%i", clipNum]];
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




////////////////////MIDI SETUP/////////////////////////
#pragma


- (void)receivedMidiBusClientEvent:(MIDIBUS_MIDI_EVENT*)event
{
    // do something with a received MIDI event
}

- (eMidiBusVirtualMode) virtualMidiBusMode
{
    // for an app that only sends MIDI
    return eMidiBusVirtualModeOutput;
}


// this delegate method is called every time there is a change in the
// MIDI world; add/remove ports or network connect/disconnect
- (void)handleMidiBusClientNotification:(uint8_t)type
{
    // create a static query object which we can reuse time and time again
    // that won't get de-alloced by ARC by making a strong reference
    // this query gets all interfaces; you can get subsets of the interfaces
    // by using a different filter value - see midibus.h for #defines for this
    static MidiBusInterfaceQuery* query = nil;
    if (query == nil)
        query = [[MidiBusInterfaceQuery alloc]
                 initWithFilter:MIDIBUS_INTERFACE_FILTER_ALL_INTERFACES];
    NSArray* interfaces = [query getInterfaces];
    
    // Enable all interfaces
    for (MidiBusInterface* obj in interfaces)
    {
        MIDIBUS_INTERFACE* interface = obj->interface;
        interface->enabled = (bool_t) '1';
    }
}




@end