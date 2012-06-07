//
//  AddPinInfoViewController.m
//  iMNet v2
//
//  Created by Kenneth on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddPinInfoViewController.h"
#import "MapViewController.h"

@implementation AddPinInfoViewController
@synthesize coordinates;
@synthesize title,description,managedObjectContext;
@synthesize delegate = _delegate;
@synthesize rscMgr;
@synthesize ownpintapped, macAddress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    DataClass *obj = [DataClass getInstance];
    title.text = obj.title;
    description.text = obj.description;
    NSLog(@"This is the data that we see in the modal view at first key=title=%@, description=%@, location=%@",obj.title,obj.description,obj.location);
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if(description.text.length == 0) {
        //for UItextview placeholder
        description.text = @"Description";
        description.textColor = [UIColor lightGrayColor];
    }
    
    //set Coordinates
    coordinates.text = [coordinates.text stringByAppendingString:obj.location];
    [super viewDidLoad];
}




- (void)viewDidUnload
{
    [self setCoordinates:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    //show the navigation bar
    [self.navigationController setNavigationBarHidden:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Editing Info

- (void) setEditing:(BOOL)editing animated:(BOOL)animated{
    
    if ([ownpintapped isEqualToString:@"NO"]){
    [super setEditing:editing animated:animated];
    
    self.title.enabled = editing;
    [self.title setBorderStyle:UITextBorderStyleRoundedRect];
    [self.description setEditable:YES];
    description.textColor = [UIColor blackColor];
    description.font = [UIFont italicSystemFontOfSize:14];
    
    //[self.description setBackgroundColor:[UIColor blueColor]];
    
    if (!editing) {
        [title setEnabled:NO];
        [self.title setBorderStyle:UITextBorderStyleNone];
        [description setEditable:NO];
        description.textColor = [UIColor grayColor];
        description.font = [UIFont systemFontOfSize:14];
        //[description setBackgroundColor:[UIColor whiteColor]];
    }
    
    }      
}



#pragma mark Placeholder for UItextView


- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    description.text = @"";
    description.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(description.text.length == 0){
        description.textColor = [UIColor lightGrayColor];
        description.text = @"Description";
        [description resignFirstResponder];
    }
}



- (IBAction)Back:(id)sender {
    
    //update data class
    DataClass *obj = [DataClass getInstance];
 
    if (ownpintapped == @"NO"){
    //UPDATING CORE DATA
    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchLocation setEntity:locationEntity];
    
    //SHould find the object with the same location?
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationTitle == %@", obj.title];
    [fetchLocation setPredicate:predicate];
    
    NSError *error = nil;
    Location *fetchedResult = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] lastObject];
    
    if (!fetchedResult) {
        //create new Location
        Location *newLocation = (Location *) [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
        newLocation.locationTitle = title.text;
        newLocation.locationDescription =description.text;
        newLocation.locationLatitude = obj.location;
        NSLog(@"SHOULDNT COME HERE! The location title was changed, we saved in COREDATA title = %@, location =%@ and description = %@", obj.title, obj.location, obj.description);
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    else{
        fetchedResult.locationTitle = title.text;
        fetchedResult.locationDescription =description.text;
        fetchedResult.locationLatitude = obj.location;
        NSLog(@"The location title was UPDATED, we saved in COREDATA title = %@, location =%@ and description = %@", obj.title, obj.location, obj.description);
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    
    obj.title = title.text;
    obj.description = description.text;
    obj.newpininformationadded = @"YES";
    }
    ownpintapped = @"NO";
    
    //working now!
    //[self.delegate infoAddedWithTitle:title.text andDescription:description.text];
    //[self.delegate didReceiveMessage:@"SONG BOOOOO"];
    [self.navigationController popViewControllerAnimated:NO];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"SendLocationContactsSegue"])
	{
        SendLocationContactsViewController *slcVC = (SendLocationContactsViewController *)[segue destinationViewController];
        slcVC.managedObjectContext = managedObjectContext;
        slcVC.rscMgr = rscMgr;

        //String to send
        DataClass *obj = [DataClass getInstance];
        NSMutableString * strtosend = [NSMutableString stringWithString:title.text];
        NSString * descriptionstr = description.text;
        NSString * locationstr = obj.location; 
    
        [strtosend appendString:[NSString stringWithString:@"*"]];
        
        [strtosend appendString:descriptionstr];
        [strtosend appendString:@"*"];
        [strtosend appendString:locationstr];
        [strtosend appendString:@"*"];
        [strtosend appendString:macAddress];
        
        NSLog(@"This is the string to send: %@", strtosend);
        slcVC.stringToSend = strtosend;
        
        //      contactDetailsViewController.rscMgr = rscMgr;
	}
}

@end