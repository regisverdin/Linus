//
//  ViewController.m
//  Linus
//
//  Created by Regis Verdin on 2/21/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property Boolean playing;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    } else {
        self.playing = true;
        NSLog(@"playing!");
    }
    
}

- (IBAction)backToBeginning:(id)sender {
}

- (IBAction)changeVolume:(id)sender {
    NSLog(@"%f", self.volumeSlider.value);
}


@end
