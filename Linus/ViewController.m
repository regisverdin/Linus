//
//  ViewController.m
//  Linus
//
//  Created by Regis Verdin on 2/21/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "AEAudioController.h"
#import "AEAudioFilePlayer.h"
#import "AEBlockChannel.h"
#import "AEReverbFilter.h"
#import "AudioShareSDK.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property Boolean playing;

@property AEAudioController *audioController;
@property AEBlockChannel *channel;
@property AEReverbFilter *reverb;
@property AEAudioFilePlayer *track1;
//@property AppDelegate *appDelegate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [MidiBusClient startWithApp:@"Linus" andDelegate:self];
    
//    //Setup audiocontroller
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //see here for cast info: http://stackoverflow.com/questions/231947/referencing-appdelegate-instance-variables
//    NSError *errorAudioSetup = NULL;
//    BOOL result = [[appDelegate audioController] start:&errorAudioSetup];
//    if ( !result ) {
//        NSLog(@"Error starting audio engine: %@", errorAudioSetup.localizedDescription);
//    }
//
    
    self.playing = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        // do something with the interface
    }
    
    NSLog(@"asdf");
}




- (IBAction)testMidiOut:(id)sender {
    // enable interface
    
    
    // create an event and initialise it
    MIDIBUS_MIDI_EVENT* event = [MidiBusClient setupSmallEvent];
    
    // populate the message
    event->timestamp = 0;         // send immediately or you can stamp in the future
    event->length = 3;            // length of MIDI message
    event->data[0] = 0x91;        // note one channel 1
    event->data[1] = 0x40;        // note on value
    event->data[2] = 0x90;        // velocity
    
    // send it
    eMidiBusStatus status = [MidiBusClient sendMidiBusEvent:2 withEvent:event];
    // probably wise to check the status
    
    // clean up message if finished with it
    [MidiBusClient disposeSmallEvent:event];
}



/////////////////////////PLAYBACK CONTROLS/////////////////////////////





- (IBAction)playPause:(id)sender {
    
    if(self.playing) {
        self.playing = false;
        NSLog(@"paused!");
        
        _track1.channelIsMuted = TRUE;
        _track1.channelIsPlaying = FALSE;
        
        
    } else {
        self.playing = true;
        NSLog(@"playing!");

        // Create an instance of the audio controller
        self.audioController = [[AEAudioController alloc]
                                initWithAudioDescription:
                                AEAudioStreamBasicDescriptionNonInterleavedFloatStereo];
        
        // Start the audio engine.
        [_audioController start:NULL];

        // Initialise tracks
        AEAudioFilePlayer *track1 =
        [AEAudioFilePlayer audioFilePlayerWithURL: [[NSBundle mainBundle] URLForResource:@"Loop" withExtension:@"mp3"] error:NULL];
        
        // Set to loop mode
        track1.loop = YES;
        
        // Add channels
        [self.audioController addChannels:@[track1]];
        
    }
    
}

- (IBAction)backToBeginning:(id)sender {
}

- (IBAction)changeVolume:(id)sender {
    NSLog(@"%f", self.volumeSlider.value);
}

- (IBAction)importAudio:(id)sender {
    [[AudioShare sharedInstance] initiateSoundImport];
}





@end
