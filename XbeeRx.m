//
//  XbeeRx.m
//  iMNet
//
//  Created by Kenneth on 1/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "XbeeRx.h"


@implementation XbeeRx
@synthesize startbyte,length,frametype,AT1,AT2,sourceAddr64,sourceAddr16,receiveoptions,receiveddata,checksum,nodeidentifier,parentnetworkaddress,devicetype,sourceAddr16HexString,sourceAddr64HexString,frameID,ack,retries,startID,endID,msgType,ATString,ATCommandResponse,ATCommandResponseHex;

- (void) createRxInfo:(NSMutableArray *)rxBuffer{
        
    //get the standard first 4 bytes of data
    startbyte = [rxBuffer objectAtIndex:0]; 
    lengthbyteMSB = [rxBuffer objectAtIndex:1];//(NSString*)[rxstring characterAtIndex:1];
    lengthbyteLSB = [rxBuffer objectAtIndex:2];//(NSString*)[rxstring characterAtIndex:2];
    //Find length of msg
    length = [lengthbyteMSB unsignedIntValue]*256 + [lengthbyteLSB unsignedIntValue];        
    //Get the frame type
    frametype = [rxBuffer objectAtIndex:3];//(NSString*)[rxstring characterAtIndex:3];

//    NSLog(@"the startbyte is %c",(char)[startbyte unsignedCharValue]);

    //if this is a normal receive packet, frametype = 0x90
    if ([frametype unsignedIntValue]== 144){ 
        NSIndexSet *sourceAddr64Index = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(4,8)];

        sourceAddr64 = [[NSMutableArray alloc] initWithArray:[rxBuffer objectsAtIndexes:sourceAddr64Index]];
        
        sourceAddr16 = [[NSMutableArray alloc] initWithObjects:[rxBuffer objectAtIndex:12],[rxBuffer objectAtIndex:13], nil];

        sourceAddr16HexString = [[hexConvert alloc] convertArrayToString:sourceAddr16];
        sourceAddr64HexString = [[hexConvert alloc] convertArrayToString:sourceAddr64];

        receiveoptions = [rxBuffer objectAtIndex:14];//(NSString*)[rxstring characterAtIndex:14];;
        
        //proprietary header bytes in transmit message: startID, endID, current FrameID and Message type
        startID = [[rxBuffer objectAtIndex:15] unsignedIntValue];
        endID = [[rxBuffer objectAtIndex:16] unsignedIntValue];
        frameID = [rxBuffer objectAtIndex:17];
        msgType = [[rxBuffer objectAtIndex:18] unsignedIntValue];   //1 = text message, 2 = picture
        
        
        //rxBuffer data
        NSIndexSet *receivedDataIndexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(19,(length - 16))];
        receiveddata = [[NSMutableArray alloc] initWithArray:[rxBuffer objectsAtIndexes:receivedDataIndexes]];
        
    }
    
    
    //if this is a transmit request acknowledgement, frametype = 0x8B
    if ([frametype unsignedIntValue]== 139){ 
        frameID = [rxBuffer objectAtIndex:4];

        sourceAddr16 = [[NSMutableArray alloc] initWithObjects:[rxBuffer objectAtIndex:5],[rxBuffer objectAtIndex:6], nil];
        
        sourceAddr16HexString = [[hexConvert alloc] convertArrayToString:sourceAddr16]; //update 16 bit address field

        retries = [rxBuffer objectAtIndex:7];    //number of retries
        ack = [rxBuffer objectAtIndex:8];        //delivery status. if 0, transmission was a success
        }
    
    
    //if this is a AT command response packet, frametype = 0x88
    if ([frametype unsignedIntValue] == 136){
        frameID = [rxBuffer objectAtIndex:4];//(NSString*)[rxstring characterAtIndex:4];;
        AT1 = [rxBuffer objectAtIndex:5];//(NSString*)[rxstring characterAtIndex:5];;
        AT2 = [rxBuffer objectAtIndex:6];//(NSString*)[rxstring characterAtIndex:6];;
        
        ATString = [NSString stringWithFormat:@"%c%c",[[rxBuffer objectAtIndex:5] charValue],[[rxBuffer objectAtIndex:6] charValue]];
        commandstatus = [rxBuffer objectAtIndex:7];//(NSString*)[rxstring characterAtIndex:7];

        
        if (([AT1 unsignedIntValue] == 78)&& ([AT2 unsignedIntValue] == 68)) { //if this is a ND command
            
            sourceAddr16 = [[NSMutableArray alloc] initWithObjects:[rxBuffer objectAtIndex:8],[rxBuffer objectAtIndex:9], nil];
            
            NSIndexSet *sourceAddr64Index = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(10,8)];
            sourceAddr64 = [[NSMutableArray alloc] initWithArray:[rxBuffer objectsAtIndexes:sourceAddr64Index]];
            
            sourceAddr16HexString = [[hexConvert alloc] convertArrayToString:sourceAddr16];
            sourceAddr64HexString = [[hexConvert alloc] convertArrayToString:sourceAddr64];
            
            int i = 18;
            nodeidentifier = [NSString stringWithFormat:@""];
            
            while ([[rxBuffer objectAtIndex:i] unsignedCharValue] != 0){
                nodeidentifier = [NSString stringWithFormat:@"%@%c",nodeidentifier,[[rxBuffer objectAtIndex:i]charValue]];
                i = i + 1;
            } 
            
            parentnetworkaddress = [[NSMutableArray alloc] initWithCapacity:2];
            [parentnetworkaddress addObject:[rxBuffer objectAtIndex:i+1]];
            [parentnetworkaddress addObject:[rxBuffer objectAtIndex:i+2]];
           
            devicetype = [rxBuffer objectAtIndex:(i+3)];
            
        }
        
        
        else{
            NSString* commandResponseString = [NSString alloc];
            NSString* commandResponseStringHex = [NSString alloc];

            commandResponseString = @"";
            commandResponseStringHex = @"";
            
            for (int i =8; i<(length +3); i++) {
                commandResponseString = [NSString stringWithFormat:@"%@%.c",commandResponseString,[[rxBuffer objectAtIndex:i] unsignedIntValue]];
                commandResponseStringHex = [NSString stringWithFormat:@"%@%.2x",commandResponseStringHex,[[rxBuffer objectAtIndex:i] unsignedIntValue]];
            }
            
            ATCommandResponse = commandResponseString;
            ATCommandResponseHex = commandResponseStringHex;
        }
    }
}

@end