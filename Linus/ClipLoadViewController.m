//
//  ClipLoadViewController.m
//  Linus
//
//  Created by Regis Verdin on 4/9/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "ClipLoadViewController.h"
#import "AudioController.h"
#import "AudioShareSDK.h"

@implementation ClipLoadViewController

- (void) viewWillAppear:(BOOL)animated{
    //get Size of view
    CGFloat windowWidth = self.view.bounds.size.width;
    CGFloat windowHeight = self.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height;
    
    //Add 16 buttons for loading clips
    for (int i = 0; i < 16; i++){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(loadClip:) forControlEvents:UIControlEventTouchUpInside];
        NSString *title = [NSString stringWithFormat: @"Load Sample %i", (i+1)];
        [button setTitle:title forState:UIControlStateNormal];
        
        
        //Positioning and sizing the buttons
        
        CGFloat xPos = windowWidth - ( windowWidth / ceil( (i+1)/8.0 ) );
        CGFloat yPos = (windowHeight / 8.0) * (i % 8);
        button.frame = CGRectMake(xPos, yPos, windowWidth/3, windowHeight/16);

        [self.view addSubview:button];
        button.backgroundColor = [UIColor redColor];
        
    }
}

- (void) importFile{
    //Load file using audioshare
    [[AudioShare sharedInstance] initiateSoundImport];
    [self updateFileList];
}

- (void) updateFileList{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
}

- (void) loadClip:(UIButton *)sender {
    //Get clip number from button title
    NSString *s = sender.titleLabel.text;
    NSString *newString = [s substringWithRange:NSMakeRange(12, 1)];
    NSInteger clipNum = [newString integerValue];
    
    //Choose URL from filesystem
    [[AudioShare sharedInstance] initiateSoundImport];
//    NSOpenPanel *open =
    
    
    //Pass url and clipnum to audiocontroller
//    [AudioController assignClip:url toIndex:clipNum];
}

@end