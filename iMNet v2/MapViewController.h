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
#import "AddPinInfoViewController.h"
#import "Location.h"


@protocol AddPinInfoViewControllerDelegate
- (void) infoAddedWithTitle: (NSString *) title andDescription: (NSString*) description;
- (void) didReceiveMessage:(NSString *)message;
@end 

@interface MapViewController : UIViewController <MyCLControllerDelegate, AddPinInfoViewControllerDelegate> 

{   
    //core data instance variables
    NSManagedObjectContext *managedObjectContext;    
    
     
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
    
    NSString *mapInUse;
    
}



-(void) locationUpdate:(CLLocation *)location;
-(void) locationError:(NSError *)error;

//Add Pin
- (IBAction)dropPin:(id)sender;

//Refresh Button: Locate me + getNearbyInfo
- (IBAction)locateMe:(id)sender;
- (IBAction)getNearbyInfo:(id)sender;

//Delete Pin
- (IBAction)deleteCurrentPin:(id)sender;


@property (strong, nonatomic) IBOutlet RMMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *deletePin;
@property (strong, nonatomic) IBOutlet UIButton *addInfo;
@property (nonatomic,retain) NSString *mapInUse;


//core data methods
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;  


//- (IBAction)sendLocation:(id)sender;





@end
