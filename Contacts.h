//
//  Contacts.h
//  iMNet v2
//
//  Created by Kenneth on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Images, Location, Messages;

@interface Contacts : NSManagedObject

@property (nonatomic, retain) NSString * address16;
@property (nonatomic, retain) NSString * address64;
@property (nonatomic, retain) NSNumber * isAvailable;
@property (nonatomic, retain) NSString * userData;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * userOrg;
@property (nonatomic, retain) Location *contactLocation;
@property (nonatomic, retain) NSSet *contactMessages;
@property (nonatomic, retain) NSSet *contactSentImage;
@end

@interface Contacts (CoreDataGeneratedAccessors)

- (void)addContactMessagesObject:(Messages *)value;
- (void)removeContactMessagesObject:(Messages *)value;
- (void)addContactMessages:(NSSet *)values;
- (void)removeContactMessages:(NSSet *)values;
- (void)addContactSentImageObject:(Images *)value;
- (void)removeContactSentImageObject:(Images *)value;
- (void)addContactSentImage:(NSSet *)values;
- (void)removeContactSentImage:(NSSet *)values;
@end
