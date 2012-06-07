//
//  DataClass.h
//  MBTiles Example
//
//  Created by Kenneth on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataClass : NSObject{
    NSString * location;
    NSString * title;
    NSString * description;
    NSString * map;
    NSString * newpininformationadded;
    NSString *fromDetailedContactView;
}

@property (nonatomic, strong) NSString * location;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * description;
@property (nonatomic, strong) NSString * map;
@property (nonatomic, strong) NSString * newpininformationadded;
@property (nonatomic, strong) NSString *fromDetailedContactView;
+(DataClass*)getInstance;    


@end
