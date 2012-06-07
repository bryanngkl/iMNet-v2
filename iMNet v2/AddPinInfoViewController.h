//
//  AddPinInfoViewController.h
//  iMNet v2
//
//  Created by Kenneth on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataClass.h"
#import "MapViewController.h"

#import "RscMgr.h"

//Coredata
#import "Location.h"

@protocol AddPinInfoViewControllerDelegate;

@interface AddPinInfoViewController : UIViewController {
    
    id<AddPinInfoViewControllerDelegate>delegate;
    UITextField *title;
    UITextView *description;
    
    RscMgr *rscMgr;
    
    //core data instance variables
    NSManagedObjectContext *managedObjectContext; 
    
}
- (IBAction)Back:(id)sender;

@property (nonatomic,retain) IBOutlet UITextField *title;
@property (nonatomic,retain) IBOutlet UITextView *description;
@property (nonatomic, retain) IBOutlet UILabel *coordinates;

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext; 
@property (nonatomic,retain) RscMgr *rscMgr;


@property (nonatomic, unsafe_unretained) id<AddPinInfoViewControllerDelegate> delegate;

@end
