//
//  ClipViewController.m
//  Linus
//
//  Created by Regis Verdin on 4/2/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "ClipViewController.h"
#import "TimelineModel.h"

@implementation ClipViewController


-(void) viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)selectButton:(UIButton *)sender {
    
    //Set selectedClipNumber classVariable to current button selected (with flags for + and -)
    if ([sender.titleLabel.text  isEqual: @"+"]) {
        [TimelineModel setSelectedClipNumber:-1];
        
    } else if ([sender.titleLabel.text  isEqual: @"-"]) {
        [TimelineModel setSelectedClipNumber:-2];
    } else {
        int clipNumber = [sender.titleLabel.text intValue];
        [TimelineModel setSelectedClipNumber:clipNumber];
    }
}

@end