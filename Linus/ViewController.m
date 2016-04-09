//
//  ViewController.m
//  Linus
//
//  Created by Regis Verdin on 2/21/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#import "AudioShareSDK.h"

#import "TimelineScene.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property Boolean playing;

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
    }
}

- (IBAction)testMidiOut:(id)sender {
    
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





- (IBAction)onPlayPause:(id)sender {
    
    //Pause
    if(self.playing) {
        self.playing = false;
        NSLog(@"paused!");
        
    //Play
    } else {
        self.playing = true;
        NSLog(@"playing!");
    }
    
}

- (IBAction)onBackToStart:(id)sender {

}

- (IBAction)changeVolume:(id)sender {
    NSLog(@"%f", self.volumeSlider.value);
}

- (IBAction)importAudio:(id)sender {
    [[AudioShare sharedInstance] initiateSoundImport];
}




/////////////////////////MAIN MODE SETTINGS/////////////////////////////


- (IBAction)toggleGridClipMode:(id)sender {
    if ([TimelineScene getGridClipMode] == 0) { //0 is grid, 1 is clip
        [TimelineScene setGridClipMode:1];
    } else {
        [TimelineScene setGridClipMode:0];
    }
}



@end
