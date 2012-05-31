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
    
    
    [marker hideLabel];
}



- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map
{
	NSLog(@"MARKER TAPPED!");
    [currentlyTappedMarker hideLabel];
    currentlyTappedMarker = marker;
    currentlyTappedMarker.data = marker.data;
    NSLog(@"the currently tapped market data is %@", [(NSArray*)currentlyTappedMarker.data objectAtIndex:0]);
    DataClass *obj = [DataClass getInstance];
    NSLog(@"This is the string that we currently store key=title=%@, description=%@, location=%@",obj.title,obj.description,obj.location);
    
    [marker showLabel];
    
    
    if (marker != currentLocationMarker) {
        [addInfo setHidden:NO];
        [deletePin setHidden:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    //hide navigationbar
    [self.navigationController setNavigationBarHidden:YES];
    
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
    
    
    //update currently tapped marker
    NSArray *CLMdata = [[NSArray alloc] initWithObjects:obj.title, [(NSArray*)currentlyTappedMarker.data objectAtIndex:1], nil];
    currentlyTappedMarker.data = CLMdata;
    //update data class    
    [currentlyTappedMarker changeLabelUsingText:obj.title font:[UIFont fontWithName:@"Courier" size:10] foregroundColor:[UIColor blueColor] backgroundColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
}


- (void)viewDidLoad
{
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
    
    //NSURL *tilesURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"geography-class_f9f8b8" ofType:@"mbtiles"]];
    
    RMMBTilesTileSource *source = [[RMMBTilesTileSource alloc] initWithTileSetURL:tilesURL];
    
    [[RMMapContents alloc] initWithView:self.mapView tilesource:source centerLatLon:startingPoint zoomLevel:kStartingZoom maxZoomLevel:5.45 minZoomLevel:[source minZoom] backgroundImage:nil screenScale:1];
    
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
    
    
}





- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
 - (void)dealloc
 {
 [mapView release];
 [locationController release];
 [unhideButton release];
 [currentLocationMarker release];
 [addInfo release];
 [super dealloc];
 }
 */

- (void)locationUpdate:(CLLocation *)location {
    
    
    float lat = location.coordinate.latitude;
    float longitude = location.coordinate.longitude;
    startlat = lat;
    startlon = longitude;
    CLLocationCoordinate2D newlocation =CLLocationCoordinate2DMake(lat, longitude);
    
    NSString *display = [NSString stringWithFormat:@"%f,%f",lat, longitude];
    RMMarkerManager *markerManager = [mapView markerManager];
    //ConvertLocationData *convertManager = [[ConvertLocationData alloc] init];
    
    [markerManager moveMarker:currentLocationMarker AtLatLon:newlocation];
    
    locationLabel.text = display;
    //locationLabel.text = [location description];
}

- (void)locationError:(NSError *)error {
    locationLabel.text = [error description];
}

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
    //currentlyTappedMarker.data = markertag;
    count = count +1;
}

- (IBAction)locateMe:(id)sender {
    RMMarkerManager *markerManager = [mapView markerManager];
	[mapView setDelegate:self];
    //[markerManager removeMarker:currentLocationMarker]; //remove current location marker
    
    CLLocationCoordinate2D newLocation;
    newLocation.latitude = locationController.locationManager.location.coordinate.latitude;
    newLocation.longitude = locationController.locationManager.location.coordinate.longitude;
    [markerManager moveMarker:currentLocationMarker AtLatLon:newLocation];
    
    [mapView moveToLatLong:newLocation];
    /*
     RMMarker *marker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"marker-blue.png"]
     anchorPoint:CGPointMake(0.5, 1.0)];
     [marker setTextForegroundColor:[UIColor blueColor]];
     [marker changeLabelUsingText:@"Hello"];
     [markerManager addMarker:marker AtLatLong:newLocation];
     [marker release];    
     */
    
}

- (void)viewDidUnload {
    [self setAddInfo:nil];
    [self setDeletePin:nil];
    mapView = nil;
    mapView = nil;
    mapView = nil;
    [self setDeletePin:nil];
    [super viewDidUnload];
}





- (IBAction)deleteCurrentPin:(id)sender {
    
    //Delete the marker
    RMMarkerManager *markerManager = [mapView markerManager];
    [markerManager removeMarker:currentlyTappedMarker];
    
    currentlyTappedMarker = NULL;
    currentlyTappedMarker.data = NULL;
    
    [deletePin setHidden:YES];
    [addInfo setHidden:YES];
    
}

- (IBAction)getNearbyInfo:(id)sender {
    }


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

@end