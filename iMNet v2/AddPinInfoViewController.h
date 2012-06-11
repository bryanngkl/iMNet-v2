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
#import "SendLocationContactsViewController.h"
#import "ContactImageViewController.h"

#import "RscMgr.h"

//Coredata
#import "Location.h"
#import "Images.h"

@protocol AddPinInfoViewControllerDelegate;

@interface AddPinInfoViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextViewDelegate> {
    
    id<AddPinInfoViewControllerDelegate>delegate;
    UITextField *title;
    UITextView *description;
    
    IBOutlet UIImageView *locationPicture;
    
    RscMgr *rscMgr;
    
    //core data instance variables
    NSManagedObjectContext *managedObjectContext; 
    NSString *ownpintapped; 
    NSString * macAddress;
    NSString *organisation;
    
}
- (IBAction)Back:(id)sender;
- (IBAction)choosePhoto:(id)sender;
- (IBAction)takePhoto:(id)sender;

@property (nonatomic,retain) IBOutlet UITextField *title;
@property (nonatomic,retain) IBOutlet UITextView *description;
@property (nonatomic, retain) IBOutlet UILabel *coordinates;
@property (strong, nonatomic) IBOutlet UILabel *orglabel;

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext; 
@property (nonatomic,retain) RscMgr *rscMgr;
@property (nonatomic,retain) NSString *ownpintapped;
@property (nonatomic,retain) NSString * macAddress;
@property (nonatomic,retain) NSString *organisation;
@property (nonatomic,retain) UIImageView *locationPicture;

@property (nonatomic, unsafe_unretained) id<AddPinInfoViewControllerDelegate> delegate;

@end
