//
//  ContactImageViewController.h
//  iMNet v2
//
//  Created by Bryan on 11/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactImageViewController : UIViewController{
    UIImage *currentImage;
    IBOutlet UIImageView *image;
}

@property (nonatomic,retain) UIImageView *image;
@property (nonatomic,retain) UIImage *currentImage;
@end
