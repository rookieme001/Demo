//
//  RMAudioFileStream.h
//  RMAudioFileStreamDemo
//
//  Created by Rookieme on 2019/3/13.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "RMParsedAudioData.h"
NS_ASSUME_NONNULL_BEGIN

@class RMAudioFileStream;
@protocol RMAudioFileStreamDelegate <NSObject>
@required
- (void)audioFileStream:(RMAudioFileStream *)audioFileStream audioDataParsed:(NSArray *)audioData;
@optional
- (void)audioFileStreamReadyToProducePackets:(RMAudioFileStream *)audioFileStream;
@end

@interface RMAudioFileStream : NSObject
// 音频文件流代理
@property (nonatomic,weak) id<RMAudioFileStreamDelegate> delegate;
// 文件类型
@property (nonatomic,assign,readonly) AudioFileTypeID fileType;
@property (nonatomic,assign,readonly) BOOL available;
// 是否解析完成，进入帧分类
@property (nonatomic,assign,readonly) BOOL readyToProducePackets;
// 音频文件结构信息
@property (nonatomic,assign,readonly) AudioStreamBasicDescription format;
// 文件大小
@property (nonatomic,assign,readonly) unsigned long long fileSize;
// 耗时
@property (nonatomic,assign,readonly) NSTimeInterval duration;
// 音频数据的码率
@property (nonatomic,assign,readonly) UInt32 bitRate;
// 输入时，输出属性数据指向的缓冲区大小。 在输出时，写入的字节数。
@property (nonatomic,assign,readonly) UInt32 maxPacketSize;
// 通过kAudioFileStreamProperty_AudioDataByteCount获取的值
@property (nonatomic,assign,readonly) UInt64 audioDataByteCount;

/**
 初始化音频文件流
 
 @param fileType 文件类型的提示，这个参数来帮助AudioFileStream对文件格式进行解析
 @param fileSize 文件大小
 @param error    error对象地址，赋值操作（根据其值判断初始化是否成功）
 @return         音频文件流实例对象
 */

- (instancetype)initWithFileType:(AudioFileTypeID)fileType fileSize:(unsigned long long)fileSize error:(NSError **)error;

- (BOOL)parseData:(NSData *)data error:(NSError **)error;

/**
 *  seek to timeinterval
 *
 *  @param time On input, timeinterval to seek.
 On output, fixed timeinterval.
 *
 *  @return seek byte offset
 */
- (SInt64)seekToTime:(NSTimeInterval *)time;

- (NSData *)fetchMagicCookie;

- (void)close;
@end

NS_ASSUME_NONNULL_END
