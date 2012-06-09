//
//  MessageViewController.m
//  iMNet v2
//
//  Created by Bryan on 30/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageViewController.h"


@implementation MessageViewController

@synthesize managedObjectContext;
@synthesize rscMgr;
@synthesize testString;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    FrameID = 1;
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [rscMgr setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceivedUpdate:) name:@"messageReceived" object:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messageReceived" object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSFetchRequest *fetchContacts = [[NSFetchRequest alloc] init];
    NSEntityDescription *contactsEntity = [NSEntityDescription entityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
    [fetchContacts setEntity:contactsEntity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchContacts setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSMutableArray *fetchedResultArray = [[managedObjectContext executeFetchRequest:fetchContacts error:&error] mutableCopy];
    fetchedContactsArray = fetchedResultArray;

    NSMutableArray *messagesArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *sortedMessages = [NSArray alloc];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:FALSE];
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    
    
    for (int i=0; i<[fetchedContactsArray count]; i++) {
        if ([[[fetchedContactsArray objectAtIndex:i] contactMessages] count] > 0) {
            sortedMessages = [[[fetchedContactsArray objectAtIndex:i] contactMessages] sortedArrayUsingDescriptors:sortDescriptors1];
            [messagesArray addObject:[sortedMessages objectAtIndex:0]];
        }
    }
    
    [messagesArray sortUsingDescriptors:sortDescriptors1];
    
    fetchedMessagesArray = messagesArray;
    
    return [messagesArray count];    // Return the number of rows in the section.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:100];
    usernameLabel.text = [[[fetchedMessagesArray objectAtIndex:indexPath.row] messageFromContacts] username];
    UILabel *messageLabel = (UILabel *)[cell viewWithTag:101];
    messageLabel.text = [[fetchedMessagesArray objectAtIndex:indexPath.row] messageContents];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:102];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yy',' HH:mm"];
    
    dateLabel.text = [dateFormatter stringFromDate:[[fetchedMessagesArray objectAtIndex:indexPath.row] messageDate]]; 
    
    
    return cell;
}

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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        
        Contacts *contactToDelete = [[fetchedMessagesArray objectAtIndex:indexPath.row] messageFromContacts];
                
        for (Messages *eachMessage in [contactToDelete contactMessages]) {
            [managedObjectContext deleteObject:eachMessage];
        }
        
        NSError *error1 = nil;
        if (![managedObjectContext save:&error1]) {
            // Handle the error.
        }

		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    NSLog(@"a row was selected");
    
}



#pragma mark Transiting to MessageLog

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"MessageLogSegue"]) {
        MessageLogViewController *mlVC = (MessageLogViewController *)[segue destinationViewController];
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        
        
    
        //UITableViewCell *tableviewcell =  [self.tableView cellForRowAtIndexPath:selectedRowIndex];
        
        //NSString *username = [[[fetchedMessagesArray objectAtIndex:selectedRowIndex.row] messageFromContacts] username];

        //NSLog(@"%@",username);
        
        mlVC.currentContact = [[fetchedMessagesArray objectAtIndex:[selectedRowIndex row]] messageFromContacts];
           
        mlVC.managedObjectContext = managedObjectContext;
        mlVC.rscMgr = rscMgr;
        
        NSLog(@"Passed Managed object context");
    }
    
    if ([segue.identifier isEqualToString:@"NewMsgContactsSegue"]) {
        
        NewMsgContactsViewController *nmcVC = (NewMsgContactsViewController *)[segue destinationViewController];
        nmcVC.managedObjectContext = managedObjectContext;
        nmcVC.rscMgr = rscMgr;
            }
}

- (void)messageReceivedUpdate:(NSNotification *)notification{
    [self.tableView reloadData];
    // Retrieve information about the document and update the panel
}

#pragma mark - RscMgrDelegate methods

-(void) cableConnected:(NSString *)protocol{
    [rscMgr setBaud:57600];
    [rscMgr open];
}

-(void) cableDisconnected{

}

-(void) portStatusChanged{

}

