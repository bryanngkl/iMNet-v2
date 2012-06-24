//
//  MessageLogViewController.m
//  iMNet v2
//
//  Created by Bryan on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageLogViewController.h"


@implementation MessageLogViewController
@synthesize tbl, field, toolbar, messages,messagefromselectedcontact,sortedMessages;
@synthesize managedObjectContext, currentContact;
@synthesize rscMgr;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceivedUpdate:) name:@"messageReceived" object:nil];

    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.title = [currentContact username];        
    FrameID = 1;
/*
    //Sort descriptors definition
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:TRUE];
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    //An array of sorted messages by date
    sortedMessages = [[currentContact contactMessages] sortedArrayUsingDescriptors:sortDescriptors1];

    
	
	// The conversation
    // An array of messages content sorted by time
	 
    messages = [[NSMutableArray alloc] initWithObjects:
				nil];
    
    for (int i=0; i<[sortedMessages count]; i++) {
        [messages addObject:[[sortedMessages objectAtIndex:i] messageContents]];
        //NSLog(@"array: %@", [[sortedMessages objectAtIndex:i] messageContents]);
        //NSLog(@"array: %@", [[sortedMessages objectAtIndex:i] messageReceived]);
    }
    
    */
    //NSLog(@"array: %@", messages);  

    /*
	 Set the background color
	 */
	tbl.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:226.0/255.0 blue:237.0/255.0 alpha:1.0];
	
	/*
	 Create header with two buttons
	 */
	/*
    CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 55)];
	
	UIButton *callButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[callButton addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];		
	callButton.frame = CGRectMake(10, 10, (screenSize.width / 2) - 10, 35);
	[callButton setTitle:@"Call" forState:UIControlStateNormal];
	
	UIButton *contactButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[contactButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];		
	contactButton.frame = CGRectMake((screenSize.width / 2) + 10, 10, (screenSize.width / 2) - 20, 35);
	[contactButton setTitle:@"Contact Info" forState:UIControlStateNormal];
    [contactButton addTarget:self action:@selector(contactInfo:) forControlEvents:UIControlEventTouchUpInside];
	
	[headerView addSubview:callButton];
	[headerView addSubview:contactButton];
	
	tbl.tableHeaderView = headerView;
    */
    //Initialize the toolbar
    toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleDefault;
    
    //Set the toolbar to fit the width of the app.
    [toolbar sizeToFit];
    
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [toolbar frame].size.height;
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.parentViewController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
    
    //Reposition and resize the receiver
    [toolbar setFrame:rectArea];
    
    //Create a textfield
    UITextField *myTextField = [[UITextField alloc] init];
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
        [myTextField setFrame:CGRectMake(0, 0, 240, 30)];
    }
    else {
        [myTextField setFrame:CGRectMake(0, 0, 680, 30)];
        //UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 600, 30)];
    }

    myTextField.borderStyle = UITextBorderStyleRoundedRect;
    myTextField.font= [UIFont systemFontOfSize:15.0];
    myTextField.placeholder = @"enter text";
    myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    myTextField.keyboardType = UIKeyboardTypeDefault;
    myTextField.returnKeyType = UIReturnKeyDone;
    myTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    myTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    myTextField.autocorrectionType = UITextAutocorrectionTypeYes;
    //when textfield is changed
    [myTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    myTextField.delegate = self;
    [self.view addSubview:myTextField];
    
    
    UIBarButtonItem *textField = [[UIBarButtonItem alloc] initWithCustomView:(UIView *) myTextField];
    
    field = myTextField;
    
    //Create a button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(info_clicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Send" forState:UIControlStateNormal];
    
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
            button.frame = CGRectMake(0, 0, 50, 30);
    }
    else {
        button.frame = CGRectMake(0, 0, 60, 30);
    }
    

    //[button setEnabled:NO];
    
    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    sendbutton = infoButton;
    
    //UIBarButtonItem *infoButton = [[UIBarButtonItem alloc]
    //                               initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(info_clicked:)];
    
    
    
    [toolbar setItems:[NSArray arrayWithObjects:textField,infoButton,nil]];
    
    //Add the toolbar as a subview to the navigation controller.
    [self.navigationController.view addSubview:toolbar];
    
    startup = TRUE;
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(didTapAnywhere:)];
    
    
    [[self tableView] reloadData];

}


- (void) textFieldDidBeginEditing:(UITextField *) textField{
    NSLog(@"Textfield startediting");
    
/*    //Reposition toolbar
    
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [toolbar frame].size.height;
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.parentViewController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
    [toolbar setFrame:rectArea];
 
 */
    
    //[sendbutton setEnabled:YES];
}

