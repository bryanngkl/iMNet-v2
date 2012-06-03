//
//  XbeeTx.m
//  iMNet
//
//  Created by Bryan on 24/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "XbeeTx.h"

@implementation XbeeTx

@synthesize txPacket;

- (id)init
{
    self = [super init];
    if (self) {
        txPacket = [NSMutableArray alloc];
        // Initialization code here.
    }
    
    return self;
}

//Transmit a message in the form of an array of bytes
-   (void) TxBytes:(NSMutableArray *) MessageStr ofSize:(int)size andMessageType:(int)msgType withStartID:(int)startID withFrameID:(int)FrameID withPacketFrameId:(int)packetFrameID withDestNode64: (NSMutableArray *) DestNode64 withDestNetworkAddr16: (NSMutableArray *) DestNetAddr16{

    NSMutableArray* transmitPacket = [[NSMutableArray alloc] initWithCapacity:([MessageStr count]+22)];
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:126]];  //add start byte to start of packet array
    
    
    NSNumber* Framelength = [[NSNumber alloc] initWithUnsignedInteger:([MessageStr count] + 18)];
    NSNumber* lengthHighByte;
    NSNumber* lengthLowByte;
    
    lengthHighByte = [[NSNumber alloc] initWithUnsignedInteger:([Framelength intValue] / 256)]; //calculate int value of high bytes
    lengthLowByte = [[NSNumber alloc] initWithUnsignedInteger:([Framelength intValue] % 256)];  //calculate int value of low bytes
    [transmitPacket addObject:lengthHighByte];      //add bytes 1 and 2 to the transmit packet
    [transmitPacket addObject:lengthLowByte];       
    
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:16]]; //Frame type is 0x10 for transmit packet
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:FrameID]]; //Set FrameID
    
    [transmitPacket addObjectsFromArray:DestNode64];    //Set 64 bit MAC address
    [transmitPacket addObjectsFromArray:DestNetAddr16]; //Set 16 bit Network Address
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:0]];  //Set broadcast radius to maximum (i.e. 0)
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:0]];  //No additional options such as encryption
    
    
    //proprietary header bytes in transmit message: startID, endID, current FrameID and Message type
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:startID]]; //startID of packet
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:(startID + size)]];   //size = 0 corresponds to only one packet, giving startID = endID
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:packetFrameID]]; //frameID of current packet
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:msgType]]; //1 = text message, 2 = picture
    
    [transmitPacket addObjectsFromArray:MessageStr];    //add entire array of bytes to the payload
        
    int sum = 0;    
    for (int i = 3; i<(int)([transmitPacket count]);i++){
        sum = sum + [[transmitPacket objectAtIndex:i] unsignedIntValue];   //sum up all bytes involved in checksum
    }
    int chksum = 255-(sum%256);         //0xFF - last 8 bytes of sum
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:(chksum)]];   //attach checksum to end of message
    
    txPacket =transmitPacket;  //output to instance variable txPacket
    /*  
     [Framelength release];      //release all objects created here
     [lengthHighByte release];
     [lengthLowByte release];
     [MessageArray release]; */
    //[transmitPacket release];
}



//Transmit a message in the form of a string
-   (void) TxMessage: (NSString *) MessageStr ofSize:(int)size andMessageType:(int)msgType withStartID:(int)startID withFrameID:(int) FrameID withPacketFrameId:(int) packetFrameID withDestNode64: (NSMutableArray *) DestNode64 withDestNetworkAddr16: (NSMutableArray *) DestNetAddr16{
    
    NSMutableArray* transmitPacket = [[NSMutableArray alloc] initWithCapacity:([MessageStr length]+22)];
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:126]];  //add start byte to start of packet array
    
    
    NSNumber* Framelength = [[NSNumber alloc] initWithUnsignedInteger:([MessageStr length] + 18)];
    NSNumber* lengthHighByte;
    NSNumber* lengthLowByte;
     
    lengthHighByte = [[NSNumber alloc] initWithUnsignedInteger:([Framelength intValue] / 256)]; //calculate int value of high bytes
    lengthLowByte = [[NSNumber alloc] initWithUnsignedInteger:([Framelength intValue] % 256)];  //calculate int value of low bytes
    [transmitPacket addObject:lengthHighByte];      //add bytes 1 and 2 to the transmit packet
    [transmitPacket addObject:lengthLowByte];       
    
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:16]]; //Frame type is 0x10 for transmit packet
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:FrameID]]; //Set FrameID
      
    [transmitPacket addObjectsFromArray:DestNode64];    //Set 64 bit MAC address
    [transmitPacket addObjectsFromArray:DestNetAddr16]; //Set 16 bit Network Address
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:0]];  //Set broadcast radius to maximum (i.e. 0)
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:0]];  //No additional options such as encryption
    
    
    //proprietary header bytes in transmit message: startID, endID, current FrameID and Message type
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:startID]]; //startID of packet
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:(startID + size)]];   //size = 0 corresponds to only one packet, giving startID = endID
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:packetFrameID]]; //frameID of current packet
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:msgType]]; //1 = text message, 2 = picture
    
    NSMutableArray* MessageArray = [[NSMutableArray alloc] initWithCapacity:[MessageStr length]];   //initialise message array to convert string to bytes
    
    int messageBytes = [MessageStr length]; 
    
    for ( int i = 0; i < messageBytes; i++ ) {          //convert string of characters to array of integers
        [MessageArray addObject:[NSNumber numberWithUnsignedInt:((int)[MessageStr characterAtIndex:i])]];
    }  
    
    [transmitPacket addObjectsFromArray:MessageArray];  //add array of message characters to transmit packet
    
    int sum = 0;    
    for (int i = 3; i<(int)([transmitPacket count]);i++){
        sum = sum + [[transmitPacket objectAtIndex:i] unsignedIntValue];   //sum up all bytes involved in checksum
    }
    int chksum = 255-(sum%256);         //0xFF - last 8 bytes of sum
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:(chksum)]];   //attach checksum to end of message

    txPacket =transmitPacket;  //output to instance variable txPacket
  /*  
    [Framelength release];      //release all objects created here
    [lengthHighByte release];
    [lengthLowByte release];
    [MessageArray release]; */
    //[transmitPacket release];
}