-(void) readBytesAvailable:(UInt32)numBytes{
    int bytesRead = [rscMgr read:rxBuffer Length:numBytes]; 

    NSMutableArray *rxPackBuf;

    if ([rxPacketBuffer count] == 0){
        rxPackBuf = [[NSMutableArray alloc] initWithCapacity:1];    //if empty, initialise array
    }
    else{
        rxPackBuf = [[NSMutableArray alloc] initWithArray:rxPacketBuffer];  //if not empty, initialise array with previous received bytes
    }
    for (int i = 0; i < numBytes; ++i) {
        [rxPackBuf addObject:[NSNumber numberWithUnsignedChar:rxBuffer[i]]];
    }

    int packetLength = [[rxPackBuf objectAtIndex:1] unsignedIntValue] + [[rxPackBuf objectAtIndex:2] unsignedIntValue] + 4;
    //calculate length of entire packet

    if ([rxPackBuf count] >= packetLength){
        NSIndexSet *onePacketIndexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, packetLength)]; //location 0, length of packetLength
        NSMutableArray  *rxOnePacket = [[NSMutableArray alloc] initWithArray:[rxPackBuf objectsAtIndexes:onePacketIndexes]];
        [rxPackBuf removeObjectsAtIndexes:onePacketIndexes];

        rxPacketBuffer = rxPackBuf;     //save the remainding bytes of packbuf for the next packet

        XbeeRx *XbeeRxObj = [XbeeRx new];
        [XbeeRxObj createRxInfo:rxOnePacket];   //load bytes into xbee receive object
        
        NSString *test = [[NSString alloc] init];
        
        for (int i = 0; i < [rxOnePacket count]; ++i) {
            test = [NSString stringWithFormat:@"%@%.2x",test, [[rxOnePacket objectAtIndex:i] unsignedIntValue]];
        } 
        
        switch ([[XbeeRxObj frametype] unsignedIntValue]) {     //sort out frametypes
            case 136:    //frame is a zigbee receive AT command packet
                //if node discover packet received
                if (([[XbeeRxObj AT1] unsignedIntValue] == 78) && [[XbeeRxObj AT2] unsignedIntValue] == 68 ) {
                    
                    NSFetchRequest *fetchContacts = [[NSFetchRequest alloc] init];
                    NSEntityDescription *contactsEntity = [NSEntityDescription entityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
                    [fetchContacts setEntity:contactsEntity];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address64 == %@",[XbeeRxObj sourceAddr64HexString]];
                    [fetchContacts setPredicate:predicate];
                    
                    NSError *error = nil;

                    Contacts *fetchedResult = [[managedObjectContext executeFetchRequest:fetchContacts error:&error] lastObject];
                    
                    if (!fetchedResult) {
                        //This method creates a new contact.
                        Contacts *newContact = (Contacts *)[NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
                        
                        [newContact setAddress16:[XbeeRxObj sourceAddr16HexString]];
                        [newContact setAddress64:[XbeeRxObj sourceAddr64HexString]];
                        [newContact setUsername:[XbeeRxObj nodeidentifier]];
                        [newContact setIsAvailable:[NSNumber numberWithBool:TRUE]];
                        NSError *error = nil;
                        if (![managedObjectContext save:&error]) {
                            // Handle the error.
                        }
                    }
                    else{
                        [fetchedResult setAddress16:[XbeeRxObj sourceAddr16HexString]];
                        [fetchedResult setUsername:[XbeeRxObj nodeidentifier]];
                        [fetchedResult setIsAvailable:[NSNumber numberWithBool:TRUE]];
                        NSError *error = nil;
                        if (![managedObjectContext save:&error]) {
                            // Handle the error.
                        }
                    }

                    [[NSNotificationCenter defaultCenter] postNotificationName:@"contactUpdated" object:self];
                }
                
                //if ATNI packet received, or PAN ID or operating channel
                else if(([[XbeeRxObj ATString] isEqualToString:@"NI"])||([[XbeeRxObj ATString] isEqualToString:@"ID"])){                    
                    
                    if ([[XbeeRxObj ATCommandResponse] length] > 0) {
                        
                        NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
                        NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
                        [fetchOwnSettings setEntity:ownSettingsEntity];
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"atCommand == %@",[XbeeRxObj ATString]];
                        [fetchOwnSettings setPredicate:predicate];
                        
                        NSError *error = nil;
                        OwnSettings *fetchedSettings = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
                        
                        if (!fetchedSettings) {
                            //This method creates a new setting.
                            OwnSettings *newSettings = (OwnSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
                            
                            [newSettings setAtCommand:[XbeeRxObj ATString]];
                            [newSettings setAtSetting:[XbeeRxObj ATCommandResponse]];
                            
                            NSError *error = nil;                           
                            if (![managedObjectContext save:&error]) {
                                // Handle the error.
                            }
                        }
                        else{
                            fetchedSettings.atCommand = [XbeeRxObj ATString];
                            fetchedSettings.atSetting = [XbeeRxObj ATCommandResponse];
                            NSError *error = nil;
                            if (![managedObjectContext save:&error]) {
                                // Handle the error.
                            }
                        }

                        
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"optionsTableUpdate" object:self];
                    
                }
                
                }
                //if ATSL or ATSH or ATMY packet received
                else if(([[XbeeRxObj ATString] isEqualToString:@"SL"])||([[XbeeRxObj ATString] isEqualToString:@"SH"])||([[XbeeRxObj ATString] isEqualToString:@"MY"])||([[XbeeRxObj ATString] isEqualToString:@"CH"])){
      

                    if ([[XbeeRxObj ATCommandResponseHex] length] > 0) {
                        
                        NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
                        NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
                        [fetchOwnSettings setEntity:ownSettingsEntity];
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"atCommand == %@",[XbeeRxObj ATString]];
                        [fetchOwnSettings setPredicate:predicate];
                        
                        NSError *error = nil;
                        OwnSettings *fetchedSettings = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
                        
                        if (!fetchedSettings) {
                            //This method creates a new setting.
                            OwnSettings *newSettings = (OwnSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
                            
                            [newSettings setAtCommand:[XbeeRxObj ATString]];
                            [newSettings setAtSetting:[XbeeRxObj ATCommandResponseHex]];
                            
                            NSError *error = nil;
                            if (![managedObjectContext save:&error]) {
                                // Handle the error.
                            }
                        }
                        else{
                            fetchedSettings.atCommand = [XbeeRxObj ATString];
                            fetchedSettings.atSetting = [XbeeRxObj ATCommandResponseHex];
                            NSError *error = nil;
                            if (![managedObjectContext save:&error]) {
                                // Handle the error.
                            }
                        }
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"optionsTableUpdate" object:self];
                
                }
                else if(([[XbeeRxObj ATString] isEqualToString:@"PL"])||([[XbeeRxObj ATString] isEqualToString:@"%V"])||([[XbeeRxObj ATString] isEqualToString:@"DB"])){
                    if ([[XbeeRxObj ATCommandResponse] length] > 0) {
                
                        NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
                        NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
                        [fetchOwnSettings setEntity:ownSettingsEntity];
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"atCommand == %@",[XbeeRxObj ATString]];
                        [fetchOwnSettings setPredicate:predicate];
                        
                        NSError *error = nil;
                        OwnSettings *fetchedSettings = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
                        
                        if (!fetchedSettings) {
                            //This method creates a new setting.
                            OwnSettings *newSettings = (OwnSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
                            
                            [newSettings setAtCommand:[XbeeRxObj ATString]];
                            [newSettings setAtSetting:[XbeeRxObj ATCommandResponse]];
                            
                            NSError *error = nil;
                            if (![managedObjectContext save:&error]) {
                                // Handle the error.
                            }
                        }
                        else{
                            fetchedSettings.atCommand = [XbeeRxObj ATString];
                            fetchedSettings.atSetting = [XbeeRxObj ATCommandResponse];
                            NSError *error = nil;
                            if (![managedObjectContext save:&error]) {
                                // Handle the error.
                            }
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"powerSettings" object:self];
                    }

                
                }
                break;
            
            case 139:{     //frame is a transmit request acknowledgement. saves result of transmission in Ownsettings in core data. 
            
                if ([[XbeeRxObj ack] unsignedIntValue] == 0){
                    
 //                   self.receivedMessage.text = [NSString stringWithFormat:@"Message sent to %@ with %d retries",[XbeeRxObj sourceAddr16HexString], [[XbeeRxObj retries] unsignedIntValue]] ;
                }
                else {
   //                 self.receivedMessage.text = [NSString stringWithFormat:@"Message to %@ not successful",[XbeeRxObj sourceAddr16HexString]];
                }
                break;}
    
            case 144:       //frame is a zigbee receive packet
            {
                
                NSFetchRequest *fetchContacts = [[NSFetchRequest alloc] init];
                NSEntityDescription *contactsEntity = [NSEntityDescription entityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
                [fetchContacts setEntity:contactsEntity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address64 == %@",[XbeeRxObj sourceAddr64HexString]];
                [fetchContacts setPredicate:predicate];
                
                NSError *error = nil;
                Contacts *fetchedResult = [[managedObjectContext executeFetchRequest:fetchContacts error:&error] lastObject];
                
                
                if ([XbeeRxObj msgType] == 1) {
                    
                    //output received text message into receivemsg.text
                    NSMutableString *rxMessage = [[NSMutableString alloc] initWithCapacity:2];
                    for (int i =0; i<[[XbeeRxObj receiveddata] count]; i++) {
                        [rxMessage appendString:[NSString stringWithFormat:@"%c",[[[XbeeRxObj receiveddata] objectAtIndex:i] unsignedIntValue]]];
                    }
                    if (!fetchedResult){
                        //This method creates a new contact.
                        Contacts *newContact = (Contacts *)[NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
                        newContact.address16 = [XbeeRxObj sourceAddr16HexString];
                        newContact.address64 = [XbeeRxObj sourceAddr64HexString];
                        newContact.username = @"Unknown";
                        newContact.isAvailable = [NSNumber numberWithBool:TRUE];
                        
                        Messages *newMessage = (Messages *)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:managedObjectContext];
                        newMessage.messageContents = rxMessage;
                        newMessage.messageReceived = [NSNumber numberWithBool:TRUE];
                        newMessage.messageDate = [NSDate date];
                        newMessage.messageFromContacts = newContact;
                    }
                    else{
                        fetchedResult.address16 = [XbeeRxObj sourceAddr16HexString];
                        fetchedResult.isAvailable = [NSNumber numberWithBool:TRUE];
                        
                        Messages *newMessage = (Messages *)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:managedObjectContext];
                        
                        [newMessage setMessageContents:[[NSString alloc] initWithString:rxMessage]];
                        [newMessage setMessageReceived:[NSNumber numberWithBool:TRUE]];
                        [newMessage setMessageFromContacts:fetchedResult];
                        [newMessage setMessageDate:[NSDate date]];
                    }
                    NSError *error = nil;
                    if (![managedObjectContext save:&error]) {
                        // Handle the error.
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"messageReceived" object:self];
                    
                }  
                
                else if ([XbeeRxObj msgType] == 4) {
                 if (!fetchedResult){
                 //This method creates a new contact.
                 Contacts *newContact = (Contacts *)[NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
                 newContact.address16 = [XbeeRxObj sourceAddr16HexString];
                 newContact.address64 = [XbeeRxObj sourceAddr64HexString];
                 newContact.username = @"Unknown";
                 newContact.isAvailable = [NSNumber numberWithBool:TRUE];
                 }
                 else {
                 fetchedResult.address16 = [XbeeRxObj sourceAddr16HexString];
                 fetchedResult.isAvailable = [NSNumber numberWithBool:TRUE];
                 }
                 NSError *error = nil;
                 if (![managedObjectContext save:&error]) {
                 // Handle the error.
                 }
                 
                 //output received text message into receivemsg.text
                 NSMutableString *rxMessage = [[NSMutableString alloc] initWithCapacity:2];
                 for (int i =0; i<[[XbeeRxObj receiveddata] count]; i++) {
                 [rxMessage appendString:[NSString stringWithFormat:@"%c",[[[XbeeRxObj receiveddata] objectAtIndex:i] unsignedIntValue]]];
                 }
                 
                 if ([rxMessage isEqualToString:@"$+$+"]) {
                 NSString *organisationtemp = [[NSString alloc] initWithString:@""];
                 NSString *userdatatemp = [[NSString alloc] initWithString:@""];
                 
                 NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
                 NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
                 [fetchOwnSettings setEntity:ownSettingsEntity];
                 
                 NSPredicate *predicateOrg= [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserOrg"];
                 [fetchOwnSettings setPredicate:predicateOrg];
                 
                 NSError *error = nil;
                 OwnSettings *fetchedOrg = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
                 if (fetchedOrg) {
                 organisationtemp = [NSString stringWithFormat:@"%@", [fetchedOrg atSetting]];
                 }
                 
                 
                 NSPredicate *predicateData = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserData"];
                 [fetchOwnSettings setPredicate:predicateData];
                 
                 OwnSettings *fetchedData = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
                 if (fetchedData) {
                 userdatatemp = [NSString stringWithFormat:@"%@", [fetchedData atSetting]];
                 }
                 
                 //pack string into appropriate form
                 NSString *txMessage = [[NSString alloc] initWithFormat:@"%@%@%@", organisationtemp, @"+++",userdatatemp];
                 XbeeTx *XbeeTxObj = [XbeeTx new];
                 //send information on organisation and personal data
                 [XbeeTxObj TxMessage:txMessage ofSize:0 andMessageType:4 withStartID:FrameID withFrameID:FrameID withPacketFrameId:FrameID withDestNode64:[[hexConvert alloc] convertStringToArray:[XbeeRxObj sourceAddr64HexString]] withDestNetworkAddr16:[[hexConvert alloc] convertStringToArray:[XbeeRxObj sourceAddr16HexString]]];
                 NSArray *sendPacket = [XbeeTxObj txPacket];
                 for ( int i = 0; i< (int)[sendPacket count]; i++ ) {
                 txBuffer[i] = [[sendPacket objectAtIndex:i] unsignedIntValue]; 
                 }
                 int bytesWritten = [rscMgr write:txBuffer Length:[sendPacket count]];
                 FrameID = FrameID + 1;  //increment FrameID
                 if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
                 FrameID = 1;
                 }
                 
                 }   
                 
                 else {
                 NSString *separator = @"+++";
                 NSArray *receivedUserData = [rxMessage componentsSeparatedByString:separator];
                 
                 NSFetchRequest *fetchContacts1 = [[NSFetchRequest alloc] init];
                 NSEntityDescription *contactsEntity1 = [NSEntityDescription entityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
                 [fetchContacts1 setEntity:contactsEntity1];
                 
                 NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"address64 == %@",[XbeeRxObj sourceAddr64HexString]];
                 [fetchContacts1 setPredicate:predicate1];
                 
                 NSError *error = nil;
                 Contacts *fetchedResult1 = [[managedObjectContext executeFetchRequest:fetchContacts1 error:&error] lastObject];
                 if (fetchedResult1) {
                 fetchedResult.userOrg = [receivedUserData objectAtIndex:0];
                 fetchedResult.userData = [receivedUserData objectAtIndex:1];
                 }
                     
                error = nil;
                if (![managedObjectContext save:&error]) {
                         // Handle the error.
                    }

                 }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"contactUpdated" object:self];

            }
                
                else if ([XbeeRxObj msgType] == 3){
                    
                    if (!fetchedResult){
                        //This method creates a new contact.
                        Contacts *newContact = (Contacts *)[NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
                        newContact.address16 = [XbeeRxObj sourceAddr16HexString];
                        newContact.address64 = [XbeeRxObj sourceAddr64HexString];
                        newContact.username = @"Unknown";
                        newContact.isAvailable = [NSNumber numberWithBool:TRUE];
                    }
                    else {
                        fetchedResult.address16 = [XbeeRxObj sourceAddr16HexString];
                        fetchedResult.isAvailable = [NSNumber numberWithBool:TRUE];
                    }
                    NSError *error = nil;
                    if (![managedObjectContext save:&error]) {
                        // Handle the error.
                    }

                    NSMutableString *rxMessage = [[NSMutableString alloc] initWithCapacity:[[XbeeRxObj receiveddata] count]];
                    for (int i =0; i<[[XbeeRxObj receiveddata] count]; i++) {
                        [rxMessage appendString:[NSString stringWithFormat:@"%c",[[[XbeeRxObj receiveddata] objectAtIndex:i] unsignedIntValue]]];
                    }                    
                    
                    NSString *separator = @"*";
                    NSArray *receivedstrings = [rxMessage componentsSeparatedByString:separator];
                    NSString *title = [receivedstrings objectAtIndex:0];
                    NSString *description = [receivedstrings objectAtIndex:1];
                    NSString *location = [receivedstrings objectAtIndex:2];
                    NSString *tag = [receivedstrings objectAtIndex:3];
                    NSLog(@"The received information are title = %@ with description = %@ and location = %@ and tag = %@", title, description, location,tag);
                    
                    //USING CORE DATA
                    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
                    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
                    [fetchLocation setEntity:locationEntity];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationTitle == %@", title];
                    [fetchLocation setPredicate:predicate];
                    
                    error = nil;
                    Location *fetchedResult = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] lastObject];
                
                    if (!fetchedResult) {
                        //create new Location
                        Location *newLocation = (Location *) [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
                        newLocation.locationTitle = title;
                        newLocation.locationDescription = description;
                        newLocation.locationLatitude = location;
                        // newLocation.locationLongitude = NULL;
                        
                        if (![tag isEqualToString:@"notPerson"]){
                        //use mac address to find the contact and link the contact to the location
                            NSPredicate *predicateLocateContact = [NSPredicate predicateWithFormat:@"address64 == %@",tag];
                            [fetchContacts setPredicate:predicateLocateContact];
                            
                            NSError *errorContact = nil;
                            Contacts *fetchedLocateContact = [[managedObjectContext executeFetchRequest:fetchContacts error:&errorContact] lastObject];
                            
                            if (!fetchedLocateContact){
                                //This method creates a new contact.
                                Contacts *newContact = (Contacts *)[NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
                                newContact.address16 = @"FFFE";
                                newContact.address64 = tag;
                                newContact.userData = description;
                                newContact.username = @"Unknown";
                                newContact.isAvailable = [NSNumber numberWithBool:FALSE];
                                newContact.contactLocation = newLocation;
                        }
                            else {
                                fetchedLocateContact.contactLocation = newLocation;
                                fetchedLocateContact.userData = description;
                        }
                            NSError *error = nil;
                        if (![managedObjectContext save:&error]) {
                            // Handle the error.
                        }
                            
                            
                        
               /*         NSError *error = nil;
                        //[managedObjectContext save:&error ];
                        if (![managedObjectContext save:&error]) {
                            // Handle the error.
                        }*/
                    }
                        
                    }
                    else{
                        fetchedResult.locationDescription = description;
                        fetchedResult.locationLatitude = location;
                        
                        if (![tag isEqualToString:@"notPerson"]){
                            //use mac address to find the contact and link the contact to the location
                            NSPredicate *predicateLocateContact = [NSPredicate predicateWithFormat:@"address64 == %@",tag];
                            [fetchContacts setPredicate:predicateLocateContact];
                            
                            NSError *errorContact = nil;
                            Contacts *fetchedLocateContact = [[managedObjectContext executeFetchRequest:fetchContacts error:&errorContact] lastObject];
                            
                            if (!fetchedLocateContact){
                                //This method creates a new contact.
                                Contacts *newContact = (Contacts *)[NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
                                newContact.address16 = @"FFFE";
                                newContact.address64 = tag;
                                newContact.username = @"Unknown";
                                newContact.userData = description;
                                newContact.isAvailable = [NSNumber numberWithBool:FALSE];
                                newContact.contactLocation = fetchedResult;
                            }
                            else {
                                fetchedLocateContact.contactLocation = fetchedResult;
                                fetchedLocateContact.userData = description;
                            }
                            NSError *error = nil;
                            if (![managedObjectContext save:&error]) {
                                // Handle the error.
                            }
                        }
                        /*
                        NSError *error = nil;
                        if (![managedObjectContext save:&error]) {
                            // Handle the error.
                        }*/
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"contactUpdated" object:self];

                }

                
                
                
                
                
                
                /*
                    else if ([XbeeRxObj msgType] == 2) {
                    //If output is a picture
                    
                    NSMutableArray *rxBufArrayTemp = [[NSMutableArray alloc] initWithArray:rxBufferArray];
                    [rxBufArrayTemp addObject:[XbeeRxObj receiveddata]];    //add received packet to buffer
                    
                    
                    if ([rxBufArrayTemp count]==(1+[XbeeRxObj endID]-[XbeeRxObj startID])) {
                    int numberOfBytes = 0;
                    for (int i = 0; i<[rxBufArrayTemp count]; i++) {
                    numberOfBytes = numberOfBytes + [[rxBufArrayTemp objectAtIndex:i] count];
                    }
                    char rxBufferChar[numberOfBytes];
                    int counter = 0;
                    for (int i = 0; i < [rxBufArrayTemp count]; i++) {
                    for (int j = 0; j<[[rxBufArrayTemp objectAtIndex:i] count]; j++) {
                    rxBufferChar[counter] = [[[rxBufArrayTemp objectAtIndex:i] objectAtIndex:j] unsignedCharValue];
                    counter = counter + 1;
                    }
                    }                        
                    
                    NSData *imageData = [[NSData alloc] initWithBytes:rxBufferChar length:numberOfBytes];
                    UIImage *picture = [[UIImage alloc] initWithData:imageData];     //display picture
                    
                    [rxBufArrayTemp removeAllObjects];
                    rxBufferArray = rxBufArrayTemp;
                    }
                    else{
                    rxBufferArray = rxBufArrayTemp;
                    }*//*
                else if ([XbeeRxObj msgType] == 3){
                    NSMutableString *rxMessage = [[NSMutableString alloc] initWithCapacity:[[XbeeRxObj receiveddata] count]];
                    for (int i =0; i<[[XbeeRxObj receiveddata] count]; i++) {
                        [rxMessage appendString:[NSString stringWithFormat:@"%c",[[[XbeeRxObj receiveddata] objectAtIndex:i] unsignedIntValue]]];
                    }                    
                    
                    NSString *separator = @"*";
                    NSArray *receivedstrings = [rxMessage componentsSeparatedByString:separator];
                    NSString *title = [receivedstrings objectAtIndex:0];
                    NSString *description = [receivedstrings objectAtIndex:1];
                    NSString *location = [receivedstrings objectAtIndex:2];
                    NSLog(@"The received information are title = %@ with description = %@ and location = %@", title, description, location);
                    
                    //USING CORE DATA
                    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
                    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
                    [fetchLocation setEntity:locationEntity];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationTitle == %@", title];
                    [fetchLocation setPredicate:predicate];
                    
                    NSError *error = nil;
                    Location *fetchedResult = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] lastObject];
                    
                    if (!fetchedResult) {
                        //create new Location
                        Location *newLocation = (Location *) [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
                        newLocation.locationTitle = title;
                        newLocation.locationDescription = description;
                        newLocation.locationLatitude = location;
                        // newLocation.locationLongitude = NULL;
                        NSError *error = nil;
                        //[managedObjectContext save:&error ];
                        if (![managedObjectContext save:&error]) {
                            // Handle the error.
                        }
                    }
                    else{
                        fetchedResult.locationDescription = description;
                        fetchedResult.locationLatitude = location;
                        NSError *error = nil;
                        if (![managedObjectContext save:&error]) {
                            // Handle the error.
                        }
                    }
                }*/
            
                break;}
            default:
                break;
        }
        
        }
    else{
        rxPacketBuffer = rxPackBuf;
    }
    

}
    @end
