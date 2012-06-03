//
//  hexConvert.h
//  iMNet Bryan
//
//  Created by Bryan on 10/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface hexConvert : NSObject {
    
}

-   (NSMutableArray *) convertStringToArray:(NSString *)hexString;
-   (NSString *) convertArrayToString:(NSMutableArray *)hexArray;

@end
