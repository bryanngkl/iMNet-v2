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
@synthesize title,description;


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
    
    //for UItextview placeholder
    description.text = @"Description";
    description.textColor = [UIColor lightGrayColor];
    
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

@end