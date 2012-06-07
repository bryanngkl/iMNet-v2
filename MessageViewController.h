//
//  MessageViewController.h
//  iMNet v2
//
//  Created by Bryan on 30/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contacts.h"
#import "Messages.h"
#import "Location.h"
#import "OwnSettings.h"
#import "Images.h"

#import "NewMsgContactsViewController.h"
#import "MessageLogViewController.h"
#import "RscMgr.h"
#import "XbeeRx.h"
#import "XbeeTx.h"
#import "hexConvert.h"

#define BUFFER_LEN 1024


@interface MessageViewController : UITableViewController{
    
    //redpark instance variables
    RscMgr *rscMgr;
    int FrameID;
    UInt8   rxBuffer[BUFFER_LEN];
    UInt8   txBuffer[BUFFER_LEN];
    NSMutableArray *rxPacketBuffer;     //Temporary storage of bytes while rxBuffer is accumulating a packet
    
    NSString *testString;
    
    
    
    //core data instance variables
    NSManagedObjectContext *managedObjectContext;   
    NSMutableArray *fetchedContactsArray;
    NSMutableArray *fetchedMessagesArray;
    
}

- (void)messageReceivedUpdate:(NSNotification *)notification;


@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic,retain) RscMgr *rscMgr;
@property (nonatomic,retain) NSString *testString;

@end
