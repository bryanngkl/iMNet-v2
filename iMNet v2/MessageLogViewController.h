//
//  MessageLogViewController.h
//  iMNet v2
//
//  Created by Bryan on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageViewController.h"
#import "hexConvert.h"

#import "RscMgr.h"
#define BUFFER_LEN 1024


//CoreData
#import "Messages.h"

@interface MessageLogViewController : UITableViewController{
    IBOutlet UITableView *tbl;
    IBOutlet UITextField *field;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *sendbutton;
    NSMutableArray *messages;
    NSMutableArray *messagefromselectedcontact;
    NSArray *sortedMessages;
    
    BOOL startup;
    UITapGestureRecognizer *tapRecognizer;
    
    RscMgr *rscMgr;
    int FrameID;
    UInt8   txBuffer[BUFFER_LEN];


    //core data instance variables
    NSManagedObjectContext *managedObjectContext; 
    Contacts *currentContact;
    
}

- (void)messageReceivedUpdate:(NSNotification *)notification;

- (IBAction)add:(id)sender;
- (IBAction)goBack:(id)sender;
@property (nonatomic, retain) UITableView *tbl;
@property (nonatomic, retain) UITextField *field;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSMutableArray *messages;

@property (nonatomic,retain) RscMgr *rscMgr;

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext; 
@property (nonatomic,retain) NSMutableArray *messagefromselectedcontact;
@property (nonatomic,retain) NSArray *sortedMessages;

@property (nonatomic,retain) Contacts *currentContact;


@end
