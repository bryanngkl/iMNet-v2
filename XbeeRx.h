//
//  XbeeRx.h
//  iMNet
//
//  Created by Kenneth on 1/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "hexConvert.h"

@interface XbeeRx : NSObject {
    NSNumber *startbyte;
    //char startbyte;
    //length
    NSNumber * lengthbyteMSB;
    NSNumber * lengthbyteLSB;
    int length;
    
    //For AT commands
    NSNumber * frametype;
    NSNumber * frameID;
    NSNumber * AT1;
    NSNumber * AT2;
    NSString * ATString;
    NSNumber * commandstatus;
    NSString * ATCommandResponseHex;
    NSString * ATCommandResponse;

    
    //For ATND
    NSMutableString * nodeidentifier;
    NSMutableArray * parentnetworkaddress;
    NSNumber * devicetype;
    
    //Generic data
    NSMutableArray *sourceAddr64;
    NSMutableArray * sourceAddr16;
    NSString * sourceAddr16HexString;
    NSString * sourceAddr64HexString;
    NSNumber * checksum;
    
    //For transmit request acknowledgement
    NSNumber * ack;
    NSNumber * retries;
    
    //For received packets
    int startID;
    int endID;
    int msgType;
    NSNumber * receiveoptions;
    NSMutableArray * receiveddata;

}

- (void) createRxInfo: (NSMutableArray *) rxBuffer;



@property (readonly) NSNumber* startbyte;
@property (readonly) int length;
@property (readonly) int startID;
@property (readonly) int endID;
@property (readonly) int msgType;
@property (readonly) NSNumber* frametype;
@property (readonly) NSNumber* frameID;
@property (readonly) NSNumber* AT1;
@property (readonly) NSNumber* AT2;
@property (readonly) NSMutableArray * sourceAddr64;
@property (readonly) NSMutableArray * sourceAddr16;
@property (readonly) NSNumber * receiveoptions;
@property (readonly) NSMutableArray * receiveddata;
@property (readonly) NSNumber* checksum;
@property (readonly) NSMutableString * nodeidentifier;
@property (readonly) NSMutableArray * parentnetworkaddress;
@property (readonly) NSNumber* devicetype;
@property (readonly) NSNumber* ack;
@property (readonly) NSNumber* retries;
@property (readonly) NSString* sourceAddr16HexString;
@property (readonly) NSString* sourceAddr64HexString;
@property (readonly) NSString *ATString;
@property (readonly) NSString *ATCommandResponse;
@property (readonly) NSString *ATCommandResponseHex;

@end