- (void) textFieldDidChange:(UITextField *) textField{
    if (field.text.length != 0 ) {
    //[sendbutton setEnabled:YES];
    }
}

#pragma mark Register for keyboard notification
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

/*
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"keyboard notification");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [toolbar frame].size.height;
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.parentViewController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight -kbSize.height, rootViewWidth, toolbarHeight);
    [toolbar setFrame:rectArea];
    

    }

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    //scrollView.contentInset = contentInsets;
    //scrollView.scrollIndicatorInsets = contentInsets;
}
*/

- (void)viewDidUnload
{
    tbl = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messageReceived" object:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{


    [super viewWillAppear:animated];
    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //[nc addObserver:self selector:@selector(keyboardWasShown:) name: UIKeyboardWillShowNotification object:nil];
    //[nc addObserver:self selector:@selector(keyboardWasHidden:) name: UIKeyboardWillHideNotification object:nil];
    
    /* CHECK THIS! CAUSE CRASH
    NSUInteger index = [messages count];
    [tbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self tableView:tbl numberOfRowsInSection:1] inSection: 1];
    [tbl scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification object:self.view.window]; 
    
}


- (void) info_clicked:(id)sender {
    
    if(![field.text isEqualToString:@""])
	{
		[messages addObject:field.text];
        
        Messages *newMessage = (Messages *)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:managedObjectContext];    
        newMessage.messageContents = field.text;
        newMessage.messageReceived = [NSNumber numberWithBool:FALSE];
        newMessage.messageDate = [NSDate date];
        newMessage.messageFromContacts = currentContact;
        NSError *error2 = nil;
        if (![managedObjectContext save:&error2]) {
            // Handle the error.
        }
        
        
        //Update sorted message
        //Sort descriptors definition
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:TRUE];
        NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
        sortedMessages = [[currentContact contactMessages] sortedArrayUsingDescriptors:sortDescriptors1];
        
        //for (int i=0; i<[sortedMessages count]; i++) {
            //NSLog(@"array new: %@", [[sortedMessages objectAtIndex:i] messageContents]);
            //NSLog(@"array new: %@", [[sortedMessages objectAtIndex:i] messageReceived]);
        //}
        
        //send message to xbee
        //create tx packet
        XbeeTx *XbeeObj = [XbeeTx new];
        [XbeeObj TxMessage:field.text ofSize:0 andMessageType:1 withStartID:FrameID withFrameID:FrameID withPacketFrameId:FrameID withDestNode64:[[hexConvert alloc] convertStringToArray:[currentContact address64]] withDestNetworkAddr16:[[hexConvert alloc] convertStringToArray:[currentContact address16]]];
        
        NSArray *sendPacket = [XbeeObj txPacket];    
        for ( int i = 0; i < (int)[sendPacket count]; i++ ) {
            txBuffer[i] = [[sendPacket objectAtIndex:i] unsignedIntValue];
        }
        int bytesWritten = [rscMgr write:txBuffer Length:[sendPacket count]];
        
        FrameID = FrameID + 1;  //increment FrameID
        if (FrameID == 256) {   //If FrameID > 0xFF, start counting from 1 again
            FrameID = 1;
        }   
        
		[tbl reloadData];
		NSUInteger index = [messages count] - 1;
		[tbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		
		field.text = @"";
        
	}
}

/*
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification object:self.view.window]; 
}
*/ 
 

- (void)viewDidAppear:(BOOL)animated
{
  /*  
    NSUInteger index = [messages count]-1;
    if (index >3) {
        [tbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
   */

    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //[nc removeObserver:self name: UIKeyboardWillShowNotification object:nil];
    //[nc removeObserver:self name: UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil]; 
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    //Sort descriptors definition
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:TRUE];
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    //An array of sorted messages by date
    sortedMessages = [[currentContact contactMessages] sortedArrayUsingDescriptors:sortDescriptors1];
        messages = [[NSMutableArray alloc] initWithObjects:
				nil];
    
    for (int i=0; i<[sortedMessages count]; i++) {
        [messages addObject:[[sortedMessages objectAtIndex:i] messageContents]];
        //NSLog(@"array: %@", [[sortedMessages objectAtIndex:i] messageContents]);
        //NSLog(@"array: %@", [[sortedMessages objectAtIndex:i] messageReceived]);
    }
    return [messages count];
}

