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
#import "Contacts.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>{


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
