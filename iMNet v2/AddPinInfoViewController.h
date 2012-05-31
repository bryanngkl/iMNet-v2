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

@protocol AddPinInfoViewControllerDelegate;

@interface AddPinInfoViewController : UIViewController {
    
    id<AddPinInfoViewControllerDelegate>delegate;
    UITextField *title;
    UITextView *description;
}
- (IBAction)Back:(id)sender;

@property (nonatomic,retain) IBOutlet UITextField *title;
@property (nonatomic,retain) IBOutlet UITextView *description;
@property (nonatomic, retain) IBOutlet UILabel *coordinates;


@property (nonatomic, unsafe_unretained) id<AddPinInfoViewControllerDelegate> delegate;

@end