//Asks the data source for a cell to insert in a particular location of the table view.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UIImageView *balloonView;
	UILabel *label;
    UILabel *senderandTimeLabel;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;		
		
		balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
		balloonView.tag = 1;
		
        //Label
		label = [[UILabel alloc] initWithFrame:CGRectZero];
        
        //Sender and Time Label
        senderandTimeLabel = [[UILabel alloc] init];
        
        
		UIView *message = [[UIView alloc] init];
		message.tag = 0;
        [message addSubview:senderandTimeLabel];
		[message addSubview:balloonView];
		[message addSubview:label];
		[cell.contentView addSubview:message];
  
        //SET the font and stuff based on whether device is iphone or ipad
        if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
            
            //label
            label.backgroundColor = [UIColor clearColor];
            label.tag = 2;
            label.numberOfLines = 0;
            label.lineBreakMode = UILineBreakModeWordWrap;
            label.font = [UIFont systemFontOfSize:14.0];
            
            //Sender and Time Label
            senderandTimeLabel.tag = 3;
            senderandTimeLabel.backgroundColor =[UIColor clearColor];
            senderandTimeLabel.textAlignment = UITextAlignmentCenter;
            senderandTimeLabel.font = [UIFont boldSystemFontOfSize:11.0];
            senderandTimeLabel.textColor = [UIColor lightGrayColor];
            
            [senderandTimeLabel setFrame:CGRectMake(10, 5, 300, 20)];
            [message setFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];
        }
        else {
            
            //label
            label.backgroundColor = [UIColor clearColor];
            label.tag = 2;
            label.numberOfLines = 0;
            label.lineBreakMode = UILineBreakModeWordWrap;
            label.font = [UIFont systemFontOfSize:14.0];
            
            //Sender and Time Label
            senderandTimeLabel.tag = 3;
            senderandTimeLabel.backgroundColor =[UIColor clearColor];
            senderandTimeLabel.textAlignment = UITextAlignmentCenter;
            senderandTimeLabel.font = [UIFont boldSystemFontOfSize:14.0];
            senderandTimeLabel.textColor = [UIColor lightGrayColor];
            
            [senderandTimeLabel setFrame:CGRectMake(25, 0, 700, 20)];
            [message setFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];        
        }
		
	}
	else
	{
        senderandTimeLabel = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:3];
		balloonView = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:1];
		label = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:2];
	}
	
	NSString *text = [messages objectAtIndex:indexPath.row];
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
	
	UIImage *balloon;
	
	if ([[sortedMessages objectAtIndex:indexPath.row] messageReceived] == [NSNumber numberWithInt:0]) //if(indexPath.row % 2 == 0)
	{
        
        if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
            balloonView.frame = CGRectMake(320.0f - (size.width + 28.0f), 27.0f, size.width + 28.0f, size.height + 15.0f);
            balloon = [[UIImage imageNamed:@"green.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
            label.frame = CGRectMake(307.0f - (size.width + 5.0f), 35.0f, size.width + 5.0f, size.height);
        }
        else {
            balloonView.frame = CGRectMake(763.0f - (size.width + 28.0f), 27.0f, size.width + 28.0f, size.height + 15.0f);
            balloon = [[UIImage imageNamed:@"green.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
            label.frame = CGRectMake(750.0f - (size.width + 5.0f), 35.0f, size.width + 5.0f, size.height); 
        }
        

	}
	else
	{
        
        if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
            balloonView.frame = CGRectMake(0.0, 24.0, size.width + 28, size.height + 15);
            balloon = [[UIImage imageNamed:@"grey.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
            label.frame = CGRectMake(16, 31, size.width + 5, size.height);
        }
        else {
            balloonView.frame = CGRectMake(5.0, 24.0, size.width + 28, size.height + 15);
            balloon = [[UIImage imageNamed:@"grey.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
            label.frame = CGRectMake(21, 31, size.width + 5, size.height);     
        }
        
        

	}
	
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ccc dd/MM/yy',' HH:mm:ss"];
    senderandTimeLabel.text = [dateFormatter stringFromDate:[[sortedMessages objectAtIndex:indexPath.row] messageDate]];
	balloonView.image = balloon;
	label.text = text;
    
    if (startup == TRUE) {
        
        if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
            tbl.frame = CGRectMake(0, 0, 320, 325);	
        }
        else {
            tbl.frame = CGRectMake(0, 0, 768, 873);	  
        }

    }
    
    //NSUInteger index = [messages count]-1;
    //[tbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
	
    //tbl.frame = CGRectMake(0, 0, 320, 325);	
    return cell;

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *body = [messages objectAtIndex:indexPath.row];
	CGSize size = [body sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0, 480.0) lineBreakMode:UILineBreakModeWordWrap];
	return size.height + 34;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [messages removeObjectAtIndex:indexPath.row];
        Messages *messageToDelete = [sortedMessages objectAtIndex:indexPath.row];
        [managedObjectContext deleteObject:messageToDelete];
        NSError *error1 = nil;
        if (![managedObjectContext save:&error1]) {
            // Handle the error.
        }
        NSArray *indexPathsToRemove = [NSArray arrayWithObject:indexPath];
        [tableView deleteRowsAtIndexPaths:indexPathsToRemove withRowAnimation:UITableViewRowAnimationRight];
    }
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

- (IBAction)add:(id)sender {
    if(![field.text isEqualToString:@""])
	{
		[messages addObject:field.text];
		[tbl reloadData];
		NSUInteger index = [messages count] - 1;
		[tbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		
		field.text = @"";

	}
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [toolbar removeFromSuperview];
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];	
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [toolbar frame].size.height;
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.parentViewController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
    
    //Reposition and resize the receiver
    [toolbar setFrame:rectArea];
    
	//toolbar.frame = CGRectMake(0, 372, 320, 44);
	tbl.frame = CGRectMake(0, 0, rootViewWidth, rootViewHeight - toolbarHeight);	
	[UIView commitAnimations];
	
	return YES;
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    [self.view addGestureRecognizer:tapRecognizer];
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];	
    NSLog(@"keyboard notification");

    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [toolbar frame].size.height;
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.parentViewController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight -kbSize.height+5, rootViewWidth, toolbarHeight);
    
    [toolbar setFrame:rectArea];
    
	//toolbar.frame = CGRectMake(0, 156, 320, 44);
    
    //Get the keyboard size
    NSDictionary *userInfo = [aNotification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSLog(@"Height: %f Width: %f", keyboardSize.height, keyboardSize.width);
    
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
        tbl.frame = CGRectMake(0, 0, rootViewWidth, rootViewHeight - keyboardSize.height - toolbarHeight+100);
    }
    else {
         tbl.frame = CGRectMake(0, 0, rootViewWidth, rootViewHeight - keyboardSize.height - toolbarHeight+100);
    }
    
    
	
	[UIView commitAnimations];
	
    startup = FALSE;
    
	if([messages count] > 0)
	{
		NSUInteger index = [messages count] - 1;
		[tbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:tapRecognizer];
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {    
    [field resignFirstResponder];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];	
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [toolbar frame].size.height;
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.parentViewController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
    
    //Reposition and resize the receiver
    [toolbar setFrame:rectArea];
    
	//toolbar.frame = CGRectMake(0, 372, 320, 44);
	tbl.frame = CGRectMake(0, 0, rootViewWidth , rootViewHeight - toolbarHeight - 62);	
	[UIView commitAnimations];

}



- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];	
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [toolbar frame].size.height;
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.parentViewController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
    
    //Reposition and resize the receiver
    [toolbar setFrame:rectArea];
    
	//toolbar.frame = CGRectMake(0, 372, 320, 44);
	tbl.frame = CGRectMake(0, 0, rootViewWidth , rootViewHeight - toolbarHeight);	
	[UIView commitAnimations];
}


