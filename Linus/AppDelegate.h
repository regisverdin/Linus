//
//  AppDelegate.h
//  Linus
//
//  Created by Regis Verdin on 2/21/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options;

@end

