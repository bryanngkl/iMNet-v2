//
//  MessageViewController.h
//  iMNet v2
//
//  Created by Bryan on 30/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageViewController : UITableViewController{
    
    //core data instance variables
    NSManagedObjectContext *managedObjectContext;   
    
}

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;  

@end