/*
 // Called when the UIKeyboardDidShowNotification is sent.
 - (void)keyboardWasShown:(NSNotification*)aNotification
 {
 NSLog(@"keyboard notification");
 NSDictionary* info = [aNotification userInfo];
 CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
 //Caclulate the height of the toolbar
 CGFloat toolbarHeight = [toolbar frame].size.height;
 
 //Get the bounds of the parent view
 CGRect rootViewBounds = self.parentViewController.view.bounds;
 
 //Get the height of the parent view.
 CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
 
 //Get the width of the parent view,
 CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
 //Create a rectangle for the toolbar
 CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight -kbSize.height, rootViewWidth, toolbarHeight);
 [toolbar setFrame:rectArea];
 
 
 }
 
 - (void)keyboardWillBeHidden:(NSNotification*)aNotification
 {
 //UIEdgeInsets contentInsets = UIEdgeInsetsZero;
 //scrollView.contentInset = contentInsets;
 //scrollView.scrollIndicatorInsets = contentInsets;
 }
 */

- (void)messageReceivedUpdate:(NSNotification *)notification{
    
    //play audio alert
    SystemSoundID soundID;
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"ALARM" ofType:@"WAV"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) [NSURL fileURLWithPath:soundFile], &soundID);    
    AudioServicesPlayAlertSound(soundID);
    
    [tbl reloadData];
    NSUInteger index = [messages count] - 1;
    [tbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    // Retrieve information about the document and update the panel
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [[self view] endEditing:TRUE];
    
}

//set max characters for textfield
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= 160 && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {return YES;}
}

@end

