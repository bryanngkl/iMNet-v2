//
//  MessageViewController.h
//  iMNet v2
//
//  Created by Bryan on 30/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contacts.h"
#import "Messages.h"
#import "MessageLogViewController.h"


@interface MessageViewController : UITableViewController{
    
    //core data instance variables
    NSManagedObjectContext *managedObjectContext;   
    NSMutableArray *fetchedContactsArray;
    NSMutableArray *fetchedMessagesArray;
    
}

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;  

@end
