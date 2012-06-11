//
//  Images.h
//  iMNet v2
//
//  Created by Bryan on 11/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contacts, Location;

@interface Images : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imageDescription;
@property (nonatomic, retain) NSString * imageSender64;
@property (nonatomic, retain) Contacts *imageFromContacts;
@property (nonatomic, retain) Location *imageLocation;

@end
