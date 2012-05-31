//
//  Messages.h
//  iMNet v2
//
//  Created by Bryan on 31/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contacts;

@interface Messages : NSManagedObject

@property (nonatomic, retain) NSString * messageContents;
@property (nonatomic, retain) NSDate * messageDate;
@property (nonatomic, retain) NSNumber * messageReceived;
@property (nonatomic, retain) Contacts *messageFromContacts;

@end
