//
//  AppDelegate.m
//  iMNet v2
//
//  Created by Bryan on 30/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext,managedObjectModel,persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    if (!context) {
        // Handle the error.
    }
    
    //pass managed object context to view controllers
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *naviController0 = [[tabBarController viewControllers] objectAtIndex:0];
    UINavigationController *naviController1 = [[tabBarController viewControllers] objectAtIndex:1];
    UINavigationController *naviController2 = [[tabBarController viewControllers] objectAtIndex:2];
    
    MessageViewController *messageViewController = [[naviController0 viewControllers] objectAtIndex:0];
    ContactsViewController *contactsViewController = [[naviController1 viewControllers] objectAtIndex:0];
    SettingsViewController *settingsViewController = [[naviController2 viewControllers] objectAtIndex:0];
    
    messageViewController.managedObjectContext = context;
    contactsViewController.managedObjectContext = context;
    settingsViewController.managedObjectContext = context;
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
