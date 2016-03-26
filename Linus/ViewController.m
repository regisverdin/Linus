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


//PLAYBACK CONTROLS

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
        track1.loop = NO;
        
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
