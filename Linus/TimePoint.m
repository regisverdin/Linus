//
//  TimePoint.m
//  Linus
//
//  Created by Regis Verdin on 3/7/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "TimePoint.h"
#import "TimelineScene.h"

@implementation TimePoint

- (id)init {
    _clipNumber = -3;
    _clipDuration = 0.0;

    return self;
}

- (void)updateTime {
    float trackWidth = [TimelineScene getTrackWidth];
    float screenT = [TimelineScene getScreenTime];
    double tOffset = [TimelineScene getTimeOffset];
    
    _time = ((_node.position.x/trackWidth) * screenT) + tOffset;
}

@end
