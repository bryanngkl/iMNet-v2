//
//  ManualConfigViewController.h
//  iMNet v2
//
//  Created by Bryan on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RscMgr.h"
#import "XbeeTx.h"
#import "OwnSettings.h"
#define BUFFER_LEN 1024


@interface ManualConfigViewController : UIViewController{

    RscMgr *rscMgr;
    int FrameID;
    UInt8   txBuffer[BUFFER_LEN];
    IBOutlet UITextField *bytesToSend;
    IBOutlet UITextView *displayBytes;
    
    //core data instance variables
    NSManagedObjectContext *managedObjectContext;   
}

- (IBAction)sendHex:(id)sender;
- (void)bytesReceivedUpdate:(NSNotification *)notification;

@property (nonatomic,retain) RscMgr *rscMgr;
@property (nonatomic,retain) UITextField *bytesToSend;
@property (nonatomic,retain) UITextView *displayBytes;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;  
@end
