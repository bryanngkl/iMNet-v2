//
//  MessageLogViewController.h
//  iMNet v2
//
//  Created by Bryan on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageViewController.h"
//CoreData
#import "Messages.h"

@interface MessageLogViewController : UITableViewController{
    IBOutlet UITableView *tbl;
    IBOutlet UITextField *field;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *sendbutton;
    NSMutableArray *messages;
    NSMutableArray *messagefromselectedcontact;
    NSArray *sortedMessages;
    
    //core data instance variables
    NSManagedObjectContext *managedObjectContext; 
    Contacts *currentContact;
    
}

- (IBAction)add:(id)sender;
- (IBAction)goBack:(id)sender;
@property (nonatomic, retain) UITableView *tbl;
@property (nonatomic, retain) UITextField *field;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSMutableArray *messages;



@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext; 
@property (nonatomic,retain) NSMutableArray *messagefromselectedcontact;
@property (nonatomic,retain) NSArray *sortedMessages;

@property (nonatomic,retain) Contacts *currentContact;


@end
