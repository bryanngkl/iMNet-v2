//
//  OwnSettings.h
//  iMNet v2
//
//  Created by Bryan on 31/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface OwnSettings : NSManagedObject

@property (nonatomic, retain) NSString * atCommand;
@property (nonatomic, retain) NSString * atSetting;

@end