-   (void) ATCommand:(NSString *) ATcmd withFrameID:(int) FrameID{   // for ATND, ATJN, ATWR, ATNI and ATNR
    
    NSMutableArray* transmitPacket = [[NSMutableArray alloc] initWithCapacity:8];
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:126]];  //add start byte to start of packet array

    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:0]];      //MSB length of packet = 0
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:4]];      //LSB length of packet = 4
    
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:8]]; //Frame type is 0x08 for AT Command Packet
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:FrameID]]; //Set FrameID
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:((int)[ATcmd characterAtIndex:0])]];  //set first letter of AT command
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:((int)[ATcmd characterAtIndex:1])]];  //set second letter of AT command

    int sum = 0;    
    for (int i = 3; i<(int)([transmitPacket count]);i++){
        sum = sum + [[transmitPacket objectAtIndex:i] unsignedIntValue];   //sum up all bytes involved in checksum
    }
    int chksum = 255-(sum%256);         //0xFF - last 8 bytes of sum
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:(chksum)]];   //attach checksum to end of message
    txPacket = transmitPacket;
//  [txPacket initWithArray:transmitPacket];  //output to instance variable txPacket

//  [transmitPacket release];
}



-   (void) ATCommandSetString:(NSString *) ATcmd withParameter:(NSString *) parameter withFrameID:(int) FrameID{ // Command refers to either NI(user defined setting), DN(destination node) or ID(PAN ID setting)
    NSMutableArray* transmitPacket = [[NSMutableArray alloc] initWithCapacity:((int)[parameter length]+8)];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:126]];  //add start byte to start of packet array
    
    NSNumber* Framelength = [[NSNumber alloc] initWithUnsignedInt:([parameter length] + 4)];
    NSNumber* lengthHighByte;
    NSNumber* lengthLowByte;
    
    lengthHighByte = [[NSNumber alloc] initWithUnsignedInteger:([Framelength intValue] / 256)]; //calculate int value of high bytes
    lengthLowByte = [[NSNumber alloc] initWithUnsignedInteger:([Framelength intValue] % 256)];  //calculate int value of low bytes
    [transmitPacket addObject:lengthHighByte];      //add length bytes 1 and 2 to the transmit packet
    [transmitPacket addObject:lengthLowByte]; 
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:8]]; //Frame type is 0x08 for AT Command Packet
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:FrameID]]; //Set FrameID
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:((int)[ATcmd characterAtIndex:0])]];  //set first letter of AT command
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:((int)[ATcmd characterAtIndex:1])]];  //set second letter of AT command
    
    NSMutableArray* parameterArray = [[NSMutableArray alloc] initWithCapacity:[parameter length]];   //initialise message array to convert string to bytes
    
    int paramBytes = (int)[parameter length]; 
    for ( int i = 0; i < paramBytes; i++ ) {          //convert string of characters to array of integers
        [parameterArray addObject:[NSNumber numberWithUnsignedInt:((int)[parameter characterAtIndex:i])]];
    }  
    [transmitPacket addObjectsFromArray:parameterArray];  //add array of parameter characters to transmit packet
    
    int sum = 0;    
    for (int i = 3; i<(int)([transmitPacket count]);i++){
        sum = sum + [[transmitPacket objectAtIndex:i] unsignedIntValue];   //sum up all bytes involved in checksum
    }
    int chksum = 255-(sum%256);         //0xFF - last 8 bytes of sum
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:(chksum)]];   //attach checksum to end of message
    txPacket = transmitPacket;  //output to instance variable txPacket
   // [transmitPacket release];
   /* [Framelength release];
    [lengthLowByte release];
    [lengthHighByte release];
    [parameterArray release];*/
}



