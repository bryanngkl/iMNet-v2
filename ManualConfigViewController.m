//
//  ManualConfigViewController.m
//  iMNet v2
//
//  Created by Bryan on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ManualConfigViewController.h"

@implementation ManualConfigViewController
@synthesize rscMgr;
@synthesize bytesToSend,displayBytes;
@synthesize managedObjectContext;

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
	// Do any additional setup after loading the view.
}



- (void)viewDidUnload
{
    bytesToSend = nil;
    displayBytes = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)viewWillAppear:(BOOL)animated
{
    // Load settings from core data
    
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    
    NSPredicate *predicateBS = [NSPredicate predicateWithFormat:@"atCommand == %@",@"byteString"];
    [fetchOwnSettings setPredicate:predicateBS];
    
    NSError *error = nil;
    OwnSettings *fetchedBS = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedBS) {
        self.displayBytes.text = [NSString stringWithFormat:@"%@", [fetchedBS atSetting]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bytesReceivedUpdate:) name:@"bytesReceivedUpdate" object:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"bytesReceivedUpdate" object:nil];
    
    [super viewWillDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (bytesToSend.editing){
        [bytesToSend resignFirstResponder];
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)bytesReceivedUpdate:(NSNotification *)notification{
    // Load settings from core data
    
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    
    NSPredicate *predicateBS = [NSPredicate predicateWithFormat:@"atCommand == %@",@"byteString"];
    [fetchOwnSettings setPredicate:predicateBS];
    
    NSError *error = nil;
    OwnSettings *fetchedBS = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedBS) {
        self.displayBytes.text = [NSString stringWithFormat:@"%@", [fetchedBS atSetting]];
    }
}


- (IBAction)sendHex:(id)sender {
    XbeeTx *XbeeObj = [XbeeTx new];
    [XbeeObj TxRawApi:self.bytesToSend.text];
    NSArray *sendPacket = [XbeeObj txPacket];
    
    for ( int i = 0; i < (int)[sendPacket count]; i++ ) {
        txBuffer[i] = [[sendPacket objectAtIndex:i] unsignedIntValue];
    }
    int bytesWritten = [rscMgr write:txBuffer Length:[sendPacket count]];
}
@end
