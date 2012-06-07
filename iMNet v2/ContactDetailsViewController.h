//
//  ContactDetailsViewController.h
//  iMNet v2
//
//  Created by Bryan on 30/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contacts.h"
#import "RscMgr.h"
#import "XbeeTx.h"
#define BUFFER_LEN 1024


@interface ContactDetailsViewController : UITableViewController{
    NSManagedObjectContext *managedObjectContext;   
    Contacts *currentContact;
    IBOutlet UILabel *userName;
    IBOutlet UILabel *userOrganisation;
    IBOutlet UITextView *userData;
    
    RscMgr *rscMgr;
    int FrameID;
    UInt8   txBuffer[BUFFER_LEN];
    
}

- (IBAction)requestUserInfo:(id)sender;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic,retain) Contacts *currentContact;  

@property (nonatomic,retain) RscMgr *rscMgr;

@property (nonatomic,retain) UILabel *userName;
@property (nonatomic,retain) UILabel *userOrganisation;
@property (nonatomic,retain) UITextView *userData;


@end
