//
//  RMParsedAudioData.m
//  RMAudioFileStreamDemo
//
//  Created by Rookieme on 2019/3/13.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "RMParsedAudioData.h"

@implementation RMParsedAudioData
@synthesize data = _data;
@synthesize packetDescription = _packetDescription;

+ (instancetype)parsedAudioDataWithBytes:(const void *)bytes
                       packetDescription:(AudioStreamPacketDescription)packetDescription
{
    return [[self alloc] initWithBytes:bytes
                     packetDescription:packetDescription];
}

- (instancetype)initWithBytes:(const void *)bytes packetDescription:(AudioStreamPacketDescription)packetDescription
{
    if (bytes == NULL || packetDescription.mDataByteSize == 0)
    {
        return nil;
    }
    
    self = [super init];
    if (self)
    {
        _data = [NSData dataWithBytes:bytes length:packetDescription.mDataByteSize];
        _packetDescription = packetDescription;
    }
    return self;
}
@end
