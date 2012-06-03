//
//  XbeeTx.h
//  iMNet
//
//  Created by Bryan on 24/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "hexConvert.h"

@interface XbeeTx : NSObject{
    NSMutableArray* txPacket;    
}

-   (void) TxBytes:(NSMutableArray *) MessageStr ofSize:(int)size andMessageType:(int)msgType withStartID:(int)startID withFrameID:(int) FrameID withPacketFrameId:(int) packetFrameID withDestNode64: (NSMutableArray *) DestNode64 withDestNetworkAddr16: (NSMutableArray *) DestNetAddr16;

-   (void) TxMessage: (NSString *) MessageStr ofSize:(int)size andMessageType:(int)msgType withStartID:(int)startID withFrameID:(int)FrameID  withPacketFrameId:(int)packetFrameID withDestNode64: (NSMutableArray *) DestNode64 withDestNetworkAddr16: (NSMutableArray *) DestNetAddr16;
-   (void) ATCommand: (NSString *) ATcmd withFrameID:(int) FrameID;
-   (void) ATCommandSetString:(NSString *) ATcmd withParameter:(NSString *) parameter withFrameID:(int) FrameID;
-   (void) ATCommandSetNumber:(NSString *) ATcmd withParameter:(NSMutableArray *) parameter withFrameID:(int) FrameID;
-   (void) TxRawApi: (NSString*) hexString;
-   (void) ATCommandTest;


@property (readonly, retain) NSMutableArray* txPacket;

@end
