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
    NSLog(@"%@", sender.titleLabel.text);
    TimelineModel *timeline = [[TimelineModel alloc] init];
    [timeline setClipNumber:sender.titleLabel.text];
}

@end