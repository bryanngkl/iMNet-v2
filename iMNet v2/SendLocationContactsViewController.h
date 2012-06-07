//
//  SendLocationContactsViewController.h
//  iMNet v2
//
//  Created by Bryan on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contacts.h"
#import "RscMgr.h"
#import "XbeeTx.h"
#define BUFFER_LEN 1024


@interface SendLocationContactsViewController : UITableViewController{

    RscMgr *rscMgr;
    int FrameID;
    UInt8   txBuffer[BUFFER_LEN];
    NSString *stringToSend;


    //core data instance variables
    NSManagedObjectContext *managedObjectContext;   

    NSMutableArray *fetchedContactsArray;
    }

- (void)contactTableUpdate:(NSNotification *)notification;
- (IBAction)contactDiscovery:(id)sender;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic,retain) RscMgr *rscMgr;
@property (nonatomic,retain) NSString *stringToSend;


@end
