//
//  AppDelegate.m
//  Linus
//
//  Created by Regis Verdin on 2/21/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

@import AudioToolbox;
#import "AppDelegate.h"
#import "AEAudioController.h"
#import "AEBlockChannel.h"
#import <UIKit/UIKit.h>
#import "AudioShareSDK.h"

@interface AppDelegate()

@property (nonatomic) AEAudioController *audioController;
@property AEBlockChannel *channel;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

    if([[AudioShare sharedInstance] checkPendingImport:url withBlock:^(NSString *path) {
        
        // Move the temporary file into our Documents folder
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *destination = [documentsDirectory stringByAppendingPathComponent:[path lastPathComponent]];
        [[NSFileManager defaultManager] moveItemAtPath:path toPath:destination error:nil];
        
        // Load the imported file
//        [mySoundEngine loadSample:destination];
        
    }]) {
        return YES;
    } else {
        return NO;
    }
}

@end
