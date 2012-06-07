//
//  PersonalInfoViewController.h
//  iMNet v2
//
//  Created by Bryan on 30/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OwnSettings.h"
#import "RscMgr.h"
#import "XbeeTx.h"
#define BUFFER_LEN 1024

@interface PersonalInfoViewController : UITableViewController{

    RscMgr *rscMgr;
    int FrameID;
    UInt8   txBuffer[BUFFER_LEN];
    
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *organisationField;
    IBOutlet UITextView *userDataField;
    //core data instance variables
    NSManagedObjectContext *managedObjectContext;   
    
}


- (IBAction)backButton:(id)sender;
- (IBAction)saveData:(id)sender;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic,retain) RscMgr *rscMgr;

@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *organisationField;
@property (nonatomic, retain) UITextView *userDataField;

@end
