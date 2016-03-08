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
    
    CGRect viewSize = [[super view] frame];    //Get size of container view, and make skView same size
    SKView * skView = [[SKView alloc] initWithFrame:CGRectMake(0, 0, viewSize.size.width, viewSize.size.height)];    //Creating an instance of SKView
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    SKScene * timelineScene = [TimelineScene sceneWithSize:skView.bounds.size];    // Create and configure the timeline scene.
    timelineScene.scaleMode = SKSceneScaleModeResizeFill;
    self.view = skView;     //Making the view controllers view a skview
    [skView presentScene:timelineScene];     // Present the scene.
}


@end
