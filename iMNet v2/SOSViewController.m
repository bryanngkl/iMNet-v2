//
//  SOSViewController.m
//  iMNet v2
//
//  Created by Bryan on 12/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SOSViewController.h"

@interface SOSViewController ()

@end

@implementation SOSViewController
@synthesize field;

@synthesize slideToUnlock, myLabel, lockButton, Container;
@synthesize  managedObjectContext, rscMgr; 

BOOL SOSCalled = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    FrameID = 1;
    [super viewDidLoad];
	// initialize custom UISlider (you have to do this in viewdidload or applicationdidfinishlaunching.
	UIImage *stetchLeftTrack= [[UIImage imageNamed:@"Nothing.png"]
                               stretchableImageWithLeftCapWidth:30.0 topCapHeight:0.0];
	UIImage *stetchRightTrack= [[UIImage imageNamed:@"Nothing.png"]
                                stretchableImageWithLeftCapWidth:30.0 topCapHeight:0.0];
	[slideToUnlock setThumbImage: [UIImage imageNamed:@"SlideToStop.png"] forState:UIControlStateNormal];
	[slideToUnlock setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
	[slideToUnlock setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification object:self.view.window]; 
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(didTapAnywhere:)];
    field.delegate = self;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    //Check if SOS was called before the initial startup, ie before power off
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    NSError *error = nil;
    NSPredicate *predicateUsername = [NSPredicate predicateWithFormat:@"atCommand == %@",@"NI"];
    [fetchOwnSettings setPredicate:predicateUsername];
    
    OwnSettings *fetchedUsername = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    // NSString *username;
    //if (fetchedUsername) {
    //This method creates a new setting.
    
    if ([fetchedUsername.atSetting length] >= 7){
        if ([[fetchedUsername.atSetting substringToIndex:7] isEqualToString:@"(SOS)--"]){
            self.title = @"SOS Called";
            SOSCalled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
    
    if (![managedObjectContext save:&error]) {
        // Handle the error.
    }

    
}

-(IBAction)LockIt {
	slideToUnlock.hidden = NO;
	lockButton.hidden = YES;
	Container.hidden = NO;
	myLabel.hidden = NO;
	myLabel.alpha = 1.0;
	//UNLOCKED = NO;
	slideToUnlock.value = 0.0;
	NSString *str = @"The iPhone is Locked!";
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SOS" message:str delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
}

-(IBAction)fadeLabel {
    
	myLabel.alpha = 1.0 - slideToUnlock.value;
	
}

- (IBAction)clearSOS:(id)sender {
    self.title = @"SOS";
    SOSCalled = NO;
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    NSError *error = nil;
    NSPredicate *predicateUsername = [NSPredicate predicateWithFormat:@"atCommand == %@",@"NI"];
    [fetchOwnSettings setPredicate:predicateUsername];
    
    OwnSettings *fetchedUsername = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
   // NSString *username;
    //if (fetchedUsername) {
        //This method creates a new setting.
    
        NSString *separator = @"--";
        NSString *username = [[fetchedUsername.atSetting componentsSeparatedByString:separator] objectAtIndex:1];
        fetchedUsername.atSetting = username;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }

    //CREATE STRING TO SEND
    NSString *organisation = [[NSString alloc] init];
    NSString *message = [[NSString alloc] initWithString:@"Clear SOS.Out of danger."];
    NSString *location = [[NSString alloc] init];
    
    /*----GET OWN SETTINGS----*/
    
    //Fetch organisation
    NSPredicate *predicateOrg = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserOrg"];
    [fetchOwnSettings setPredicate:predicateOrg];
    
    error = nil;
    OwnSettings *fetchedOrg = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedOrg) {
        organisation = [fetchedOrg atSetting];
    }
    
    //Fetch Own location
    NSPredicate *predicateUserLocation = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserLocation"];
    [fetchOwnSettings setPredicate:predicateUserLocation];
    OwnSettings *fetchedUserLocation = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedUserLocation) {
        location = [NSString stringWithFormat:@"%@", [fetchedUserLocation atSetting]];
    }
    
    
    //Create the string to send
    NSMutableString *strtosend = [NSMutableString stringWithString:username];
    [strtosend appendString:@"*"];
    [strtosend appendString:organisation];
    //[strtosend appendString:@"*"];
    //[strtosend appendString:macaddress];
    [strtosend appendString:@"*"];
    [strtosend appendString:location];
    [strtosend appendString:@"*"];
    [strtosend appendString:message];
    
    //Broadcast SOS message
    XbeeTx *XbeeObj = [XbeeTx new];
    [XbeeObj TxMessage:strtosend ofSize:0 andMessageType:5 withStartID:FrameID withFrameID:FrameID withPacketFrameId:FrameID withDestNode64:[[hexConvert alloc] convertStringToArray:@"000000000000FFFF"] withDestNetworkAddr16:[[hexConvert alloc] convertStringToArray:@"FFFE"]];
    
    NSArray *sendPacket = [XbeeObj txPacket];    
    for ( int i = 0; i < (int)[sendPacket count]; i++ ) {
        txBuffer[i] = [[sendPacket objectAtIndex:i] unsignedIntValue];
    }
    int bytesWritten = [rscMgr write:txBuffer Length:[sendPacket count]];
    
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }  

    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    //Save Changes to Zigbee
    XbeeTx *XbeeObj2 = [XbeeTx new];
    //set up ATCommand for PAN ID
    [XbeeObj2 ATCommandSetString:@"NI" withParameter:username withFrameID:FrameID];
    NSArray *sendPacket2 = [XbeeObj2 txPacket];
    for ( int i = 0; i< (int)[sendPacket2 count]; i++ ) {
        txBuffer[i] = [[sendPacket2 objectAtIndex:i] unsignedIntValue]; 
    }
    int bytesWritten2 = [rscMgr write:txBuffer Length:[sendPacket2 count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    
    //save changes permanently
    [XbeeObj2 ATCommand:@"WR" withFrameID:FrameID];
    NSArray *sendPacketWR = [XbeeObj2 txPacket];
    for ( int i = 0; i< (int)[sendPacketWR count]; i++ ) {
        txBuffer[i] = [[sendPacketWR objectAtIndex:i] unsignedIntValue]; 
    }
    bytesWritten2 = [rscMgr write:txBuffer Length:[sendPacketWR count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"optionsTableUpdate" object:self];
    
    
    NSString *str = @"SOS CLEAR Message Sent!";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SOS" message:str delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}


-(IBAction)UnLockIt {
		if (slideToUnlock.value == 1.0) {  // if user slide far enough, stop the operation	
            // Put here what happens when it is unlocked
            
            NSString *macaddress = [[NSString alloc] init];
            NSString *organisation = [[NSString alloc] init];
            NSString *name = [[NSString alloc] init];
            NSString *message = [[NSString alloc] init];
            NSString *location = [[NSString alloc] init];
            
            
            message = field.text;
            
            /*----GET OWN SETTINGS----*/
            //Fetch Mac address
            NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
            NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
            [fetchOwnSettings setEntity:ownSettingsEntity];
            NSError *error = nil;
            NSPredicate *predicateSH = [NSPredicate predicateWithFormat:@"atCommand == %@",@"SH"];
            [fetchOwnSettings setPredicate:predicateSH];
            
            OwnSettings *fetchedSH = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
            
            NSPredicate *predicateSL = [NSPredicate predicateWithFormat:@"atCommand == %@",@"SL"];
            [fetchOwnSettings setPredicate:predicateSL];
            
            OwnSettings *fetchedSL = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
            if (fetchedSH && fetchedSL) {
                macaddress = [NSString stringWithFormat:@"%@%@", [fetchedSH atSetting], [fetchedSL atSetting]];    
            }
            
            //Fetch organisation
            NSPredicate *predicateOrg = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserOrg"];
            [fetchOwnSettings setPredicate:predicateOrg];
            
            error = nil;
            OwnSettings *fetchedOrg = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
            
            if (fetchedOrg) {
                organisation = [fetchedOrg atSetting];
            }
            
            //Fetch username
            NSPredicate *predicateUsername = [NSPredicate predicateWithFormat:@"atCommand == %@",@"NI"];
            [fetchOwnSettings setPredicate:predicateUsername];
            
            OwnSettings *fetchedUsername = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
            if (fetchedUsername) {
               name = [NSString stringWithFormat:@"%@", [fetchedUsername atSetting]];
            }
            
            //Fetch Own location
            NSPredicate *predicateUserLocation = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserLocation"];
            [fetchOwnSettings setPredicate:predicateUserLocation];
            OwnSettings *fetchedUserLocation = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
            
            if (fetchedUserLocation) {
                location = [NSString stringWithFormat:@"%@", [fetchedUserLocation atSetting]];
            }
            
            
            //Create the string to send

            NSMutableString *strtosend2 = [NSMutableString alloc];
            
            
            if (SOSCalled == NO){
            //Update own username
            if (fetchedUsername) {
                //This method creates a new setting.
                fetchedUsername.atSetting = [NSString stringWithFormat:@"(SOS)--%@",name];
                NSMutableString *strtosend = [NSMutableString stringWithString:@"(SOS)--"];
                [strtosend appendString:name];
                [strtosend appendString:@"*"];
                [strtosend appendString:organisation];
                //[strtosend appendString:@"*"];
                //[strtosend appendString:macaddress];
                [strtosend appendString:@"*"];
                [strtosend appendString:location];
                [strtosend appendString:@"*"];
                [strtosend appendString:message];
                strtosend2 = strtosend;
                NSLog(@"This is the string to send %@", strtosend);
                NSError *error = nil;
                if (![managedObjectContext save:&error]) {
                    // Handle the error.
                }
            }
            else{
                OwnSettings *newSettings = (OwnSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
                
                [newSettings setAtCommand:@"NI"];
                [newSettings setAtSetting:[NSString stringWithFormat:@"(SOS)--%@",name]];
                NSError *error = nil;
                if (![managedObjectContext save:&error]) {
                    // Handle the error.
                }
            }
            }
            else {
                NSMutableString *strtosend = [NSMutableString stringWithString:name];
                [strtosend appendString:@"*"];
                [strtosend appendString:organisation];
                //[strtosend appendString:@"*"];
                //[strtosend appendString:macaddress];
                [strtosend appendString:@"*"];
                [strtosend appendString:location];
                [strtosend appendString:@"*"];
                [strtosend appendString:message];
                strtosend2 = strtosend;
               
            }
             NSLog(@"This is the string to send2 %@", strtosend2);
            //Broadcast SOS message
            XbeeTx *XbeeObj = [XbeeTx new];
            [XbeeObj TxMessage:strtosend2 ofSize:0 andMessageType:5 withStartID:FrameID withFrameID:FrameID withPacketFrameId:FrameID withDestNode64:[[hexConvert alloc] convertStringToArray:@"000000000000FFFF"] withDestNetworkAddr16:[[hexConvert alloc] convertStringToArray:@"FFFE"]];
            
            NSArray *sendPacket = [XbeeObj txPacket];    
            for ( int i = 0; i < (int)[sendPacket count]; i++ ) {
                txBuffer[i] = [[sendPacket objectAtIndex:i] unsignedIntValue];
            }
            int bytesWritten = [rscMgr write:txBuffer Length:[sendPacket count]];
            
            FrameID = FrameID + 1;  //increment FrameID
            if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
                FrameID = 1;
            }     
            
            
            //Save Changes to Zigbee
            XbeeTx *XbeeObj2 = [XbeeTx new];
            
            NSString *separator = @"*";
            
            
            //set up ATCommand for PAN ID
            [XbeeObj2 ATCommandSetString:@"NI" withParameter:[[strtosend2 componentsSeparatedByString:separator]objectAtIndex:0]  withFrameID:FrameID];
             NSArray *sendPacket2 = [XbeeObj2 txPacket];
             for ( int i = 0; i< (int)[sendPacket2 count]; i++ ) {
                 txBuffer[i] = [[sendPacket2 objectAtIndex:i] unsignedIntValue]; 
             }
             int bytesWritten2 = [rscMgr write:txBuffer Length:[sendPacket2 count]];
             FrameID = FrameID + 1;  //increment FrameID
             if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
                 FrameID = 1;
             }
             
             //save changes permanently
             [XbeeObj2 ATCommand:@"WR" withFrameID:FrameID];
             NSArray *sendPacketWR = [XbeeObj2 txPacket];
             for ( int i = 0; i< (int)[sendPacketWR count]; i++ ) {
                 txBuffer[i] = [[sendPacketWR objectAtIndex:i] unsignedIntValue]; 
             }
             bytesWritten2 = [rscMgr write:txBuffer Length:[sendPacketWR count]];
             FrameID = FrameID + 1;  //increment FrameID
             if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
                 FrameID = 1;
             }
             
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"optionsTableUpdate" object:self];
            
        
            
            NSString *str = @"SOS Message Sent!";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SOS" message:str delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            
            //Reset slider bar
            [UIView beginAnimations: @"SlideCanceled" context: nil];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDuration: 0.35];
			// use CurveEaseOut to create "spring" effect
			[UIView setAnimationCurve: UIViewAnimationCurveEaseOut];	
			slideToUnlock.value = 0.0;
            myLabel.alpha=1.0;
            self.title = @"SOS CALLED!";
			self.navigationItem.rightBarButtonItem.enabled = YES;
            SOSCalled = YES;
			[UIView commitAnimations];
            
		} 
        else { 
			// user did not slide far enough, so return back to 0 position
			[UIView beginAnimations: @"SlideCanceled" context: nil];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDuration: 0.35];
			// use CurveEaseOut to create "spring" effect
			[UIView setAnimationCurve: UIViewAnimationCurveEaseOut];	
			slideToUnlock.value = 0.0;
            myLabel.alpha = 1.0;
			
			[UIView commitAnimations];
			
			
		}
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    [self.view addGestureRecognizer:tapRecognizer];
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:tapRecognizer];
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {    
    [field resignFirstResponder];
}

- (void)viewDidUnload
{
    [self setField:nil];
    field = nil;
    
    //Deregister the keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil]; 
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
