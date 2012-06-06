//
//  NetworkSettingsViewController.m
//  iMNet v2
//
//  Created by Bryan on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetworkSettingsViewController.h"

@implementation NetworkSettingsViewController


@synthesize managedObjectContext;
@synthesize rscMgr;
@synthesize UsernameLabel,NetworkAddressLabel,NetworkIDLabel,MACAddressLabel,DeviceTypeLabel;


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
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    FrameID = 1;

}


- (void)viewDidUnload
{
    NetworkIDLabel = nil;
    UsernameLabel = nil;
    MACAddressLabel = nil;
    NetworkAddressLabel = nil;
    DeviceTypeLabel = nil;

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
    
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"atCommand == %@",@"ID"];
    [fetchOwnSettings setPredicate:predicateID];
    
    NSError *error = nil;
    OwnSettings *fetchedID = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedID) {
        self.NetworkIDLabel.text = [NSString stringWithFormat:@"%@", [fetchedID atSetting]];
    }

    NSPredicate *predicateNI = [NSPredicate predicateWithFormat:@"atCommand == %@",@"NI"];
    [fetchOwnSettings setPredicate:predicateNI];
    
    OwnSettings *fetchedNI = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedNI) {
        self.UsernameLabel.text = [NSString stringWithFormat:@"%@", [fetchedNI atSetting]];
    }

    NSPredicate *predicateSH = [NSPredicate predicateWithFormat:@"atCommand == %@",@"SH"];
    [fetchOwnSettings setPredicate:predicateSH];
    
    OwnSettings *fetchedSH = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];

    
    NSPredicate *predicateSL = [NSPredicate predicateWithFormat:@"atCommand == %@",@"SL"];
    [fetchOwnSettings setPredicate:predicateSL];
    
    OwnSettings *fetchedSL = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedSH && fetchedSL) {
        self.MACAddressLabel.text = [NSString stringWithFormat:@"%@%@", [fetchedSH atSetting], [fetchedSL atSetting]];    
    } 
    
    NSPredicate *predicateMY = [NSPredicate predicateWithFormat:@"atCommand == %@",@"MY"];
    [fetchOwnSettings setPredicate:predicateMY];
    error = nil;
    OwnSettings *fetchedMY = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedMY) {
        self.NetworkAddressLabel.text = [NSString stringWithFormat:@"%@", [fetchedMY atSetting]];
        if ([[fetchedMY atSetting] isEqualToString:@"0000"]){
            self.DeviceTypeLabel.text = @"Coordinator";
        }
        else{
            self.DeviceTypeLabel.text = @"Router";
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(optionsTableUpdate:) name:@"optionsTableUpdate" object:nil];

    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"optionsTableUpdate" object:nil];

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

- (void)optionsTableUpdate:(NSNotification *)notification
{
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"atCommand == %@",@"ID"];
    [fetchOwnSettings setPredicate:predicateID];
    
    NSError *error = nil;
    OwnSettings *fetchedID = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedID) {
         self.NetworkIDLabel.text = [NSString stringWithFormat:@"%@", [fetchedID atSetting]];
    }
    
    NSPredicate *predicateNI = [NSPredicate predicateWithFormat:@"atCommand == %@",@"NI"];
    [fetchOwnSettings setPredicate:predicateNI];
    
    error = nil;
    OwnSettings *fetchedNI = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedNI) {
        self.UsernameLabel.text = [fetchedNI atSetting];
    }
    
    
    NSPredicate *predicateSH = [NSPredicate predicateWithFormat:@"atCommand == %@",@"SH"];
    [fetchOwnSettings setPredicate:predicateSH];
    
    error = nil;
    OwnSettings *fetchedSH = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    
    NSPredicate *predicateSL = [NSPredicate predicateWithFormat:@"atCommand == %@",@"SL"];
    [fetchOwnSettings setPredicate:predicateSL];
    
    error = nil;
    OwnSettings *fetchedSL = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedSH && fetchedSL) {
        self.MACAddressLabel.text = [NSString stringWithFormat:@"%@%@", [fetchedSH atSetting], [fetchedSL atSetting]];
    }
    
    
    NSPredicate *predicateMY = [NSPredicate predicateWithFormat:@"atCommand == %@",@"MY"];
    [fetchOwnSettings setPredicate:predicateMY];
    error = nil;
    OwnSettings *fetchedMY = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];

    if (fetchedMY) {
        self.NetworkAddressLabel.text = [NSString stringWithFormat:@"%@", [fetchedMY atSetting]];
        if ([[fetchedMY atSetting] isEqualToString:@"0000"]){
            self.DeviceTypeLabel.text = @"Coordinator";
        }
        else{
            self.DeviceTypeLabel.text = @"Router";
        }
    }
    //  [self.tableView reloadData];
    
    // Retrieve information about the document and update the panel
}

- (IBAction)updateNetworkDetails:(id)sender {
    
    XbeeTx *XbeeObj = [XbeeTx new];
    [XbeeObj ATCommand:@"ID" withFrameID:FrameID];
    NSArray *sendPacket = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacket count]; i++ ) {
        txBuffer[i] = [[sendPacket objectAtIndex:i] unsignedIntValue]; 
    }
    int bytesWritten = [rscMgr write:txBuffer Length:[sendPacket count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    
    //set up ATCommand for 16 bit network address
    [XbeeObj ATCommand:@"MY" withFrameID:FrameID];
    NSArray *sendPacketMY = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacketMY count]; i++ ) {
        txBuffer[i] = [[sendPacketMY objectAtIndex:i] unsignedIntValue]; 
    }
    bytesWritten = [rscMgr write:txBuffer Length:[sendPacketMY count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    
    //set up ATCommand for node identifier
    [XbeeObj ATCommand:@"NI" withFrameID:FrameID];
    NSArray *sendPacketNI = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacketNI count]; i++ ) {
        txBuffer[i] = [[sendPacketNI objectAtIndex:i] unsignedIntValue]; 
    }
    bytesWritten = [rscMgr write:txBuffer Length:[sendPacketNI count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    
    //set up ATCommand for 64bit serial high MAC address
    [XbeeObj ATCommand:@"SH" withFrameID:FrameID];
    NSArray *sendPacketSH = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacketSH count]; i++ ) {
        txBuffer[i] = [[sendPacketSH objectAtIndex:i] unsignedIntValue]; 
    }
    bytesWritten = [rscMgr write:txBuffer Length:[sendPacketSH count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    
    //set up ATCommand for 64bit serial low MAC address
    [XbeeObj ATCommand:@"SL" withFrameID:FrameID];
    NSArray *sendPacketSL = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacketSL count]; i++ ) {
        txBuffer[i] = [[sendPacketSL objectAtIndex:i] unsignedIntValue]; 
    }
    bytesWritten = [rscMgr write:txBuffer Length:[sendPacketSL count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    

    
}
@end
