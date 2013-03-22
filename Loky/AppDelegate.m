//
//  AppDelegate.m
//  Loky
//
//  Created by Srikanth Sombhatla on 26/09/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import "AppDelegate.h"
#import "LKMediator.h"
#import "LKReminder.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"%s app state is %d",__PRETTY_FUNCTION__,(int)[UIApplication sharedApplication].applicationState);
    UIApplicationState appState = [UIApplication sharedApplication].applicationState;
    if(UIApplicationStateInactive == appState) {
        // launch reminder view
    } else if(UIApplicationStateActive == appState) {
        // show alert and launch reminder view when clicked on ok.
    }
    
    NSString* reminderID = [notification.userInfo valueForKey:kLKReminderKeyID];
    NSLog(@"reminder id:%@",reminderID);
    [[[LKMediator sharedInstance] manager] showAlertForReminderWithID:reminderID];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[LKMediator sharedInstance] restoreState];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    NSLog(@"launch options :%@",launchOptions);
    if([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        NSLog(@"launched for bkg location update");
        [[[LKMediator sharedInstance] locationManager] startUpdatingLocation];
    } else {
        self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
        [[LKMediator sharedInstance] setupNavigationOnWindow:self.window];
        [self.window makeKeyAndVisible];
    }
    return YES; // TODO: handle url invokation
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[LKMediator sharedInstance] saveState];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[[LKMediator sharedInstance] restoreState];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
