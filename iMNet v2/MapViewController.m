//
//  MapViewController.m
//  GUI_1
//
//  Created by Kenneth on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#define kStartingZoom   1.0f
#import "RMMBTilesTileSource.h"
#import "RMMapContents.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "ConvertLocationData.h"
#import "DataClass.h"

@implementation MapViewController
@synthesize deletePin;
@synthesize mapView;
@synthesize addInfo;
@synthesize mapInUse;
@synthesize managedObjectContext;
@synthesize rscMgr;
@synthesize mytoolbar;


- (void)testMarkers
{
	RMMarkerManager *markerManager = [mapView markerManager];
	NSArray *markers = [markerManager markers];
	
	NSLog(@"Nb markers %d", [markers count]);
	
	NSEnumerator *markerEnumerator = [markers objectEnumerator];
	RMMarker *aMarker;
	
	while (aMarker = (RMMarker *)[markerEnumerator nextObject])
		
	{
		RMProjectedPoint point = [aMarker projectedLocation];
		NSLog(@"Marker projected location: east:%lf, north:%lf", point.easting, point.northing);
		CGPoint screenPoint = [markerManager screenCoordinatesForMarker: aMarker];
		NSLog(@"Marker screen location: X:%lf, Y:%lf", screenPoint.x, screenPoint.y);
		CLLocationCoordinate2D coordinates =  [markerManager latitudeLongitudeForMarker: aMarker];
		NSLog(@"Marker Lat/Lon location: Lat:%lf, Lon:%lf", coordinates.latitude, coordinates.longitude);
		
		[markerManager removeMarker:aMarker];
	}
	
	// Put the marker back
	RMMarker *marker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue.png"]
											anchorPoint:CGPointMake(0.5, 1.0)];
    [marker changeLabelUsingText:@"Hello"];
	
	[markerManager addMarker:marker AtLatLong:[[mapView contents] mapCenter]];
	
	//[marker release];
	markers  = [markerManager markersWithinScreenBounds];
	
	NSLog(@"Nb Markers in Screen: %d", [markers count]);
	
	//	[mapView getScreenCoordinateBounds];
	
	[markerManager hideAllMarkers];
	[markerManager unhideAllMarkers];
	
    
    ;}

#pragma mark Manipulating markers

- (BOOL)mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event
{
    /*
     //If you do not implement this function, then all drags on markers will be sent to the didDragMarker function.
     //If you always return YES you will get the same result
     //If you always return NO you will never get a call to the didDragMarker function
     NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
     // get documents path
     NSString *documentsPath = [paths objectAtIndex:0];
     // get the path to our Data/plist file
     NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"pinsInfo.plist"];
     NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
     NSString * key = (NSString *)currentlyTappedMarker.data;
     id objects = [plistDict objectForKey:key];
     NSLog(@"%@", [objects objectAtIndex:2]);
     */
    if ([(NSArray*)marker.data objectAtIndex:1] == @"Person") {
        return NO;
    }
    else
        return YES;
    
}



- (void)mapView:(RMMapView *)map didDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event 
{
    CGPoint position = [[[event allTouches] anyObject] locationInView:mapView];
	RMMarkerManager *markerManager = [mapView markerManager];
	NSLog(@"New location: east:%lf north:%lf", [marker projectedLocation].easting, [marker projectedLocation].northing);
	CGRect rect = [marker bounds];
	[markerManager moveMarker:marker AtXY:CGPointMake(position.x,position.y +rect.size.height/3)];
    
    // set currently Tapped marker
    currentlyTappedMarker = marker;
    currentlyTappedMarker.data = marker.data;
    
    //Update COREDATA
    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchLocation setEntity:locationEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationTitle == %@", [(NSArray*)marker.data objectAtIndex:0]];
    [fetchLocation setPredicate:predicate];
    
    NSError *error = nil;
    Location *fetchedResult = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] lastObject];
    
    ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
    NSString * locationstr = [convertManager createStringFromLocation:[markerManager latitudeLongitudeForMarker:marker]];
    
    if (!fetchedResult) {
        //create new Location
        Location *newLocation = (Location *) [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
        newLocation.locationTitle = [(NSArray*)marker.data objectAtIndex:0];
        newLocation.locationDescription = NULL;
        newLocation.locationLatitude = locationstr;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    else{
        fetchedResult.locationLatitude = locationstr;
        NSLog(@"New location stored in locationtitle = %@ is %@", fetchedResult.locationTitle, locationstr);
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    
    [marker hideLabel];
}



- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map
{
	NSLog(@"MARKER TAPPED!");
    [currentlyTappedMarker hideLabel];
    
    
    currentlyTappedMarker = marker;
    currentlyTappedMarker.data = marker.data;
    NSLog(@"the currently tapped market data is %@", [(NSArray*)currentlyTappedMarker.data objectAtIndex:0]);
    
    //Get coordinates of currently tapped marker
    RMMarkerManager *markerManager = [mapView markerManager];
    ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
    NSString * locationstr = [convertManager createStringFromLocation:[markerManager latitudeLongitudeForMarker:currentlyTappedMarker]];
    
    
    //Update data class    
    DataClass *obj = [DataClass getInstance];
    obj.title = [(NSArray*)currentlyTappedMarker.data objectAtIndex:0];
    obj.location = locationstr;
    
    //GET marker info from core data
    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchLocation setEntity:locationEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationTitle == %@", obj.title];
    [fetchLocation setPredicate:predicate];
    
    NSError *error = nil;
    Location *fetchedResult = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] lastObject];
    NSLog(@"From the COREDATA WE have retrived title= %@, location =%@ and description =%@", fetchedResult.locationTitle,fetchedResult.locationLatitude, fetchedResult.locationDescription);
    
    //Update data object's description
    obj.description = fetchedResult.locationDescription;
    
    
    NSLog(@"This is the string that we currently store key=title=%@, description=%@, location=%@",obj.title,obj.description,obj.location);
    
    [marker showLabel];
    
    
    
    if (marker != currentLocationMarker) {
        [addInfo setHidden:NO];
        [deletePin setHidden:NO];
    }
    else {
        [addInfo setHidden:NO];
        [deletePin setHidden:YES];
    }
    
    if ([(NSArray*)currentlyTappedMarker.data objectAtIndex:1] == @"Person"){
        if (currentlyTappedMarker != currentLocationMarker){
            NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
            NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
            [fetchLocation setEntity:locationEntity];
            
            NSError *error = nil;
            NSMutableArray *fetchedResultArray = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] mutableCopy];
            
            
            for (Location *eachlocation in fetchedResultArray){
                if (eachlocation.locationContact != NULL) { //a person marker
                    if (eachlocation.locationContact.address64 = [(NSArray*)currentlyTappedMarker.data objectAtIndex:2]){
                        obj.description =  eachlocation.locationContact.userData;
                        //nextViewController.macAddress = eachlocation.locationContact.address64;
                        //NSLog(@"The mac address sent is %@",eachlocation.locationContact.address64);
                    }
                }
            }
            
        }
    }
    
    if (currentlyTappedMarker == currentLocationMarker){
        /*----GET OWN SETTINGS----*/
        NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
        NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
        [fetchOwnSettings setEntity:ownSettingsEntity];
        NSError *error = nil;
        NSPredicate *predicateUserData = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserData"];
        [fetchOwnSettings setPredicate:predicateUserData];
        
        OwnSettings *fetchedUserData = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
        
        if (fetchedUserData) {
            obj.description = fetchedUserData.atSetting;
        } 
    }
}


