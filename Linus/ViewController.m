//
//  ViewController.m
//  Linus
//
//  Created by Regis Verdin on 2/21/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "TimelineScene.h"
#import "AudioController.h"
#import "TimelineViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *gridButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *loopButton;
@property (weak, nonatomic) IBOutlet UIButton *drawButton;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *selectHoldButton;
@property (weak, nonatomic) IBOutlet UIButton *shiftButton;
@property (weak, nonatomic) IBOutlet UISlider *tempoSlider;
@property (weak, nonatomic) IBOutlet UITextField *tempoDisplay;
@property (weak, nonatomic) IBOutlet UIButton *scaleButton;

@property Boolean playing;
@property TimelineScene *scene;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [MidiBusClient startWithApp:@"Linus" andDelegate:self];
    
    _scene = [TimelineViewController getScene];
    self.playing = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/////////////////////////PLAYBACK CONTROLS/////////////////////////////


- (IBAction)onPlayPause:(id)sender {
    _scene = [TimelineViewController getScene];
    _playButton.selected = !_playButton.selected;
    
    void (^callBack)() = ^void{
        _playing = NO;
        _playButton.selected = !_playButton.selected;
    };
    
        //Stop
    if(self.playing) {
        _playing = NO;
        [_scene stop];
        _playButton.selected = NO;
        //Play
    } else {
        _playing = YES;
        [_scene play:callBack];
        _playButton.selected = YES;
    }
}


- (IBAction)onBackToStart:(id)sender {
    
}


- (IBAction)toggleLoop:(id)sender {
    _loopButton.selected = !_loopButton.selected;
    [TimelineScene setLoopPlayback:![TimelineScene getLoopPlayback]];
}


- (IBAction)changeVolume:(id)sender {
    NSLog(@"%f", self.volumeSlider.value);
}


- (IBAction)changeTempo:(id)sender {
    _scene = [TimelineViewController getScene];
    float tempo = _tempoSlider.value;
    [_scene changeTempo:tempo];
    _tempoDisplay.text = [NSString stringWithFormat:@"%f", tempo];
}



//- (IBAction)importAudio:(id)sender {
//    [[AudioShare sharedInstance] initiateSoundImport];
//}



/////////////////////////MAIN MODE SETTINGS/////////////////////////////


- (IBAction)toggleGridClipMode:(id)sender {
    _gridButton.selected = !_gridButton.selected;
    [TimelineScene setClipMode:![TimelineScene getClipMode]];
    
}

- (IBAction)toggleDrawMode:(id)sender {
    [self deselectAllButtons];
    
    _drawButton.selected = !_drawButton.selected;
    [TimelineScene setDrawMode:![TimelineScene getDrawMode]];
}

- (IBAction)toggleSelectMode:(id)sender {
    [self deselectAllButtons];
    
    _selectButton.selected = !_selectButton.selected;
    [TimelineScene setSelectMode:![TimelineScene getSelectMode]];
}

- (IBAction)toggleSelectHoldMode:(id)sender {
    [self deselectAllButtons];
    _selectButton.selected = YES;
    [TimelineScene setSelectMode:YES];
    
    _selectHoldButton.selected = !_selectHoldButton.selected;
    [TimelineScene setSelectHoldMode:![TimelineScene getSelectHoldMode]];
}

- (IBAction)toggleShiftMode:(id)sender {
    [self deselectAllButtons];
    
    _shiftButton.selected = !_shiftButton.selected;
    [TimelineScene setShiftMode:![TimelineScene getShiftMode]];

}

- (IBAction)toggleScaleMode:(id)sender {
    [self deselectAllButtons];
    
    _scaleButton.selected = !_scaleButton.selected;
    [TimelineScene setScaleMode:![TimelineScene getScaleMode]];
}



- (void)deselectAllButtons {
    _gridButton.selected = NO;
    [TimelineScene setClipMode:NO];
    _drawButton.selected = NO;
    [TimelineScene setDrawMode:NO];
    _selectButton.selected = NO;
    [TimelineScene setSelectMode:NO];
    _selectHoldButton.selected = NO;
    [TimelineScene setSelectHoldMode:NO];
    _shiftButton.selected = NO;
    [TimelineScene setShiftMode:NO];
}

/////////////////////////MODIFY/////////////////////////////


- (IBAction)deleteButtonPressed:(id)sender {
    _scene = [TimelineViewController getScene];
    [_scene deleteSelection];
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



@end
