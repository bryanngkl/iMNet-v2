//
//  Location.h
//  iMNet v2
//
//  Created by Bryan on 31/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contacts;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * locationDescription;
@property (nonatomic, retain) NSString * locationLatitude;
@property (nonatomic, retain) NSString * locationTitle;
@property (nonatomic, retain) Contacts *locationContact;

@end