#pragma mark Loading Views

-(void)viewWillAppear:(BOOL)animated{
    //hide navigationbar
    [self.navigationController setNavigationBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SOSReceivedUpdate:) name:@"SOSReceived" object:nil];
    
    DataClass *obj = [DataClass getInstance];
    
    
    if (mapInUse !=obj.map) {
        locationController = [[MyCLController alloc] init];
        locationController.delegate = self;
        [locationController.locationManager startUpdatingLocation];
        
        NSLog(@"Center: Lat: %lf Lon: %lf", mapView.contents.mapCenter.latitude, mapView.contents.mapCenter.longitude);
        
        CLLocationCoordinate2D startingPoint;
        
        
        startingPoint.latitude  = locationController.locationManager.location.coordinate.latitude;
        startingPoint.longitude = locationController.locationManager.location.coordinate.longitude;
        
        //test
        ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
        NSString *test = [convertManager createStringFromLocation:startingPoint];
        NSLog(@"This is the string that we will see %@",test);
        
        //get the filename of the chosen map
        DataClass *obj = [DataClass getInstance];
        
        NSURL *tilesURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:obj.map ofType:@"mbtiles"]];
        
        //NSURL *tilesURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"geography-class_f9f8b8" ofType:@"mbtiles"]];
        
        RMMBTilesTileSource *source = [[RMMBTilesTileSource alloc] initWithTileSetURL:tilesURL];
        
        [[RMMapContents alloc] initWithView:self.mapView tilesource:source centerLatLon:startingPoint zoomLevel:kStartingZoom maxZoomLevel:[source maxZoom] minZoomLevel:[source minZoom] backgroundImage:nil screenScale:1];
        
        //[[RMMapContents alloc] initWithView:self.mapView tilesource:source centerLatLon:startingPoint zoomLevel:kStartingZoom maxZoomLevel:5.45 minZoomLevel:[source minZoom] backgroundImage:nil];
        
        //[[RMMapContents alloc] initWithView:self.mapView tilesource:source centerLatLon:startingPoint zoomLevel:kStartingZoom maxZoomLevel:[source maxZoom] minZoomLevel:[source minZoom] backgroundImage:nil];
        
        mapView.enableRotate = NO;
        mapView.deceleration = NO;
        mapView.backgroundColor = [UIColor blackColor];
        mapView.contents.zoom = kStartingZoom;
        
        //set marker
        RMMarkerManager *markerManager = [mapView markerManager];
        [mapView setDelegate:self];
        currentLocationMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue.png"]
                                                     anchorPoint:CGPointMake(0.5, 1.0)];
        //[currentLocationMarker setTextForegroundColor:[UIColor blueColor]];
        //[currentLocationMarker changeLabelUsingText:@"Hello"];
        
        UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
        NSString *labelText =@"iMNet";
        UIColor *foregroundColor = [UIColor blueColor];
        UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        
        [currentLocationMarker changeLabelUsingText:labelText font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
        [markerManager addMarker:currentLocationMarker AtLatLong:startingPoint];
        
        //updating data class
        //DataClass *obj = [DataClass getInstance];
        obj.title = labelText;
        obj.description = @"add description";
        obj.location = [convertManager createStringFromLocation:startingPoint];
        NSLog(@"The data class currently has title = %@, description = %@, and location = %@", obj.title,obj.description,obj.location);
        NSArray *CLMdata = [[NSArray alloc] initWithObjects:labelText, @"Person", nil];
        
        currentLocationMarker.data = CLMdata;
        currentlyTappedMarker = currentLocationMarker;
        currentlyTappedMarker.data = CLMdata;
        
        //Plot the previous pins    
        
        mapInUse = obj.map;
    }
    
    //Returning from Add Pin Info VC
    //update currently tapped marker
    if (obj.newpininformationadded == @"YES") {
        
        NSArray *CLMdata = [[NSArray alloc] initWithObjects:obj.title, [(NSArray*)currentlyTappedMarker.data objectAtIndex:1], nil];
        currentlyTappedMarker.data = CLMdata;
        //update data class    
        [currentlyTappedMarker changeLabelUsingText:obj.title font:[UIFont fontWithName:@"Courier" size:10] foregroundColor:[UIColor blueColor] backgroundColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
        
        obj.newpininformationadded = @"NO";
    }
    
    if (obj.fromDetailedContactView == @"YES") {
        ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
        [mapView moveToLatLong:[convertManager createLoctionFromString:obj.location]];
        
        RMMarkerManager *markerManager = [mapView markerManager];
        NSArray *markers = [markerManager markers];
        
        NSLog(@"Nb markers %d", [markers count]);
        
        
        NSEnumerator *markerEnumerator = [markers objectEnumerator];
        RMMarker *aMarker;
        NSArray *samedata = [[NSArray alloc] initWithObjects:obj.title, @"Person", nil];

        //Pseudo tap on the contact marker
        while (aMarker = (RMMarker *)[markerEnumerator nextObject]){
            if ([aMarker.data isEqual: samedata]) {
                if ([[convertManager createStringFromLocation:[markerManager latitudeLongitudeForMarker:aMarker]]isEqualToString: obj.location]) {
                    [self tapOnMarker:aMarker onMap:mapView];
                }
            }
        }

        obj.fromDetailedContactView = @"NO";
    }
    
    
    RMMarkerManager *markerManager = [mapView markerManager];
	[mapView setDelegate:self];
    [markerManager removeMarkers]; //remove all markers
    
    CLLocationCoordinate2D newLocation;
    newLocation.latitude = locationController.locationManager.location.coordinate.latitude;
    newLocation.longitude = locationController.locationManager.location.coordinate.longitude;
    //[markerManager moveMarker:currentLocationMarker AtLatLon:newLocation];
    
    [mapView moveToLatLong:newLocation];
    
    /*-----------FROM VIEWDIDLOAD---------*/
    NSString *labelText =@"iMNet";
    NSString *mydescription = @"add description";
    
    //Get ownsettings---------------------------------
    
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    
    NSPredicate *predicateUsername = [NSPredicate predicateWithFormat:@"atCommand == %@",@"NI"];
    [fetchOwnSettings setPredicate:predicateUsername];
    
    NSError *error = nil;
    OwnSettings *fetchedUsername = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedUsername) {
        labelText = [NSString stringWithFormat:@"%@", [fetchedUsername atSetting]];
    }
    
    
    NSPredicate *predicateUserData = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserData"];
    [fetchOwnSettings setPredicate:predicateUserData];
    
    error = nil;
    OwnSettings *fetchedUserData = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedUserData) {
        mydescription = [fetchedUserData atSetting];
    }
    
    
    //-------------------------------------------------
    
    //set marker
    //RMMarkerManager *markerManager = [mapView markerManager];
	//[mapView setDelegate:self];
    currentLocationMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue.png"]
                                                 anchorPoint:CGPointMake(0.5, 1.0)];
    UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
    UIColor *foregroundColor = [UIColor blueColor];
    UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    [currentLocationMarker changeLabelUsingText:labelText font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
	[markerManager addMarker:currentLocationMarker AtLatLong:newLocation];
    
    ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
    //updating data class
    //DataClass *obj = [DataClass getInstance];
    obj.title = labelText;
    obj.description = mydescription;
    obj.location = [convertManager createStringFromLocation:newLocation];
    NSLog(@"The data class currently has title = %@, description = %@, and location = %@", obj.title,obj.description,obj.location);
    NSArray *CLMdata = [[NSArray alloc] initWithObjects:labelText, @"Person", nil];
    
    currentLocationMarker.data = CLMdata;
    currentlyTappedMarker = currentLocationMarker;
    currentlyTappedMarker.data = CLMdata;
    
    /*----UPDATE OWN LOCATION DATA------*/
    
    NSPredicate *predicateUserLocation = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserLocation"];
    [fetchOwnSettings setPredicate:predicateUserLocation];
    
    error = nil;
    OwnSettings *fetchedUserLocation = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedUserLocation) {
        //This method creates a new setting.
        fetchedUserLocation.atSetting = obj.location;
        NSLog(@"self location added");
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    else{
        OwnSettings *newSettings = (OwnSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
        
        [newSettings setAtCommand:@"UserLocation"];
        [newSettings setAtSetting:obj.location];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    
    /*----------------------------------*/
    
    
    
    
    //Plot the previous pins
    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchLocation setEntity:locationEntity];
    
    //NSError *error = nil;
    NSMutableArray *fetchedResultArray = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] mutableCopy];
    
    
    for (Location *eachlocation in fetchedResultArray){
        if (eachlocation.locationContact == NULL) { //not a person marker
            NSLog(@"THE LOCATIONS STORED IN COREDATA");
            NSLog(@"title : %@", eachlocation.locationTitle);
            
            RMMarkerManager *markerManager = [mapView markerManager];
            //[mapView setDelegate:self];
            RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-red.png"]
                                                        anchorPoint:CGPointMake(0.5, 1.0)];
            UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
            UIColor *foregroundColor = [UIColor blueColor];
            UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
            
            [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
            ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
            [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
            NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"notPerson", nil];
            currentlyTappedMarker = newMarker;
            currentlyTappedMarker.data = datatostore;
            [newMarker hideLabel];
            
        }
        else {
            if (([eachlocation.locationTitle length] >= 7) && ([[eachlocation.locationTitle substringToIndex:7] isEqualToString:@"(SOS)--"])){
                    NSLog(@"THE CONTACT LOCATIONS STORED IN COREDATA");
                    NSLog(@"title : %@", eachlocation.locationTitle);
                    
                    RMMarkerManager *markerManager = [mapView markerManager];
                    //[mapView setDelegate:self];
                    RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-red-withletter.png"] anchorPoint:CGPointMake(0.5, 1.0)];
                    UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
                    UIColor *foregroundColor = [UIColor blueColor];
                    UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
                    
                    [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
                    ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
                    [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
                    NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"Person",eachlocation.locationContact.address64, nil];
                    currentlyTappedMarker = newMarker;
                    currentlyTappedMarker.data = datatostore;
                    [newMarker hideLabel];
                }
            else{
                NSLog(@"THE CONTACT LOCATIONS STORED IN COREDATA");
                NSLog(@"title : %@", eachlocation.locationTitle);
                
                RMMarkerManager *markerManager = [mapView markerManager];
                //[mapView setDelegate:self];
                RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue-withletter.png"] anchorPoint:CGPointMake(0.5, 1.0)];
                UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
                UIColor *foregroundColor = [UIColor blueColor];
                UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
                
                [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
                ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
                [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
                NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"Person",eachlocation.locationContact.address64, nil];
                currentlyTappedMarker = newMarker;
                currentlyTappedMarker.data = datatostore;
                [newMarker hideLabel];
            }
        }
    }

}

- (void)viewWillDisappear:(BOOL)animated{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SOSReceived" object:nil];
    [super viewWillDisappear:animated];
}

-(void)SOSReceivedUpdate:(NSNotification *) notification{
    SystemSoundID soundID;
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"glass_sms" ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) [NSURL fileURLWithPath:soundFile], &soundID);    
    AudioServicesPlayAlertSound(soundID);
    
    RMMarkerManager *markerManager = [mapView markerManager];
	[mapView setDelegate:self];
    [markerManager removeMarkers]; //remove all markers
    
    CLLocationCoordinate2D newLocation;
    newLocation.latitude = locationController.locationManager.location.coordinate.latitude;
    newLocation.longitude = locationController.locationManager.location.coordinate.longitude;
    //[markerManager moveMarker:currentLocationMarker AtLatLon:newLocation];
    
    [mapView moveToLatLong:newLocation];
    DataClass *obj = [DataClass getInstance];
    
    /*-----------FROM VIEWDIDLOAD---------*/
    NSString *labelText =@"iMNet";
    NSString *mydescription = @"add description";
    
    //Get ownsettings---------------------------------
    
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    
    NSPredicate *predicateUsername = [NSPredicate predicateWithFormat:@"atCommand == %@",@"NI"];
    [fetchOwnSettings setPredicate:predicateUsername];
    
    NSError *error = nil;
    OwnSettings *fetchedUsername = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedUsername) {
        labelText = [NSString stringWithFormat:@"%@", [fetchedUsername atSetting]];
    }
    
    
    NSPredicate *predicateUserData = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserData"];
    [fetchOwnSettings setPredicate:predicateUserData];
    
    error = nil;
    OwnSettings *fetchedUserData = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedUserData) {
        mydescription = [fetchedUserData atSetting];
    }
    
    
    //-------------------------------------------------
    
    //set marker
    //RMMarkerManager *markerManager = [mapView markerManager];
	//[mapView setDelegate:self];
    currentLocationMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue.png"]
                                                 anchorPoint:CGPointMake(0.5, 1.0)];
    UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
    UIColor *foregroundColor = [UIColor blueColor];
    UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    [currentLocationMarker changeLabelUsingText:labelText font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
	[markerManager addMarker:currentLocationMarker AtLatLong:newLocation];
    
    ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
    //updating data class
    //DataClass *obj = [DataClass getInstance];
    obj.title = labelText;
    obj.description = mydescription;
    obj.location = [convertManager createStringFromLocation:newLocation];
    NSLog(@"The data class currently has title = %@, description = %@, and location = %@", obj.title,obj.description,obj.location);
    NSArray *CLMdata = [[NSArray alloc] initWithObjects:labelText, @"Person", nil];
    
    currentLocationMarker.data = CLMdata;
    currentlyTappedMarker = currentLocationMarker;
    currentlyTappedMarker.data = CLMdata;
    
    /*----UPDATE OWN LOCATION DATA------*/
    
    NSPredicate *predicateUserLocation = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserLocation"];
    [fetchOwnSettings setPredicate:predicateUserLocation];
    
    error = nil;
    OwnSettings *fetchedUserLocation = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedUserLocation) {
        //This method creates a new setting.
        fetchedUserLocation.atSetting = obj.location;
        NSLog(@"self location added");
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    else{
        OwnSettings *newSettings = (OwnSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
        
        [newSettings setAtCommand:@"UserLocation"];
        [newSettings setAtSetting:obj.location];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    
    /*----------------------------------*/
    
    
    
    
    //Plot the previous pins
    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchLocation setEntity:locationEntity];
    
    //NSError *error = nil;
    NSMutableArray *fetchedResultArray = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] mutableCopy];
    
    
    for (Location *eachlocation in fetchedResultArray){
        NSLog(@"%@", eachlocation.locationTitle);
        if (eachlocation.locationContact == NULL) { //not a person marker
            NSLog(@"THE LOCATIONS STORED IN COREDATA");
            NSLog(@"title : %@", eachlocation.locationTitle);
            
            RMMarkerManager *markerManager = [mapView markerManager];
            //[mapView setDelegate:self];
            RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-red.png"]
                                                        anchorPoint:CGPointMake(0.5, 1.0)];
            UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
            UIColor *foregroundColor = [UIColor blueColor];
            UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
            
            [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
            ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
            [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
            NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"notPerson", nil];
            currentlyTappedMarker = newMarker;
            currentlyTappedMarker.data = datatostore;
            [newMarker hideLabel];
            
        }
        else {
            if (([eachlocation.locationTitle length] >= 7) && ([[eachlocation.locationTitle substringToIndex:7] isEqualToString:@"(SOS)--"])){
                NSLog(@"THE CONTACT LOCATIONS STORED IN COREDATA");
                NSLog(@"title : %@", eachlocation.locationTitle);
                
                RMMarkerManager *markerManager = [mapView markerManager];
                //[mapView setDelegate:self];
                RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-red-withletter.png"] anchorPoint:CGPointMake(0.5, 1.0)];
                UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
                UIColor *foregroundColor = [UIColor blueColor];
                UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
                
                [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
                ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
                [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
                NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"Person",eachlocation.locationContact.address64, nil];
                currentlyTappedMarker = newMarker;
                currentlyTappedMarker.data = datatostore;
                [newMarker hideLabel];
            }
            else{
                NSLog(@"THE CONTACT LOCATIONS STORED IN COREDATA");
                NSLog(@"title : %@", eachlocation.locationTitle);
                
                RMMarkerManager *markerManager = [mapView markerManager];
                //[mapView setDelegate:self];
                RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue-withletter.png"] anchorPoint:CGPointMake(0.5, 1.0)];
                UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
                UIColor *foregroundColor = [UIColor blueColor];
                UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
                
                [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
                ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
                [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
                NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"Person",eachlocation.locationContact.address64, nil];
                currentlyTappedMarker = newMarker;
                currentlyTappedMarker.data = datatostore;
                [newMarker hideLabel];
            }
        }
    }
    
    if (obj.fromDetailedContactView == @"YES") {
        ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
        [mapView moveToLatLong:[convertManager createLoctionFromString:obj.location]];
        
        RMMarkerManager *markerManager = [mapView markerManager];
        NSArray *markers = [markerManager markers];
        
        NSLog(@"Nb markers %d", [markers count]);
        
        
        NSEnumerator *markerEnumerator = [markers objectEnumerator];
        RMMarker *aMarker;
        NSArray *samedata = [[NSArray alloc] initWithObjects:obj.title, @"Person", nil];
        
        //Pseudo tap on the contact marker
        while (aMarker = (RMMarker *)[markerEnumerator nextObject]){
            if ([aMarker.data isEqual: samedata]) {
                if ([[convertManager createStringFromLocation:[markerManager latitudeLongitudeForMarker:aMarker]]isEqualToString: obj.location]) {
                    [self tapOnMarker:aMarker onMap:mapView];
                }
            }
        }
        
        obj.fromDetailedContactView = @"NO";
    }
    
}

- (void)viewDidLoad
{
    //set toolbar
    
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
        [mytoolbar setFrame:CGRectMake(0, 405, 320, 58)];
    }
    else {
        [mytoolbar setFrame:CGRectMake(0, 950, 770, 58)];
    }
    
    NSLog(@"THE current device is %@",[[UIDevice currentDevice] model]);
    
    count =1;
    
    locationController = [[MyCLController alloc] init];
    locationController.delegate = self;
    [locationController.locationManager startUpdatingLocation];
    
    
	NSLog(@"Center: Lat: %lf Lon: %lf", mapView.contents.mapCenter.latitude, mapView.contents.mapCenter.longitude);
    
    CLLocationCoordinate2D startingPoint;
    
    
    startingPoint.latitude  = locationController.locationManager.location.coordinate.latitude;
    startingPoint.longitude = locationController.locationManager.location.coordinate.longitude;
    
    //test
    ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
    NSString *test = [convertManager createStringFromLocation:startingPoint];
    NSLog(@"This is the string that we will see %@",test);
    
    //get the filename of the chosen map
    DataClass *obj = [DataClass getInstance];
    mapInUse = obj.map;
    
    NSURL *tilesURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:obj.map ofType:@"mbtiles"]];
    
    //NSURL *tilesURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"london_hyde_park_72f42ffdasfs" ofType:@"mbtiles"]];
    
    RMMBTilesTileSource *source = [[RMMBTilesTileSource alloc] initWithTileSetURL:tilesURL];
    
    [[RMMapContents alloc] initWithView:self.mapView tilesource:source centerLatLon:startingPoint zoomLevel:kStartingZoom maxZoomLevel:[source maxZoom]  minZoomLevel:[source minZoom] backgroundImage:nil screenScale:1];
    
    mapView.enableRotate = NO;
    mapView.deceleration = NO;
    mapView.backgroundColor = [UIColor blackColor];
    mapView.contents.zoom = kStartingZoom;
    
    NSString *labelText =@"iMNet";
    NSString *mydescription = @"add description";
    
    //Get ownsettings---------------------------------
    
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    
    NSPredicate *predicateUsername = [NSPredicate predicateWithFormat:@"atCommand == %@",@"NI"];
    [fetchOwnSettings setPredicate:predicateUsername];
    
    NSError *error = nil;
    OwnSettings *fetchedUsername = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedUsername) {
        labelText = [NSString stringWithFormat:@"%@", [fetchedUsername atSetting]];
    }
    
    
    NSPredicate *predicateUserData = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserData"];
    [fetchOwnSettings setPredicate:predicateUserData];
    
    error = nil;
    OwnSettings *fetchedUserData = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedUserData) {
        mydescription = [fetchedUserData atSetting];
    }


    //-------------------------------------------------
    
    //set marker
    RMMarkerManager *markerManager = [mapView markerManager];
	[mapView setDelegate:self];
    currentLocationMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue.png"]
                                                 anchorPoint:CGPointMake(0.5, 1.0)];
    UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
    UIColor *foregroundColor = [UIColor blueColor];
    UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    [currentLocationMarker changeLabelUsingText:labelText font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
	[markerManager addMarker:currentLocationMarker AtLatLong:startingPoint];
    
    //updating data class
    //DataClass *obj = [DataClass getInstance];
    obj.title = labelText;
    obj.description = mydescription;
    obj.location = [convertManager createStringFromLocation:startingPoint];
    NSLog(@"The data class currently has title = %@, description = %@, and location = %@", obj.title,obj.description,obj.location);
    NSArray *CLMdata = [[NSArray alloc] initWithObjects:labelText, @"Person", nil];
    
    currentLocationMarker.data = CLMdata;
    currentlyTappedMarker = currentLocationMarker;
    currentlyTappedMarker.data = CLMdata;
    
    /*----UPDATE OWN LOCATION DATA------*/
    
    NSPredicate *predicateUserLocation = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserLocation"];
    [fetchOwnSettings setPredicate:predicateUserLocation];
    
    error = nil;
    OwnSettings *fetchedUserLocation = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedUserLocation) {
        //This method creates a new setting.
        fetchedUserLocation.atSetting = obj.location;
        NSLog(@"self location added");
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    else{
        OwnSettings *newSettings = (OwnSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
        
        [newSettings setAtCommand:@"UserLocation"];
        [newSettings setAtSetting:obj.location];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    
    /*----------------------------------*/
    
    
    
    
    //Plot the previous pins
    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchLocation setEntity:locationEntity];
    
    //NSError *error = nil;
    NSMutableArray *fetchedResultArray = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] mutableCopy];
    
    
    for (Location *eachlocation in fetchedResultArray){
        //NSLog(@"%@",eachlocation.locationTitle);
        if (eachlocation.locationContact == NULL) { //not a person marker
            NSLog(@"THE LOCATIONS STORED IN COREDATA");
            NSLog(@"title : %@", eachlocation.locationTitle);
            
            RMMarkerManager *markerManager = [mapView markerManager];
            //[mapView setDelegate:self];
            RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-red.png"]
                                                            anchorPoint:CGPointMake(0.5, 1.0)];
            UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
            UIColor *foregroundColor = [UIColor blueColor];
            UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
                
            [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
            ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
            [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
            NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"notPerson", nil];
            currentlyTappedMarker = newMarker;
            currentlyTappedMarker.data = datatostore;
            [newMarker hideLabel];
        
        }
        else {
            if (([eachlocation.locationTitle length] >= 7) && ([[eachlocation.locationTitle substringToIndex:7] isEqualToString:@"(SOS)--"])) {
                //if ([[eachlocation.locationTitle substringToIndex:7] isEqualToString:@"(SOS)--"]){
                    NSLog(@"THE CONTACT LOCATIONS STORED IN COREDATA");
                    NSLog(@"title : %@", eachlocation.locationTitle);
                    
                    RMMarkerManager *markerManager = [mapView markerManager];
                    //[mapView setDelegate:self];
                    RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-red-withletter.png"] anchorPoint:CGPointMake(0.5, 1.0)];
                    UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
                    UIColor *foregroundColor = [UIColor blueColor];
                    UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
                    
                    [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
                    ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
                    [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
                    NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"Person",eachlocation.locationContact.address64, nil];
                    currentlyTappedMarker = newMarker;
                    currentlyTappedMarker.data = datatostore;
                    [newMarker hideLabel];
               // }
            }
            else{
                NSLog(@"THE CONTACT LOCATIONS STORED IN COREDATA");
                NSLog(@"title : %@", eachlocation.locationTitle);
                
                RMMarkerManager *markerManager = [mapView markerManager];
                //[mapView setDelegate:self];
                RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue-withletter.png"] anchorPoint:CGPointMake(0.5, 1.0)];
                UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
                UIColor *foregroundColor = [UIColor blueColor];
                UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
                
                [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
                ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
                [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
                NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"Person",eachlocation.locationContact.address64, nil];
                currentlyTappedMarker = newMarker;
                currentlyTappedMarker.data = datatostore;
                [newMarker hideLabel];
            }
        }
    }
    
    if (obj.fromDetailedContactView == @"YES") {
        ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
        [mapView moveToLatLong:[convertManager createLoctionFromString:obj.location]];
        
        RMMarkerManager *markerManager = [mapView markerManager];
        NSArray *markers = [markerManager markers];
        
        NSLog(@"Nb markers %d", [markers count]);
        
        
        NSEnumerator *markerEnumerator = [markers objectEnumerator];
        RMMarker *aMarker;
        NSArray *samedata = [[NSArray alloc] initWithObjects:obj.title, @"Person", nil];
        
        //Pseudo tap on the contact marker
        while (aMarker = (RMMarker *)[markerEnumerator nextObject]){
            if ([aMarker.data isEqual: samedata]) {
                if ([[convertManager createStringFromLocation:[markerManager latitudeLongitudeForMarker:aMarker]]isEqualToString: obj.location]) {
                    [self tapOnMarker:aMarker onMap:mapView];
                }
            }
        }
        
        obj.fromDetailedContactView = @"NO";
    }
}



- (void)viewDidUnload {
    [self setAddInfo:nil];
    [self setDeletePin:nil];
    mapView = nil;
    mapView = nil;
    mapView = nil;
    [self setDeletePin:nil];
    mytoolbar = nil;
    [super viewDidUnload];
}


#pragma mark Actions on Map


- (void) afterMapMove: (RMMapView*) map{
    [addInfo setHidden:YES];
    [deletePin setHidden:YES];
}


- (void) singleTapOnMap: (RMMapView*) map At: (CGPoint) point{
    
    [addInfo setHidden:YES];
    [deletePin setHidden:YES];
    [currentlyTappedMarker hideLabel];
    
    NSLog(@"%@", [(NSArray*)currentlyTappedMarker.data objectAtIndex:0]);
    
}




#pragma mark CoreLocation

- (void)locationUpdate:(CLLocation *)location {
    
    
    float lat = location.coordinate.latitude;
    float longitude = location.coordinate.longitude;
    startlat = lat;
    startlon = longitude;
    CLLocationCoordinate2D newlocation =CLLocationCoordinate2DMake(lat, longitude);
    
    NSString *display = [NSString stringWithFormat:@"%f,%f",lat, longitude];
    RMMarkerManager *markerManager = [mapView markerManager];
    ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
    
    [markerManager moveMarker:currentLocationMarker AtLatLon:newlocation];
    
    locationLabel.text = display;
    //locationLabel.text = [location description];
    
    /*-----------UPDATE OWN LOCATION---------*/
    
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    NSError *error = nil;
    NSPredicate *predicateUserLocation = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserLocation"];
    [fetchOwnSettings setPredicate:predicateUserLocation];
    
    error = nil;
    OwnSettings *fetchedUserLocation = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedUserLocation) {
        //This method creates a new setting.
        fetchedUserLocation.atSetting = [convertManager createStringFromLocation:newlocation];
        //NSLog(@"self location updated");
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    else{
        OwnSettings *newSettings = (OwnSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
        
        [newSettings setAtCommand:@"UserLocation"];
        [newSettings setAtSetting:[convertManager createStringFromLocation:newlocation]];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
}

- (void)locationError:(NSError *)error {
    locationLabel.text = [error description];
}




#pragma mark Buttons

- (IBAction)dropPin:(id)sender {
    [currentlyTappedMarker hideLabel];
    
    //adding the marker
    RMMarkerManager *markerManager = [mapView markerManager];
	//[mapView setDelegate:self];
    RMMarker *marker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-red.png"]
											anchorPoint:CGPointMake(0.5, 1.0)];
    NSString *labelText =@"Add info";
    UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
    UIColor *foregroundColor = [UIColor blueColor];
    UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    //labelling the markers
    NSString * m = @"(M";
    NSString *num = [NSString stringWithFormat:@"%d)", count];
    NSString *mtag = [m stringByAppendingString:num];
    NSString *markertag = [labelText stringByAppendingString:mtag];    
    [marker changeLabelUsingText:markertag font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
	[markerManager addMarker:marker AtLatLong:[[mapView contents] mapCenter]];
    [currentlyTappedMarker showLabel];
    //updating data class
    DataClass *obj = [DataClass getInstance];
    obj.title = markertag;
    obj.description = @"";
    ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
    NSString *location = [convertManager createStringFromLocation:[[mapView contents] mapCenter]];
    obj.location =location;
    // to check
    NSLog(@"This is the string that we will store key=title=%@, description=%@, location=%@",obj.title,obj.description,obj.location);
    
    //updating tag of currently tapped marker
    NSArray *datatostore = [[NSArray alloc] initWithObjects:markertag, @"notPerson", nil];
    marker.data = datatostore;
    currentlyTappedMarker = marker;
    currentlyTappedMarker.data = marker.data;
    //Increase variable counter
    count = count +1;
    
    //Saving new marker to CoreData
    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchLocation setEntity:locationEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationTitle == %@", obj.title];
    [fetchLocation setPredicate:predicate];
    
    NSError *error = nil;
    Location *fetchedResult = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] lastObject];
    
    if (!fetchedResult) {
        //create new Location
        Location *newLocation = (Location *) [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
        newLocation.locationTitle = obj.title;
        newLocation.locationDescription = obj.description;
        newLocation.locationLatitude = obj.location;
        // newLocation.locationLongitude = NULL;
        NSError *error = nil;
        NSLog(@"NEW LOCATION SAVED");
        //[managedObjectContext save:&error ];
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    else{
        fetchedResult.locationLatitude = obj.location;
        NSError *error = nil;
        NSLog(@"LOCATION UPDATED");
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
}

- (IBAction)locateMe:(id)sender {
    RMMarkerManager *markerManager = [mapView markerManager];
	[mapView setDelegate:self];
    [markerManager removeMarkers]; //remove all markers
    
    CLLocationCoordinate2D newLocation;
    newLocation.latitude = locationController.locationManager.location.coordinate.latitude;
    newLocation.longitude = locationController.locationManager.location.coordinate.longitude;
    //[markerManager moveMarker:currentLocationMarker AtLatLon:newLocation];
    
    [mapView moveToLatLong:newLocation];
    DataClass *obj = [DataClass getInstance];
    
    /*-----------FROM VIEWDIDLOAD---------*/
    NSString *labelText =@"iMNet";
    NSString *mydescription = @"add description";
    
    //Get ownsettings---------------------------------
    
    NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
    NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
    [fetchOwnSettings setEntity:ownSettingsEntity];
    
    NSPredicate *predicateUsername = [NSPredicate predicateWithFormat:@"atCommand == %@",@"NI"];
    [fetchOwnSettings setPredicate:predicateUsername];
    
    NSError *error = nil;
    OwnSettings *fetchedUsername = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    if (fetchedUsername) {
        labelText = [NSString stringWithFormat:@"%@", [fetchedUsername atSetting]];
    }
    
    
    NSPredicate *predicateUserData = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserData"];
    [fetchOwnSettings setPredicate:predicateUserData];
    
    error = nil;
    OwnSettings *fetchedUserData = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedUserData) {
        mydescription = [fetchedUserData atSetting];
    }
    
    
    //-------------------------------------------------
    
    //set marker
    //RMMarkerManager *markerManager = [mapView markerManager];
	//[mapView setDelegate:self];
    currentLocationMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue.png"]
                                                 anchorPoint:CGPointMake(0.5, 1.0)];
    UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
    UIColor *foregroundColor = [UIColor blueColor];
    UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    [currentLocationMarker changeLabelUsingText:labelText font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
	[markerManager addMarker:currentLocationMarker AtLatLong:newLocation];
    
    ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
    //updating data class
    //DataClass *obj = [DataClass getInstance];
    obj.title = labelText;
    obj.description = mydescription;
    obj.location = [convertManager createStringFromLocation:newLocation];
    NSLog(@"The data class currently has title = %@, description = %@, and location = %@", obj.title,obj.description,obj.location);
    NSArray *CLMdata = [[NSArray alloc] initWithObjects:labelText, @"Person", nil];
    
    currentLocationMarker.data = CLMdata;
    currentlyTappedMarker = currentLocationMarker;
    currentlyTappedMarker.data = CLMdata;
    
    /*----UPDATE OWN LOCATION DATA------*/
    
    NSPredicate *predicateUserLocation = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserLocation"];
    [fetchOwnSettings setPredicate:predicateUserLocation];
    
    error = nil;
    OwnSettings *fetchedUserLocation = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
    
    if (fetchedUserLocation) {
        //This method creates a new setting.
        fetchedUserLocation.atSetting = obj.location;
        NSLog(@"self location added");
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    else{
        OwnSettings *newSettings = (OwnSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
        
        [newSettings setAtCommand:@"UserLocation"];
        [newSettings setAtSetting:obj.location];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    
    /*----------------------------------*/
    
    
    
    
    //Plot the previous pins
    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchLocation setEntity:locationEntity];
    
    //NSError *error = nil;
    NSMutableArray *fetchedResultArray = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] mutableCopy];
    
    
    for (Location *eachlocation in fetchedResultArray){
        NSLog(@"%@", eachlocation.locationTitle);
        if (eachlocation.locationContact == NULL) { //not a person marker
            NSLog(@"THE LOCATIONS STORED IN COREDATA");
            NSLog(@"title : %@", eachlocation.locationTitle);
            
            RMMarkerManager *markerManager = [mapView markerManager];
            //[mapView setDelegate:self];
            RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-red.png"]
                                                        anchorPoint:CGPointMake(0.5, 1.0)];
            UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
            UIColor *foregroundColor = [UIColor blueColor];
            UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
            
            [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
            ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
            [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
            NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"notPerson", nil];
            currentlyTappedMarker = newMarker;
            currentlyTappedMarker.data = datatostore;
            [newMarker hideLabel];
            
        }
        else {
            if (([eachlocation.locationTitle length] >= 7) && ([[eachlocation.locationTitle substringToIndex:7] isEqualToString:@"(SOS)--"])){
                    NSLog(@"THE CONTACT LOCATIONS STORED IN COREDATA");
                    NSLog(@"title : %@", eachlocation.locationTitle);
                    
                    RMMarkerManager *markerManager = [mapView markerManager];
                    //[mapView setDelegate:self];
                    RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-red-withletter.png"] anchorPoint:CGPointMake(0.5, 1.0)];
                    UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
                    UIColor *foregroundColor = [UIColor blueColor];
                    UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
                    
                    [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
                    ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
                    [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
                    NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"Person",eachlocation.locationContact.address64, nil];
                    currentlyTappedMarker = newMarker;
                    currentlyTappedMarker.data = datatostore;
                    [newMarker hideLabel];
                }
            else{
                NSLog(@"THE CONTACT LOCATIONS STORED IN COREDATA");
                NSLog(@"title : %@", eachlocation.locationTitle);
                
                RMMarkerManager *markerManager = [mapView markerManager];
                //[mapView setDelegate:self];
                RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue-withletter.png"] anchorPoint:CGPointMake(0.5, 1.0)];
                UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
                UIColor *foregroundColor = [UIColor blueColor];
                UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
                
                [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
                ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
                [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
                NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"Person",eachlocation.locationContact.address64, nil];
                currentlyTappedMarker = newMarker;
                currentlyTappedMarker.data = datatostore;
                [newMarker hideLabel];
            }
        }
    }
    
    if (obj.fromDetailedContactView == @"YES") {
        ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
        [mapView moveToLatLong:[convertManager createLoctionFromString:obj.location]];
        
        RMMarkerManager *markerManager = [mapView markerManager];
        NSArray *markers = [markerManager markers];
        
        NSLog(@"Nb markers %d", [markers count]);
        
        
        NSEnumerator *markerEnumerator = [markers objectEnumerator];
        RMMarker *aMarker;
        NSArray *samedata = [[NSArray alloc] initWithObjects:obj.title, @"Person", nil];
        
        //Pseudo tap on the contact marker
        while (aMarker = (RMMarker *)[markerEnumerator nextObject]){
            if ([aMarker.data isEqual: samedata]) {
                if ([[convertManager createStringFromLocation:[markerManager latitudeLongitudeForMarker:aMarker]]isEqualToString: obj.location]) {
                    [self tapOnMarker:aMarker onMap:mapView];
                }
            }
        }
        
        obj.fromDetailedContactView = @"NO";
    }

    /*---------------------------------------------*/
    
    /*
     RMMarker *marker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue.png"]
     anchorPoint:CGPointMake(0.5, 1.0)];
     [marker setTextForegroundColor:[UIColor blueColor]];
     [marker changeLabelUsingText:@"Hello"];
     [markerManager addMarker:marker AtLatLong:newLocation];
     [marker release];    
     */

    /*
    //plot new points
    //Get INFO from COREDATA
    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchLocation setEntity:locationEntity];
    
    NSError *error = nil;
    NSMutableArray *fetchedResultArray = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] mutableCopy];
    
    for (Location *eachlocation in fetchedResultArray){
        NSLog(@"THE LOCATIONS STORED IN COREDATA");
        NSLog(@"title : %@", eachlocation.locationTitle);
        if (eachlocation.locationContact == NULL){
            //if ((eachlocation.locationContact != NULL) && (eachlocation.locationTitle == [(NSArray*)currentlyTappedMarker.data objectAtIndex:0])) {
            RMMarkerManager *markerManager = [mapView markerManager];
            //[mapView setDelegate:self];
            RMMarker * newMarker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue-withletter.png"]
                                                        anchorPoint:CGPointMake(0.5, 1.0)];
            UIFont *labelFont = [UIFont fontWithName:@"Courier" size:10];
            UIColor *foregroundColor = [UIColor blueColor];
            UIColor *backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
            
            [newMarker changeLabelUsingText:eachlocation.locationTitle font:labelFont foregroundColor:foregroundColor backgroundColor:backgroundColor];
            ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
            [markerManager addMarker:newMarker AtLatLong:[convertManager createLoctionFromString:eachlocation.locationLatitude]];
            NSArray *datatostore = [[NSArray alloc] initWithObjects:eachlocation.locationTitle, @"Person", nil];
            currentlyTappedMarker = newMarker;
            currentlyTappedMarker.data = datatostore;
            [newMarker hideLabel];
        }
        
    }
    */
    
}


- (IBAction)deleteCurrentPin:(id)sender {
    
    //Delete the marker
    RMMarkerManager *markerManager = [mapView markerManager];
    [markerManager removeMarker:currentlyTappedMarker];
    
    
    
    //Delete the data from COREDATA
    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchLocation setEntity:locationEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationTitle == %@", [(NSArray*)currentlyTappedMarker.data objectAtIndex:0]];
    [fetchLocation setPredicate:predicate];
    
    NSError *error = nil;
    Location *fetchedResult = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] lastObject];
    [managedObjectContext deleteObject:fetchedResult];
    NSLog(@"MARKER DELETED ON COREDATA");
    if (![managedObjectContext save:&error]) {
        // Handle the error.
    }
    
    //Update currentlyTappedMarker
    currentlyTappedMarker = NULL;
    currentlyTappedMarker.data = NULL;
    
    [deletePin setHidden:YES];
    [addInfo setHidden:YES];
    
}

- (IBAction)getNearbyInfo:(id)sender {
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"GetPinInfoSegue"]) {
        AddPinInfoViewController *apivc = (AddPinInfoViewController *)[segue destinationViewController];
        DataClass *obj =[DataClass getInstance];
        apivc.title.text = obj.title;
        apivc.description.text = obj.description;
        apivc.delegate = self;
        
        AddPinInfoViewController *nextViewController = segue.destinationViewController;
        nextViewController.managedObjectContext = managedObjectContext;
        nextViewController.rscMgr = rscMgr;
        
        if (currentlyTappedMarker == currentLocationMarker){
        nextViewController.ownpintapped = @"YES";
            /*----GET OWN SETTINGS----*/
            NSFetchRequest *fetchOwnSettings = [[NSFetchRequest alloc] init];
            NSEntityDescription *ownSettingsEntity = [NSEntityDescription entityForName:@"OwnSettings" inManagedObjectContext:managedObjectContext];
            [fetchOwnSettings setEntity:ownSettingsEntity];
            NSError *error = nil;
            NSPredicate *predicateSH = [NSPredicate predicateWithFormat:@"atCommand == %@",@"SH"];
            [fetchOwnSettings setPredicate:predicateSH];
            
            OwnSettings *fetchedSH = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
            
            
            NSPredicate *predicateSL = [NSPredicate predicateWithFormat:@"atCommand == %@",@"SL"];
            [fetchOwnSettings setPredicate:predicateSL];
            
            OwnSettings *fetchedSL = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
            if (fetchedSH && fetchedSL) {
                nextViewController.macAddress = [NSString stringWithFormat:@"%@%@", [fetchedSH atSetting], [fetchedSL atSetting]];    
            }
            
            //Fetch organisation
            NSPredicate *predicateOrg = [NSPredicate predicateWithFormat:@"atCommand == %@",@"UserOrg"];
            [fetchOwnSettings setPredicate:predicateOrg];
            
            error = nil;
            OwnSettings *fetchedOrg = [[managedObjectContext executeFetchRequest:fetchOwnSettings error:&error] lastObject];
            
            if (fetchedOrg) {
                nextViewController.organisation = [fetchedOrg atSetting];
            }

        }
        
        else {
            nextViewController.ownpintapped = @"NO";
            nextViewController.macAddress = @"notPerson";
            nextViewController.organisation =@"?l";
        }
        
        if ([(NSArray*)currentlyTappedMarker.data objectAtIndex:1] == @"Person"){
            if (currentlyTappedMarker != currentLocationMarker){
                NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
                NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
                [fetchLocation setEntity:locationEntity];
                
                NSError *error = nil;
                NSMutableArray *fetchedResultArray = [[managedObjectContext executeFetchRequest:fetchLocation error:&error] mutableCopy];
                
                
                for (Location *eachlocation in fetchedResultArray){
                    if (eachlocation.locationContact != NULL) { //a person marker
                        if (eachlocation.locationContact.address64 = [(NSArray*)currentlyTappedMarker.data objectAtIndex:2]){
                            nextViewController.macAddress = eachlocation.locationContact.address64;
                            nextViewController.organisation = eachlocation.locationContact.userOrg;
                            NSLog(@"The mac address sent is %@",eachlocation.locationContact.address64);
                        }
                    }
                }

            }
        }
        
        NSLog(@"Passed Managed object context");
    }
    
}

# pragma mark Others

- (void) infoAddedWithTitle: (NSString *) title andDescription: (NSString*) description{
    //NSString *mymessage = [[NSString alloc] initWithString:message];
    NSLog(@"%@, %@", title, description);
    
    DataClass *obj = [DataClass getInstance];
    //updating currently tapped marker
    NSArray *CLMdata = [[NSArray alloc] initWithObjects:title, [(NSArray*)currentlyTappedMarker.data objectAtIndex:1], nil];
    currentlyTappedMarker.data = CLMdata;
    //update data class
    obj.title= title;
    obj.description =description;
    
    [currentlyTappedMarker changeLabelUsingText:title font:[UIFont fontWithName:@"Courier" size:10] foregroundColor:[UIColor blueColor] backgroundColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
    
}

- (void) didReceiveMessage:(NSString *)message{
    NSLog(@"%@", message);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end