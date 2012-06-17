//
//  SOSViewController.h
//  iMNet v2
//
//  Created by Bryan on 12/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RscMgr.h"
#import "XbeeTx.h"

//CoreData
#import "Location.h"
#import "OwnSettings.h"
#define BUFFER_LEN 1024


@interface SOSViewController : UIViewController{
    IBOutlet UISlider *slideToUnlock;
	IBOutlet UIButton *lockButton;
	IBOutlet UILabel *myLabel;
	IBOutlet UIImageView *Container;
    IBOutlet UITextView *field;
    
    UITapGestureRecognizer *tapRecognizer;
    
    RscMgr *rscMgr;
    int FrameID;
    UInt8   txBuffer[BUFFER_LEN];

    
    //CoreData 
    NSManagedObjectContext *managedObjectContext;
}

@property (strong, nonatomic) IBOutlet UITextView *field;
@property (nonatomic, retain) UISlider *slideToUnlock;
@property (nonatomic, retain) UIButton *lockButton;
@property (nonatomic, retain) UILabel *myLabel;
@property (nonatomic, retain) UIImageView *Container;

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) RscMgr *rscMgr;

-(IBAction)UnLockIt;
-(IBAction)LockIt;
-(IBAction)fadeLabel;
- (IBAction)clearSOS:(id)sender;



@end
