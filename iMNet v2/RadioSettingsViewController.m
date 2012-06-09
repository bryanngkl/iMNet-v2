//
//  RadioSettingsViewController.m
//  iMNet v2
//
//  Created by Bryan on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RadioSettingsViewController.h"


@implementation RadioSettingsViewController
@synthesize PowerLevelLabel,RSSILabel,SupplyVoltageLabel;
@synthesize managedObjectContext;
@synthesize rscMgr;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    FrameID = 1;
    
    //set up AT command for power level
    XbeeTx *XbeeObj = [XbeeTx new];
    [XbeeObj ATCommand:@"PL" withFrameID:FrameID];
    NSArray *sendPacketPL = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacketPL count]; i++ ) {
        txBuffer[i] = [[sendPacketPL objectAtIndex:i] unsignedIntValue]; 
    }
    int bytesWritten = [rscMgr write:txBuffer Length:[sendPacketPL count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    
    //set up ATCommand received signal strength
    [XbeeObj ATCommand:@"DB" withFrameID:FrameID];
    NSArray *sendPacketDB = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacketDB count]; i++ ) {
        txBuffer[i] = [[sendPacketDB objectAtIndex:i] unsignedIntValue]; 
    }
    bytesWritten = [rscMgr write:txBuffer Length:[sendPacketDB count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    
    //set up ATCommand for finding supply voltage of device
    [XbeeObj ATCommand:@"%V" withFrameID:FrameID];
    NSArray *sendPacketV = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacketV count]; i++ ) {
        txBuffer[i] = [[sendPacketV objectAtIndex:i] unsignedIntValue]; 
    }
    bytesWritten = [rscMgr write:txBuffer Length:[sendPacketV count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }

    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    PowerLevelLabel = nil;
    RSSILabel = nil;
    SupplyVoltageLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Load settings from core data
    
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    
    NSPredicate *predicatePL = [NSPredicate predicateWithFormat:@"atCommand == %@",@"PL"];
    [fetchOwnSettings setPredicate:predicatePL];
    
    NSError *error = nil;
    OwnSettings *fetchedPL = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedPL) {
        if ((int)[[fetchedPL atSetting] characterAtIndex:0] == 4)  {
            self.PowerLevelLabel.text = [NSString stringWithFormat:@"%i (max)", (int)[[fetchedPL atSetting] characterAtIndex:0]];
        } else {
            self.PowerLevelLabel.text = [NSString stringWithFormat:@"%i", (int)[[fetchedPL atSetting] characterAtIndex:0]];
        }
    }
    
    NSPredicate *predicateDB = [NSPredicate predicateWithFormat:@"atCommand == %@",@"DB"];
    [fetchOwnSettings setPredicate:predicateDB];
    
    OwnSettings *fetchedDB = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedDB) {
        self.RSSILabel.text = [NSString stringWithFormat:@"-%i dbm", (int)[[fetchedDB atSetting] characterAtIndex:0]];
    }
    
    NSPredicate *predicateV = [NSPredicate predicateWithFormat:@"atCommand == %@",@"%V"];
    [fetchOwnSettings setPredicate:predicateV];
    
    OwnSettings *fetchedV = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedV) {
        float temp = ((int)[[fetchedV atSetting] characterAtIndex:0] * 256 + (int)[[fetchedV atSetting] characterAtIndex:1]) * 1.200/1024;
        self.SupplyVoltageLabel.text = [NSString stringWithFormat:@"%.2fV", temp];
        }
    
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(powerTableUpdate:) name:@"powerSettings" object:nil];
    
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"powerSettings" object:nil];
    
    [super viewWillDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}
*/
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}
                                        
- (void)powerTableUpdate:(NSNotification *)notification{
    // Load settings from core data

    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    
    NSPredicate *predicatePL = [NSPredicate predicateWithFormat:@"atCommand == %@",@"PL"];
    [fetchOwnSettings setPredicate:predicatePL];
    
    NSError *error = nil;
    OwnSettings *fetchedPL = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedPL) {
        if ((int)[[fetchedPL atSetting] characterAtIndex:0] == 4)  {
            self.PowerLevelLabel.text = [NSString stringWithFormat:@"%i (max)", (int)[[fetchedPL atSetting] characterAtIndex:0]];
        } else {
            self.PowerLevelLabel.text = [NSString stringWithFormat:@"%i", (int)[[fetchedPL atSetting] characterAtIndex:0]];
        }
        
    }
    
    NSPredicate *predicateDB = [NSPredicate predicateWithFormat:@"atCommand == %@",@"DB"];
    [fetchOwnSettings setPredicate:predicateDB];
    
    OwnSettings *fetchedDB = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedDB) {
        self.RSSILabel.text = [NSString stringWithFormat:@"-%i dbm", (int)[[fetchedDB atSetting] characterAtIndex:0]];
    }
    
    NSPredicate *predicateV = [NSPredicate predicateWithFormat:@"atCommand == %@",@"%V"];
    [fetchOwnSettings setPredicate:predicateV];
    
    OwnSettings *fetchedV = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedV) {
        float temp = ((int)[[fetchedV atSetting] characterAtIndex:0] * 256 + (int)[[fetchedV atSetting] characterAtIndex:1]) * 1.200/1024;
        self.SupplyVoltageLabel.text = [NSString stringWithFormat:@"%.2fV", temp];
    }                   
}


- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updatePowerSettings:(id)sender {
    //set up AT command for power level
    XbeeTx *XbeeObj = [XbeeTx new];
    [XbeeObj ATCommand:@"PL" withFrameID:FrameID];
    NSArray *sendPacketPL = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacketPL count]; i++ ) {
        txBuffer[i] = [[sendPacketPL objectAtIndex:i] unsignedIntValue]; 
    }
    int bytesWritten = [rscMgr write:txBuffer Length:[sendPacketPL count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    
    //set up ATCommand received signal strength
    [XbeeObj ATCommand:@"DB" withFrameID:FrameID];
    NSArray *sendPacketDB = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacketDB count]; i++ ) {
        txBuffer[i] = [[sendPacketDB objectAtIndex:i] unsignedIntValue]; 
    }
    bytesWritten = [rscMgr write:txBuffer Length:[sendPacketDB count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    
    //set up ATCommand for finding supply voltage of device
    [XbeeObj ATCommand:@"%V" withFrameID:FrameID];
    NSArray *sendPacketV = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacketV count]; i++ ) {
        txBuffer[i] = [[sendPacketV objectAtIndex:i] unsignedIntValue]; 
    }
    bytesWritten = [rscMgr write:txBuffer Length:[sendPacketV count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
}
@end