-   (void) ATCommandSetNumber:(NSString *)ATcmd withParameter:(NSMutableArray *)parameter withFrameID:(int) FrameID{ // Command refers to either NI(user defined setting), DN(destination node) or ID(PAN ID setting)
    NSMutableArray* transmitPacket = [[NSMutableArray alloc] initWithCapacity:((int)[parameter count]+8)];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:126]];  //add start byte to start of packet array
    
    NSNumber* Framelength = [[NSNumber alloc] initWithUnsignedInt:([parameter count] + 4)];
    NSNumber* lengthHighByte;
    NSNumber* lengthLowByte;
    
    lengthHighByte = [[NSNumber alloc] initWithUnsignedInteger:([Framelength intValue] / 256)]; //calculate int value of high bytes
    lengthLowByte = [[NSNumber alloc] initWithUnsignedInteger:([Framelength intValue] % 256)];  //calculate int value of low bytes
    [transmitPacket addObject:lengthHighByte];      //add length bytes 1 and 2 to the transmit packet
    [transmitPacket addObject:lengthLowByte]; 
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:8]]; //Frame type is 0x08 for AT Command Packet
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:FrameID]]; //Set FrameID
    
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:((int)[ATcmd characterAtIndex:0])]];  //set first letter of AT command
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:((int)[ATcmd characterAtIndex:1])]];  //set second letter of AT command
    
    
    int paramBytes = (int)[parameter count]; 
    for ( int i = 0; i < paramBytes; i++ ) {          //convert string of characters to array of integers
        [transmitPacket addObject:[parameter objectAtIndex:i]];
    }  
    
    int sum = 0;    
    for (int i = 3; i<(int)([transmitPacket count]);i++){
        sum = sum + [[transmitPacket objectAtIndex:i] unsignedIntValue];   //sum up all bytes involved in checksum
    }
    int chksum = 255-(sum%256);         //0xFF - last 8 bytes of sum
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:(chksum)]];   //attach checksum to end of message
    txPacket = transmitPacket;  //output to instance variable txPacket
    // [transmitPacket release];
    
    /*
    [Framelength release];
    [lengthLowByte release];
    [lengthHighByte release];
     
     */
}



-   (void) TxRawApi: (NSString *) hexString{ //attach checksum to end of api frame

    NSMutableArray *transmitPacket = [[NSMutableArray alloc] initWithCapacity:(1+([hexString length]/2))];
    uint dec;
    NSString *byteString;
    NSScanner *scan;
        
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:126]];  //add start byte to start of packet array
    
    int length = ([hexString length]/2) - 3;
    
    NSNumber* lengthHighByte;
    NSNumber* lengthLowByte;
    
    lengthHighByte = [[NSNumber alloc] initWithUnsignedInteger:(length / 256)]; //calculate int value of high bytes
    lengthLowByte = [[NSNumber alloc] initWithUnsignedInteger:(length % 256)];  //calculate int value of low bytes

    [transmitPacket addObject:lengthHighByte];      //add length bytes 1 and 2 to the transmit packet
    [transmitPacket addObject:lengthLowByte]; 

    
    for (int i = 3; i < ([hexString length]/2); i++) {
        byteString = [NSString stringWithFormat:@"%c%c", [hexString characterAtIndex:(2*i)], [hexString characterAtIndex:((2*i)+1)]];
        scan = [NSScanner scannerWithString:byteString];
        [scan scanHexInt:&dec];
        [transmitPacket addObject:[NSNumber numberWithUnsignedInt:dec]];
    }
    
    
    int sum = 0;    
     for (int i = 3; i<(int)([transmitPacket count]);i++){
         sum = sum + [[transmitPacket objectAtIndex:i] unsignedIntValue];   //sum up all bytes involved in checksum
     }
     int chksum = 255-(sum%256);         //0xFF - last 8 bytes of sum
     [transmitPacket addObject:[NSNumber numberWithUnsignedInt:(chksum)]];   //attach checksum to end of message
     
     txPacket =transmitPacket;  //output to instance variable txPacket
}






-(void) ATCommandTest{
    NSMutableArray* transmitPacket = [[NSMutableArray alloc] initWithCapacity:8];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:126]];  //add start byte to start of packet array
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:0]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:30]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:136]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:21]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:78]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:68]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:0]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:131]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:240]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:0]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:19]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:162]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:0]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:64]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:124]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:110]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:205]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:82]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:79]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:85]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:84]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:69]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:82]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:00]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:255]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:254]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:1]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:00]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:193]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:5]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:16]];
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:30]];
    int sum = 0;    
    for (int i = 3; i<(int)([transmitPacket count]);i++){
        sum = sum + [[transmitPacket objectAtIndex:i] unsignedIntValue];   //sum up all bytes involved in checksum
    }
    int chksum = 255-(sum%256);         //0xFF - last 8 bytes of sum
    [transmitPacket addObject:[NSNumber numberWithUnsignedInt:(chksum)]];   //attach checksum to end of message
    txPacket = transmitPacket;  //output to instance variable txPacket
}




@end
