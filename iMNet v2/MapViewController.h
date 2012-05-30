//
//  MapViewController.h
//  GUI_1
//
//  Created by Kenneth on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"
#import <Foundation/Foundation.h>
#import "ConvertLocationData.h"
#import "RMMapView.h"





@interface MapViewController : UIViewController <MyCLControllerDelegate> 

{   
    
     
    //MapView
    IBOutlet RMMapView *mapView;
    MyCLController *locationController;
    float startlat;
    float startlon;
    RMMarker *currentLocationMarker;
    RMMarker *currentlyTappedMarker;
    CLLocationCoordinate2D locationOfCurrentlyTappedMarker;
    int count;
    
    IBOutlet UILabel *locationLabel;
}

@property (strong, nonatomic) IBOutlet RMMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *addInfo;

-(void) locationUpdate:(CLLocation *)location;
-(void) locationError:(NSError *)error;
- (IBAction)dropPin:(id)sender;
- (IBAction)locateMe:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *unhideButton;
- (IBAction)sendLocation:(id)sender;
- (IBAction)deleteCurrentPin:(id)sender;
- (IBAction)getNearbyInfo:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *deletePin;


@end
