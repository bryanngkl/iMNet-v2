//
//  MapChoseTableViewController.h
//  iMNet Bryan2
//
//  Created by Kenneth on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataClass.h"

@interface MapChoseTableViewController : UITableViewController{
    
    NSIndexPath *checkedIndexPath;
    NSString *mapChosen;

}

@property (nonatomic,retain) NSIndexPath *checkedIndexPath;
@property (nonatomic,retain) NSString *mapChosen;

@end
