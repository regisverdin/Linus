//
//  TimelineScene.m
//  Linus
//
//  Created by Regis Verdin on 2/17/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "TimelineScene.h"

@interface TimelineScene ()
@property BOOL contentCreated;
@end

@implementation TimelineScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:0.0];
        
        // Create a simple label here - this is the equivalent of UILabel
        
        //        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Times"];
        //
        //        myLabel.text = @"Testing";
        //
        //        myLabel.fontSize = 30;
        //
        //        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
        //
        //                                       CGRectGetMidY(self.frame));
        //
        //        [self addChild:myLabel];
        
    }
    
    return self;
    
}

- (void)didMoveToView: (SKView *) view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}


- (void)createSceneContents
{
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    [self addChild: [self newHelloNode]];
    
}



- (SKSpriteNode *)newGridMarker
{
    SKSpriteNode *gridMarker = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(64,32)];
    return gridMarker;
}



- (SKLabelNode *)newHelloNode
{
    SKLabelNode *helloNode = [SKLabelNode labelNodeWithFontNamed:@"Times"];
    helloNode.text = @"testing";
    helloNode.fontSize = 42;
    helloNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    
    // Adding animation
    helloNode.name = @"helloNode";
    
    return helloNode;
}


//- (SKSpriteNode *)newGridNode
//{
//    SKSpriteNode *gridNode = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(64,32)];
//    gridNode.position = CGPointMake(CGRec)
//    return gridNode;
//}




- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
    
    SKNode *helloNode = [self childNodeWithName:@"helloNode"];
    if (helloNode != nil)
    {
        helloNode.name = nil;
        SKAction *moveUp = [SKAction moveByX: 0 y: 100.0 duration: 0.5];
        SKAction *zoom = [SKAction scaleTo: 2.0 duration: 0.25];
        SKAction *pause = [SKAction waitForDuration: 0.5];
        SKAction *fadeAway = [SKAction fadeOutWithDuration: 0.25];
        SKAction *remove = [SKAction removeFromParent];
        SKAction *moveSequence = [SKAction sequence:@[moveUp, zoom, pause, fadeAway, remove]];
        [helloNode runAction: moveSequence];
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ///
    SKSpriteNode *gridMarker = [self newGridMarker];
    gridMarker.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame));
    [self addChild:gridMarker];
}


//
//-(void)mouseDown:(NSEvent *)event
//{
//    mousePosition = [event locationInWindow];
//    SKSpriteNode *gridNode = [self newGridNode];
//    gridNode.position = CGPointMake(CGRectGetMidX(self.frame),
//                                    CGRectGetMidY(self.frame));
//}


@end