//
//  NetworkSettingsViewController.h
//  iMNet v2
//
//  Created by Bryan on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RscMgr.h"
#import "OwnSettings.h"
#import "XbeeTx.h"
#import "Contacts.h"
#define BUFFER_LEN 1024


@interface NetworkSettingsViewController : UITableViewController{

    RscMgr *rscMgr;
    int FrameID;
    UInt8   txBuffer[BUFFER_LEN];
    //core data instance variables
    NSManagedObjectContext *managedObjectContext;   
    IBOutlet UILabel *NetworkIDLabel;
    IBOutlet UILabel *DeviceTypeLabel;
    IBOutlet UILabel *NetworkAddressLabel;
    IBOutlet UILabel *MACAddressLabel;
    IBOutlet UILabel *UsernameLabel;
}

- (void)optionsTableUpdate:(NSNotification *)notification;
- (IBAction)updateNetworkDetails:(id)sender;

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic,retain) RscMgr *rscMgr;
@property (nonatomic,retain) UILabel *NetworkIDLabel;
@property (nonatomic,retain) UILabel *DeviceTypeLabel;
@property (nonatomic,retain) UILabel *NetworkAddressLabel;
@property (nonatomic,retain) UILabel *MACAddressLabel;
@property (nonatomic,retain) UILabel *UsernameLabel;

@end
