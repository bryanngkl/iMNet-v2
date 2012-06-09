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
    
    //create rscMgr
    rscMgr = [[RscMgr alloc] init];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    if (!context) {
        // Handle the error.
    }
    
    //pass managed object context to view controllers
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *naviController0 = [[tabBarController viewControllers] objectAtIndex:0];
    UINavigationController *naviController1 = [[tabBarController viewControllers] objectAtIndex:1];
    UINavigationController *naviController2 = [[tabBarController viewControllers] objectAtIndex:2];
    UINavigationController *naviController3 = [[tabBarController viewControllers] objectAtIndex:3];
    
    MessageViewController *messageViewController = [[naviController0 viewControllers] objectAtIndex:0];
    ContactsViewController *contactsViewController = [[naviController1 viewControllers] objectAtIndex:0];
    SettingsViewController *settingsViewController = [[naviController2 viewControllers] objectAtIndex:0];
    MapViewController *mapViewController = [[naviController3 viewControllers] objectAtIndex:0];
    
    messageViewController.managedObjectContext = context;
    contactsViewController.managedObjectContext = context;
    settingsViewController.managedObjectContext = context;
    mapViewController.managedObjectContext = context;
    
    messageViewController.rscMgr = rscMgr;
    contactsViewController.rscMgr = rscMgr;
    settingsViewController.rscMgr = rscMgr;
    mapViewController.rscMgr = rscMgr;
    
  /*
    //create new sample contact
    Contacts *newContact = (Contacts *)[NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
    
    [newContact setAddress16:@"1234"];
    [newContact setAddress64:@"1234567890"];
    [newContact setUsername:@"richard2"];
    [newContact setUserData:@"asdfghjklzxcvbnm qwertyui"];
    [newContact setUserOrg:@"Oxfam"];
    [newContact setIsAvailable:[NSNumber numberWithBool:TRUE]];
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        // Handle the error.
    }
    //end of sample contact
   
    
    //create new sample contact2
    Contacts *newContact2 = (Contacts *)[NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
    
    [newContact2 setAddress16:@"1234"];
    [newContact2 setAddress64:@"1234567890"];
    [newContact2 setUsername:@"richard"];
    [newContact2 setUserData:@"asdfghjklzxcvbnm qwertyui"];
    [newContact2 setUserOrg:@"Red Cross"];
    
        //Create location for richard
        Location *newlocation = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
        newlocation.locationTitle = newContact2.username;
        newlocation.locationDescription = newContact2.userData;
        newlocation.locationLatitude = @"000.761708,103.359387";
        [newlocation setLocationContact:newContact2];
    
    [newContact2 setIsAvailable:[NSNumber numberWithBool:FALSE]];
    [newContact2 setContactLocation:newlocation];
    
    NSError *error1 = nil;
    if (![managedObjectContext save:&error1]) {
        // Handle the error.
    }
    //end of sample contact2
    
    
    
    //create new sample message
    Messages *newMessage = (Messages *)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:managedObjectContext];    
    newMessage.messageContents = [NSString stringWithFormat:@"%@", @"firstfirst"];
    newMessage.messageReceived = [NSNumber numberWithBool:TRUE];
    newMessage.messageDate = [NSDate date];
    newMessage.messageFromContacts = newContact2;
    NSError *error2 = nil;
    if (![managedObjectContext save:&error2]) {
        // Handle the error.
    }
    //end of sample message 1
    
    //create new sample message
    Messages *newMessage2 = (Messages *)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:managedObjectContext];    
    newMessage2.messageContents = [NSString stringWithFormat:@"%@", @"firstsecond"];
    newMessage2.messageReceived = [NSNumber numberWithBool:TRUE];
    newMessage2.messageDate = [NSDate date];
    newMessage2.messageFromContacts = newContact;
    NSError *error3 = nil;
    if (![managedObjectContext save:&error3]) {
        // Handle the error.
    }
    //end of sample message 2
    
    //create new sample message
    Messages *newMessage3 = (Messages *)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:managedObjectContext];    
    newMessage3.messageContents = [NSString stringWithFormat:@"%@", @"secondfirst"];
    newMessage3.messageReceived = [NSNumber numberWithBool:TRUE];
    newMessage3.messageDate = [NSDate date];
    newMessage3.messageFromContacts = newContact;
    NSError *error4 = nil;
    if (![managedObjectContext save:&error4]) {
        // Handle the error.
    }
    //end of sample message 2
*/    

    
    
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



#pragma mark -
#pragma mark Core Data stack


/*
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */



- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/*
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */


- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return managedObjectModel;
}


/*
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iMNet-v2.sqlite"];
    
    NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle the error.
    }    
    
    return persistentStoreCoordinator;
}

#pragma mark Application's documents directory

/*
 Returns the path to the application's documents directory.
 */


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    
    NSError *error = nil;
    NSManagedObjectContext *objectContext = self.managedObjectContext;
    if (objectContext != nil)
    {
        if ([objectContext hasChanges] && ![objectContext save:&error])
        {
            // add error handling here
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
