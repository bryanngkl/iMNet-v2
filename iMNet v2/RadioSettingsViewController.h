//
//  RadioSettingsViewController.h
//  iMNet v2
//
//  Created by Bryan on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RscMgr.h"
#import "OwnSettings.h"
#import "XbeeTx.h"
#import "Contacts.h"
#define BUFFER_LEN 1024

@interface RadioSettingsViewController : UITableViewController{

    RscMgr *rscMgr;
    int FrameID;
    UInt8   txBuffer[BUFFER_LEN];
    //core data instance variables
    NSManagedObjectContext *managedObjectContext;   

    IBOutlet UILabel *PowerLevelLabel;
    IBOutlet UILabel *RSSILabel;
    IBOutlet UILabel *SupplyVoltageLabel;
}

- (void)powerTableUpdate:(NSNotification *)notification;
- (IBAction)backButton:(id)sender;
- (IBAction)updatePowerSettings:(id)sender;

@property (nonatomic,retain) UILabel *PowerLevelLabel;
@property (nonatomic,retain) UILabel *RSSILabel;
@property (nonatomic,retain) UILabel *SupplyVoltageLabel;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic,retain) RscMgr *rscMgr;


@end
