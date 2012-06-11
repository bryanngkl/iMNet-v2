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
#define BUFFER_LEN 1024

#import "MBProgressHUD.h"


@interface NetworkSettingsViewController : UITableViewController<MBProgressHUDDelegate>{

    RscMgr *rscMgr;
    int FrameID;
    UInt8   txBuffer[BUFFER_LEN];
    //core data instance variables
    NSManagedObjectContext *managedObjectContext;   
    
    IBOutlet UILabel *ChannelLabel;
    IBOutlet UILabel *NetworkIDLabel;
    IBOutlet UILabel *UsernameLabel;
    IBOutlet UILabel *DeviceTypeLabel;
    IBOutlet UILabel *NetworkAddressLabel;
    IBOutlet UILabel *MACAddressLabel;
    
    MBProgressHUD *HUD;
}

- (void)optionsTableUpdate:(NSNotification *)notification;
- (IBAction)updateNetworkDetails:(id)sender;
- (IBAction)backButton:(id)sender;
- (IBAction)retryATSC:(id)sender;

- (void)updateNetworkDetailsTask;
- (void)ChangeNetworkIDTask:(NSString *)infoEntered;


@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic,retain) RscMgr *rscMgr;
@property (nonatomic,retain) UILabel *NetworkIDLabel;
@property (nonatomic,retain) UILabel *DeviceTypeLabel;
@property (nonatomic,retain) UILabel *NetworkAddressLabel;
@property (nonatomic,retain) UILabel *MACAddressLabel;
@property (nonatomic,retain) UILabel *UsernameLabel;
@property (nonatomic,retain) UILabel *ChannelLabel;
@end
