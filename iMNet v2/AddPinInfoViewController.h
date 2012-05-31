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



@interface AddPinInfoViewController : UIViewController {
    
    UITextField *title;
    UITextView *description;
}

@property (nonatomic,retain) IBOutlet UITextField *title;
@property (nonatomic,retain) IBOutlet UITextView *description;
@property (nonatomic, retain) IBOutlet UILabel *coordinates;


@end
