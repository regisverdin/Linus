//
//  TimelineViewController.m
//  Linus
//
//  Created by Regis Verdin on 2/17/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "TimelineViewController.h"

@implementation TimelineViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    //Creating an instance of SKView
    
    SKView * skView = [[SKView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
    
    //Setting frames per second property to be true
    
    skView.showsFPS = YES;
    
    //Setting count nodes property to be true because we want to know the number of nodes on the screen at any given time
    
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    
    SKScene * scene = [TimelineScene sceneWithSize:skView.bounds.size];
    
    //SKSceneScaleModeAspectFill will make sure that the scene is scaled properly in all orientations
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    //Making the view controllers view a skview
    
    self.view = skView;
    
    // Present the scene.
    
    [skView presentScene:scene];
}


@end
