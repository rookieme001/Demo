//
//  RMParsedAudioData.h
//  RMAudioFileStreamDemo
//
//  Created by Rookieme on 2019/3/13.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
NS_ASSUME_NONNULL_BEGIN

@interface RMParsedAudioData : NSObject
@property (nonatomic,readonly) NSData *data;
@property (nonatomic,readonly) AudioStreamPacketDescription packetDescription;

+ (instancetype)parsedAudioDataWithBytes:(const void *)bytes
                       packetDescription:(AudioStreamPacketDescription)packetDescription;
@end

NS_ASSUME_NONNULL_END
