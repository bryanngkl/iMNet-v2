//
//  ContactDetailsViewController.m
//  iMNet v2
//
//  Created by Bryan on 30/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactDetailsViewController.h"
#import <unistd.h>


@implementation ContactDetailsViewController

@synthesize managedObjectContext;
@synthesize currentContact;
@synthesize userName,userData,userOrganisation,userlatitude,userlongitude;
@synthesize rscMgr;
@synthesize contactPicture;
@synthesize popovercontroller;


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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactDetailUpdate:) name:@"contactDetailsUpdated" object:nil];
    self.contactPicture.image = [[UIImage alloc] initWithData:currentContact.contactImage.imageData];
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contactDetailsUpdated" object:nil];
    userName = nil;
    userOrganisation = nil;
    userData = nil;
    userlatitude = nil;
    userlongitude = nil;
    contactPicture = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.userName.text = currentContact.username;
    self.userOrganisation.text = currentContact.userOrg;
    self.userData.text = currentContact.userData;
    
    //CONTACT LOCATION
    Location *locationofcurrentcontact;
    if ([currentContact contactLocation] != NULL){
        locationofcurrentcontact = [currentContact contactLocation];
        //get the respective coordinates
        NSString *separator = @",";
        NSArray *coordinatesofcontact = [[locationofcurrentcontact locationLatitude] componentsSeparatedByString:separator];
        self.userlatitude.text =  [[coordinatesofcontact objectAtIndex:0] stringByAppendingString:@"E"];
        self.userlongitude.text = [[coordinatesofcontact objectAtIndex:1] stringByAppendingString:@"N"];
        
    }
    else {
        self.userlatitude.text = @"Not available";
        self.userlongitude.text = @"Not available";
    }
    
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
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
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    return cell;
}*/

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
- (void)contactDetailUpdate:(NSNotification *)notification{
    NSFetchRequest *fetchContacts = [[NSFetchRequest alloc] init];
    NSEntityDescription *contactsEntity = [NSEntityDescription entityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
    [fetchContacts setEntity:contactsEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address64 == %@", currentContact.address64];
    [fetchContacts setPredicate:predicate];
    
    NSError *error = nil;
    Contacts *fetchedResult = [[managedObjectContext executeFetchRequest:fetchContacts error:&error] lastObject];
    if (fetchedResult) {
        currentContact = fetchedResult;
    }

    self.userName.text = currentContact.username;
    self.userOrganisation.text = currentContact.userOrg;
    self.userData.text = currentContact.userData;

    //CONTACT LOCATION
    Location *locationofcurrentcontact;
    if ([currentContact contactLocation] != NULL){
    locationofcurrentcontact = [currentContact contactLocation];
    //get the respective coordinates
    NSString *separator = @",";
    NSArray *coordinatesofcontact = [[locationofcurrentcontact locationLatitude] componentsSeparatedByString:separator];
    self.userlatitude.text =  [[coordinatesofcontact objectAtIndex:0] stringByAppendingString:@"E"];
    self.userlongitude.text = [[coordinatesofcontact objectAtIndex:1] stringByAppendingString:@"N"];
    
}
else {
    self.userlatitude.text = @"Not available";
    self.userlongitude.text = @"Not available";
}


}
    


- (IBAction)requestUserInfo:(id)sender {
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	HUD.delegate = self;
	HUD.labelText = @"Loading";
    HUD.dimBackground = YES;
	
	[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    }

#pragma mark Segues
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"MessageLogSegueFromDetailedContacts"]) {
        MessageLogViewController *mlVC = (MessageLogViewController *)[segue destinationViewController];
        mlVC.currentContact = currentContact;
        mlVC.managedObjectContext = managedObjectContext;
        mlVC.rscMgr = rscMgr;
        NSLog(@"passed data from detailed contacts to message log");        
    }

    else if ([segue.identifier isEqualToString:@"ContactImageSegue"]) {
        ContactImageViewController *ciVC = (ContactImageViewController *)[segue destinationViewController];
        ciVC.currentImage = contactPicture.image;
        ciVC.navigationItem.title = currentContact.username;
    }
}


- (IBAction)locateMe:(id)sender {
    //update dataclass to center map on the contact
    DataClass *obj = [DataClass getInstance];
    obj.fromDetailedContactView = @"YES";
    obj.title = [[currentContact contactLocation] locationTitle];
    obj.description = [[currentContact contactLocation] locationDescription];
    obj.location = [[currentContact contactLocation] locationLatitude];
    //load the map tab
    [self.tabBarController setSelectedIndex:3];
}


- (void)myTask {
	// Do something usefull in here instead of sleeping ...
    //send message to xbee
    //create tx packet
    XbeeTx *XbeeObj = [XbeeTx new];
    [XbeeObj TxMessage:@"$+$+" ofSize:0 andMessageType:4 withStartID:FrameID withFrameID:FrameID withPacketFrameId:FrameID withDestNode64:[[hexConvert alloc] convertStringToArray:[currentContact address64]] withDestNetworkAddr16:[[hexConvert alloc] convertStringToArray:[currentContact address16]]];
    
    NSArray *sendPacket = [XbeeObj txPacket];    
    for ( int i = 0; i < (int)[sendPacket count]; i++ ) {
        txBuffer[i] = [[sendPacket objectAtIndex:i] unsignedIntValue];
    }
    int bytesWritten = [rscMgr write:txBuffer Length:[sendPacket count]];
    
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }   
    sleep(3);
}

- (IBAction)choosePhoto:(id)sender {
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentModalViewController:picker animated:YES];
    }
    else {
        if ([self.popovercontroller isPopoverVisible]) {
            [self.popovercontroller dismissPopoverAnimated:YES];
        } 
        else {
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                UIImagePickerController *imagePicker =
                [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType =
                UIImagePickerControllerSourceTypePhotoLibrary;
                //imagePicker.mediaTypes = [NSArray arrayWithObjects:
                //                          (NSString *) kUTTypeImage,
                //                          nil];
                imagePicker.allowsEditing = NO;
                
                self.popovercontroller = [[UIPopoverController alloc]
                                          initWithContentViewController:imagePicker];
                
                popovercontroller.delegate = self;
                
                //[self.popovercontroller presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
                
                [self.popovercontroller presentPopoverFromRect:CGRectMake(50,635,10,10) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
                
                // newMedia = NO;
            }
        }
        
    }

}

- (IBAction)takePhoto:(id)sender {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;    
	
    [self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
        [picker dismissModalViewControllerAnimated:YES];
    }
    else {
        [self.popovercontroller dismissPopoverAnimated:true];
    }
	contactPicture.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    NSFetchRequest *fetchContacts = [[NSFetchRequest alloc] init];
    NSEntityDescription *contactsEntity = [NSEntityDescription entityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
    [fetchContacts setEntity:contactsEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address64 == %@",currentContact.address64];
    [fetchContacts setPredicate:predicate];
    
    NSError *error = nil;
    Contacts *fetchedResult = [[managedObjectContext executeFetchRequest:fetchContacts error:&error] lastObject];
    
    if (fetchedResult) {
        NSData *imageDataCurrent = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 0.0); //Convert image to .png format     
        if (fetchedResult.contactImage) {
            fetchedResult.contactImage.imageData = imageDataCurrent;
        }
        else {
            Images *newImage = (Images *)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:managedObjectContext];
            newImage.imageData = imageDataCurrent;        
            
            fetchedResult.contactImage = newImage;
        }

    }

    error = nil;
    if (![managedObjectContext save:&error]) {
        // Handle the error.
    }
    
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}
@end
