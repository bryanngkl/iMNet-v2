//
//  PersonalInfoViewController.m
//  iMNet v2
//
//  Created by Bryan on 30/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersonalInfoViewController.h"


@implementation PersonalInfoViewController

@synthesize managedObjectContext;
@synthesize rscMgr;
@synthesize userDataField,usernameField,organisationField;

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
    
    userDataField.delegate = self;
    usernameField.delegate = self;
    organisationField.delegate = self;
    
    
    //Register for gesture notification
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(didTapAnywhere:)];
    //Rgister for keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification object:self.view.window]; 

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    usernameField = nil;
    organisationField = nil;
    userDataField = nil;
    
    //Deregister the keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil]; 
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    
    NSPredicate *predicateUsername = [NSPredicate predicateWithFormat:@"atCommand == %@",@"NI"];
    [fetchOwnSettings setPredicate:predicateUsername];
    
    NSError *error = nil;
    OwnSettings *fetchedUsername = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedUsername) {
        self.usernameField.text = [NSString stringWithFormat:@"%@", [fetchedUsername atSetting]];
    }
    

    NSPredicate *predicateOrg = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserOrg"];
    [fetchOwnSettings setPredicate:predicateOrg];
    
    error = nil;
    OwnSettings *fetchedOrg = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedOrg) {
        self.organisationField.text = [fetchedOrg atSetting];
    }
    
    NSPredicate *predicateUserData = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserData"];
    [fetchOwnSettings setPredicate:predicateUserData];
    
    error = nil;
    OwnSettings *fetchedUserData = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedUserData) {
        self.userDataField.text = [fetchedUserData atSetting];
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



//set max characters for textfield
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= 15 && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {return YES;}
}

- (void)textViewDidChange:(UITextView *)textView{
    
    NSInteger restrictedLength=140;
    
    NSString *temp=textView.text;
    
    if([[textView text] length] > restrictedLength){
        textView.text=[temp substringToIndex:[temp length]-1];
    }
}
/*
- (BOOL)textView:(UITextView *)textView shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    if (textView.text.length >= 15 && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {return YES;}

}
*/

- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)saveData:(id)sender {
    
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    
    NSPredicate *predicateUsername = [NSPredicate predicateWithFormat:@"atCommand == %@",@"NI"];
    [fetchOwnSettings setPredicate:predicateUsername];
    
    NSError *error = nil;
    OwnSettings *fetchedUsername = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedUsername) {
        //This method creates a new setting.
        fetchedUsername.atSetting = self.usernameField.text;
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    else{
        OwnSettings *newSettings = (OwnSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
        
        [newSettings setAtCommand:@"NI"];
        [newSettings setAtSetting:self.usernameField.text];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    
    
    
    NSPredicate *predicateOrg = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserOrg"];
    [fetchOwnSettings setPredicate:predicateOrg];
    
    error = nil;
    OwnSettings *fetchedOrg = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedOrg) {
        //This method creates a new setting.
        fetchedOrg.atSetting = self.organisationField.text;
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    else{
        OwnSettings *newSettings = (OwnSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
        
        [newSettings setAtCommand:@"UserOrg"];
        [newSettings setAtSetting:self.organisationField.text];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    
    
    NSPredicate *predicateUserData = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserData"];
    [fetchOwnSettings setPredicate:predicateUserData];
    
    error = nil;
    OwnSettings *fetchedUserData = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedUserData) {
        //This method creates a new setting.
        fetchedUserData.atSetting = self.userDataField.text;
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    else{
        OwnSettings *newSettings = (OwnSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
        
        [newSettings setAtCommand:@"UserData"];
        [newSettings setAtSetting:self.userDataField.text];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    
    XbeeTx *XbeeObj = [XbeeTx new];
    //set up ATCommand for PAN ID
    [XbeeObj ATCommandSetString:@"NI" withParameter:self.usernameField.text withFrameID:FrameID];
    NSArray *sendPacket = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacket count]; i++ ) {
        txBuffer[i] = [[sendPacket objectAtIndex:i] unsignedIntValue]; 
    }
    int bytesWritten = [rscMgr write:txBuffer Length:[sendPacket count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    
    //save changes permanently
    [XbeeObj ATCommand:@"WR" withFrameID:FrameID];
    NSArray *sendPacketWR = [XbeeObj txPacket];
    for ( int i = 0; i< (int)[sendPacketWR count]; i++ ) {
        txBuffer[i] = [[sendPacketWR objectAtIndex:i] unsignedIntValue]; 
    }
    bytesWritten = [rscMgr write:txBuffer Length:[sendPacketWR count]];
    FrameID = FrameID + 1;  //increment FrameID
    if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
        FrameID = 1;
    }
    

    [[NSNotificationCenter defaultCenter] postNotificationName:@"optionsTableUpdate" object:self];
    
}

#pragma mark Resigning the keyboard

- (void)keyboardWillShow:(NSNotification *)aNotification {
    [self.view addGestureRecognizer:tapRecognizer];
    NSLog(@"keyboard notification");
    }

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:tapRecognizer];
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {    
    [userDataField resignFirstResponder];
    [usernameField resignFirstResponder];
    [organisationField resignFirstResponder];
    }


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[usernameField resignFirstResponder];
    [userDataField resignFirstResponder];
	return YES;
}
@end
