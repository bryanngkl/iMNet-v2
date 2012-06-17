//
//  AppDelegate.h
//  iMNet v2
//
//  Created by Bryan on 30/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsViewController.h"
#import "MessageViewController.h"
#import "SettingsViewController.h"
#import "MapViewController.h"
#import "SOSViewController.h"
#import "Contacts.h"
#import "Messages.h"
#import "RscMgr.h"
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{

    RscMgr *rscMgr;

    //core data objects
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;   

}



@property (strong, nonatomic) UIWindow *window;
    //core data methods
- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;



@end
