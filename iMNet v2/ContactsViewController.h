//
//  ContactsViewController.h
//  iMNet v2
//
//  Created by Bryan on 30/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contacts.h"
#import "ContactDetailsViewController.h"
#import "RscMgr.h"
#import "XbeeTx.h"

#import "MBProgressHUD.h"

#define BUFFER_LEN 1024


@interface ContactsViewController : UITableViewController<MBProgressHUDDelegate>{

    //redpark instance variables
    RscMgr *rscMgr;
    int FrameID;
    UInt8   txBuffer[BUFFER_LEN];
    
    //core data instance variables
    NSManagedObjectContext *managedObjectContext;   
    
    NSMutableArray *fetchedContactsArray;
    
    MBProgressHUD *HUD;
}

- (void)contactTableUpdate:(NSNotification *)notification;

- (IBAction)contactDiscovery:(id)sender;

- (void)contactDiscoveryTask;

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic,retain) RscMgr *rscMgr;

@end
