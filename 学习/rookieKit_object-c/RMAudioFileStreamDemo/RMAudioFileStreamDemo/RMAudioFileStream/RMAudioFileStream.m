//
//  RMAudioFileStream.m
//  RMAudioFileStreamDemo
//
//  Created by Rookieme on 2019/3/13.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "RMAudioFileStream.h"

#define BitRateEstimationMaxPackets 5000
#define BitRateEstimationMinPackets 10

@interface RMAudioFileStream ()
{
@private
    BOOL _discontinuous;
    // AudioFileStream实例对应的AudioFileStreamID，这个ID需要保存起来作为后续一些方法的参数使用
    AudioFileStreamID _audioFileStreamID;
    // 通过kAudioFileStreamProperty_DataOffset获取的值
    SInt64 _dataOffset;
    NSTimeInterval _packetDuration;
    
    UInt64 _processedPacketsCount;
    UInt64 _processedPacketsSizeTotal;
}
- (void)handleAudioFileStreamProperty:(AudioFileStreamPropertyID)propertyID;
- (void)handleAudioFileStreamPackets:(const void *)packets
                       numberOfBytes:(UInt32)numberOfBytes
                     numberOfPackets:(UInt32)numberOfPackets
                  packetDescriptions:(AudioStreamPacketDescription *)packetDescriptioins;
@end

#pragma mark - static callbacks

/**
 歌曲信息解析的回调，每解析出一个歌曲信息都会进行一次回调 的回调静态函数

 @param inClientData      open的上下文对象
 @param inAudioFileStream 和Open方法中第四个返回参数AudioFileStreamID一样，表示当前FileStream的ID
 @param inPropertyID      此次回调解析的信息ID。表示当前PropertyID对应的信息已经解析完成信息（例如数据格式、音频数据的偏移量等等），使用者可以通过AudioFileStreamGetProperty接口获取PropertyID对应的值或者数据结构
 @param ioFlags           是一个返回参数，表示这个property是否需要被缓存，如果需要赋值kAudioFileStreamPropertyFlag_PropertyIsCached否则不赋值（这个参数我也不知道应该在啥场景下使用。。一直都没去理他）
 */
static void MCSAudioFileStreamPropertyListener(void *inClientData,
                                               AudioFileStreamID inAudioFileStream,
                                               AudioFileStreamPropertyID inPropertyID,
                                               UInt32 *ioFlags)
{
    RMAudioFileStream *audioFileStream = (__bridge RMAudioFileStream *)inClientData;
    // 对歌曲信息结构进行解析
    [audioFileStream handleAudioFileStreamProperty:inPropertyID];
}

/**
 分离帧的回调，每解析出一部分帧就会进行一次回调 的回调静态函数

 @param inClientData         open的上下文对象
 @param inNumberBytes        本次处理的数据大小
 @param inNumberPackets      本次总共处理了多少帧（即代码里的Packet）
 @param inInputData          本次处理的所有数据
 @param inPacketDescriptions AudioStreamPacketDescription数组，存储了每一帧数据是从第几个字节开始的，这一帧总共多少字节
 */
static void MCAudioFileStreamPacketsCallBack(void *inClientData,
                                             UInt32 inNumberBytes,
                                             UInt32 inNumberPackets,
                                             const void *inInputData,
                                             AudioStreamPacketDescription *inPacketDescriptions)
{
    RMAudioFileStream *audioFileStream = (__bridge RMAudioFileStream *)inClientData;
    [audioFileStream handleAudioFileStreamPackets:inInputData
                                    numberOfBytes:inNumberBytes
                                  numberOfPackets:inNumberPackets
                               packetDescriptions:inPacketDescriptions];
}
@implementation RMAudioFileStream

/**
 初始化音频文件流

 @param fileType 文件类型的提示，这个参数来帮助AudioFileStream对文件格式进行解析
 @param fileSize 文件大小
 @param error    error对象地址，赋值操作（根据其值判断初始化是否成功）
 @return         音频文件流实例对象
 */
- (instancetype)initWithFileType:(AudioFileTypeID)fileType fileSize:(unsigned long long)fileSize error:(NSError **)error
{
    self  = [super init];
    if (self)
    {
        _discontinuous = NO;
        _fileType = fileType;
        _fileSize = fileSize;
        // 开启音频文件流
        [self openAudioFileStreamWithFileTypeHint:_fileType error:error];
    }
    return self;
}

- (void)errorForOSStatus:(OSStatus)status error:(NSError *__autoreleasing *)outError
{
    if (status != noErr && outError != NULL)
    {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
}

#pragma mark - open & close
/**
 启动音频文件流解析

 @param fileTypeHint 文件类型的提示，这个参数来帮助AudioFileStream对文件格式进行解析
 @param error        error对象地址，赋值操作（根据其值判断初始化是否成功）
 @return             是否启动成功
 */
- (BOOL)openAudioFileStreamWithFileTypeHint:(AudioFileTypeID)fileTypeHint error:(NSError *__autoreleasing *)error
{
    // 生产音频文件流实例，并返回状态码
    OSStatus status = AudioFileStreamOpen((__bridge void *)self, // 上下文对象(自身)
                                          MCSAudioFileStreamPropertyListener,
                                          MCAudioFileStreamPacketsCallBack,
                                          fileTypeHint,
                                          &_audioFileStreamID);
    
    if (status != noErr)
    {
        _audioFileStreamID = NULL;
    }
    // 对是否错误进行封装解析
    [self errorForOSStatus:status error:error];
    return status == noErr;
}


/**
 根据解析的信息ID，对数据结构进行解析（表示当前PropertyID对应的信息已经解析完成信息（例如数据格式、音频数据的偏移量等等）)

 @param propertyID 解析的信息ID
 */
- (void)handleAudioFileStreamProperty:(AudioFileStreamPropertyID)propertyID
{
    // 代表解析完成，接下来可以对音频数据进行帧分离了
    if (propertyID == kAudioFileStreamProperty_ReadyToProducePackets)
    {
        _readyToProducePackets = YES;
        _discontinuous = YES;
        
        UInt32 sizeOfUInt32 = sizeof(_maxPacketSize);
        OSStatus status = AudioFileStreamGetProperty(_audioFileStreamID, kAudioFileStreamProperty_PacketSizeUpperBound, &sizeOfUInt32, &_maxPacketSize);
        if (status != noErr || _maxPacketSize == 0)
        {
            status = AudioFileStreamGetProperty(_audioFileStreamID, kAudioFileStreamProperty_MaximumPacketSize, &sizeOfUInt32, &_maxPacketSize);
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(audioFileStreamReadyToProducePackets:)])
        {
            [_delegate audioFileStreamReadyToProducePackets:self];
        }
    }
    // 表示音频数据在整个音频文件中的offset（因为大多数音频文件都会有一个文件头之后才使真正的音频数据），这个值在seek时会发挥比较大的作用，音频的seek并不是直接seek文件位置而seek时间（比如seek到2分10秒的位置），seek时会根据时间计算出音频数据的字节offset然后需要再加上音频数据的offset才能得到在文件中的真正offset。
    else if (propertyID == kAudioFileStreamProperty_DataOffset)
    {
        // 计算数据空间的字节数
        UInt32 offsetSize = sizeof(_dataOffset);
        // 通过AudioFileStreamGetProperty接口获取PropertyID对应的值或者数据结构
        AudioFileStreamGetProperty(_audioFileStreamID, kAudioFileStreamProperty_DataOffset, &offsetSize, &_dataOffset);
        // 获取剩余比特位
        _audioDataByteCount = _fileSize - _dataOffset;
        // 计算时长
        [self calculateDuration];
    }
    // 表示音频文件结构信息，是一个AudioStreamBasicDescription的结构
    else if (propertyID == kAudioFileStreamProperty_DataFormat)
    {
        UInt32 asbdSize = sizeof(_format);
        AudioFileStreamGetProperty(_audioFileStreamID, kAudioFileStreamProperty_DataFormat, &asbdSize, &_format);
        [self calculatepPacketDuration];
    }
    // 作用和kAudioFileStreamProperty_DataFormat是一样的，区别在于用这个PropertyID获取到是一个AudioStreamBasicDescription的数组，这个参数是用来支持AAC SBR这样的包含多个文件类型的音频格式。由于到底有多少个format我们并不知晓，所以需要先获取一下总数据大小
    else if (propertyID == kAudioFileStreamProperty_FormatList)
    {
        Boolean outWriteable;
        UInt32 formatListSize;
        OSStatus status = AudioFileStreamGetPropertyInfo(_audioFileStreamID, kAudioFileStreamProperty_FormatList, &formatListSize, &outWriteable);
        if (status == noErr)
        {
            AudioFormatListItem *formatList = malloc(formatListSize);
            OSStatus status = AudioFileStreamGetProperty(_audioFileStreamID, kAudioFileStreamProperty_FormatList, &formatListSize, formatList);
            if (status == noErr)
            {
                UInt32 supportedFormatsSize;
                status = AudioFormatGetPropertyInfo(kAudioFormatProperty_DecodeFormatIDs, 0, NULL, &supportedFormatsSize);
                if (status != noErr)
                {
                    free(formatList);
                    return;
                }
                
                UInt32 supportedFormatCount = supportedFormatsSize / sizeof(OSType);
                OSType *supportedFormats = (OSType *)malloc(supportedFormatsSize);
                status = AudioFormatGetProperty(kAudioFormatProperty_DecodeFormatIDs, 0, NULL, &supportedFormatsSize, supportedFormats);
                if (status != noErr)
                {
                    free(formatList);
                    free(supportedFormats);
                    return;
                }
                
                for (int i = 0; i * sizeof(AudioFormatListItem) < formatListSize; i ++)
                {
                    AudioStreamBasicDescription format = formatList[i].mASBD;
                    for (UInt32 j = 0; j < supportedFormatCount; ++j)
                    {
                        if (format.mFormatID == supportedFormats[j])
                        {
                            _format = format;
                            [self calculatepPacketDuration];
                            break;
                        }
                    }
                }
                free(supportedFormats);
            }
            free(formatList);
        }
    }
}

/**
 分离帧的数据解析

 @param packets 本次处理的数据大小
 @param numberOfBytes 本次总共处理了多少帧（即代码里的Packet）
 @param numberOfPackets 本次处理的所有数据
 @param packetDescriptioins AudioStreamPacketDescription数组，存储了每一帧数据是从第几个字节开始的，这一帧总共多少字节
 */
- (void)handleAudioFileStreamPackets:(const void *)packets
                       numberOfBytes:(UInt32)numberOfBytes
                     numberOfPackets:(UInt32)numberOfPackets
                  packetDescriptions:(AudioStreamPacketDescription *)packetDescriptioins
{
    // 处理间断
    if (_discontinuous)
    {
        _discontinuous = NO;
    }
    
    if (numberOfBytes == 0 || numberOfPackets == 0)
    {
        return;
    }
    
    BOOL deletePackDesc = NO;
    if (packetDescriptioins == NULL)
    {
        // 如果packetDescriptioins不存在，就按照CBR处理，平均每一帧的数据后生成packetDescriptioins
        deletePackDesc = YES;
        UInt32 packetSize = numberOfBytes / numberOfPackets;
        AudioStreamPacketDescription *descriptions = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) * numberOfPackets);
        
        for (int i = 0; i < numberOfPackets; i++)
        {
            UInt32 packetOffset = packetSize * i;
            descriptions[i].mStartOffset = packetOffset;
            descriptions[i].mVariableFramesInPacket = 0;
            // 把解析出来的帧数据放进自己的buffer中
            if (i == numberOfPackets - 1)
            {
                descriptions[i].mDataByteSize = numberOfBytes - packetOffset;
            }
            else
            {
                descriptions[i].mDataByteSize = packetSize;
            }
        }
        packetDescriptioins = descriptions;
    }
    
    NSMutableArray *parsedDataArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < numberOfPackets; ++i)
    {
        SInt64 packetOffset = packetDescriptioins[i].mStartOffset;
        RMParsedAudioData *parsedData = [RMParsedAudioData parsedAudioDataWithBytes:packets + packetOffset
                                                                  packetDescription:packetDescriptioins[i]];
        
        [parsedDataArray addObject:parsedData];
        
        if (_processedPacketsCount < BitRateEstimationMaxPackets)
        {
            _processedPacketsSizeTotal += parsedData.packetDescription.mDataByteSize;
            _processedPacketsCount += 1;
            [self calculateBitRate];
            [self calculateDuration];
        }
    }
    
    [_delegate audioFileStream:self audioDataParsed:parsedDataArray];
    
    if (deletePackDesc)
    {
        free(packetDescriptioins);
    }
}


/**
 获取时长的最佳方法是从ID3信息中去读取，那样是最准确的。如果ID3信息中没有存，那就依赖于文件头中的信息去计算了。
 计算duration的公式如下：
 */
- (void)calculateDuration
{
    if (_fileSize > 0 && _bitRate > 0)
    {
        _duration = ((_fileSize - _dataOffset) * 8.0) / _bitRate;
    }
}


/**
 计算seekToTime对应的是第几个帧（Packet）
 我们可以利用之前Parse得到的音频格式信息来计算PacketDuration。audioItem.fileFormat.mFramesPerPacket / audioItem.fileFormat.mSampleRate;
 */
- (void)calculatepPacketDuration
{
    if (_format.mSampleRate > 0)
    {
        _packetDuration = _format.mFramesPerPacket / _format.mSampleRate;
    }
}

- (void)calculateBitRate
{
    if (_packetDuration && _processedPacketsCount > BitRateEstimationMinPackets && _processedPacketsCount <= BitRateEstimationMaxPackets)
    {
        double averagePacketByteSize = _processedPacketsSizeTotal / _processedPacketsCount;
        _bitRate = 8.0 * averagePacketByteSize / _packetDuration;
    }
}

- (BOOL)parseData:(NSData *)data error:(NSError **)error
{
    if (self.readyToProducePackets && _packetDuration == 0)
    {
        [self errorForOSStatus:-1 error:error];
        return NO;
    }
    /**
     在初始化完成之后，只要拿到文件数据就可以进行解析了。解析时调用方法

     inAudioFileStream AudioFileStreamID,即初始化时返回的ID
     inDataByteSize    本次解析的数据长度
     inData            本次解析的数据
     inFlags           本次的解析和上一次解析是否是连续的关系，如果是连续的传入0，否则传入kAudioFileStreamParseFlag_Discontinuity
     返回值(OSStatus)   返回值表示当前的数据是否被正常解析，如果OSStatus的值不是noErr则表示解析不成功
     */
    OSStatus status = AudioFileStreamParseBytes(_audioFileStreamID,(UInt32)[data length],[data bytes],_discontinuous ? kAudioFileStreamParseFlag_Discontinuity : 0);
    [self errorForOSStatus:status error:error];
    return status == noErr;
}

- (SInt64)seekToTime:(NSTimeInterval *)time
{
    SInt64 approximateSeekOffset = _dataOffset + (*time / _duration) * _audioDataByteCount;
    SInt64 seekToPacket = floor(*time / _packetDuration);
    SInt64 seekByteOffset;
    UInt32 ioFlags = 0;
    SInt64 outDataByteOffset;
    OSStatus status = AudioFileStreamSeek(_audioFileStreamID, seekToPacket, &outDataByteOffset, &ioFlags);
    if (status == noErr && !(ioFlags & kAudioFileStreamSeekFlag_OffsetIsEstimated))
    {
        *time -= ((approximateSeekOffset - _dataOffset) - outDataByteOffset) * 8.0 / _bitRate;
        seekByteOffset = outDataByteOffset + _dataOffset;
    }
    else
    {
        _discontinuous = YES;
        seekByteOffset = approximateSeekOffset;
    }
    return seekByteOffset;
}

- (NSData *)fetchMagicCookie
{
    UInt32 cookieSize;
    Boolean writable;
    OSStatus status = AudioFileStreamGetPropertyInfo(_audioFileStreamID, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
    if (status != noErr)
    {
        return nil;
    }
    
    void *cookieData = malloc(cookieSize);
    status = AudioFileStreamGetProperty(_audioFileStreamID, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
    if (status != noErr)
    {
        return nil;
    }
    
    NSData *cookie = [NSData dataWithBytes:cookieData length:cookieSize];
    free(cookieData);
    
    return cookie;
}

- (void)close
{
    [self closeAudioFileStream];
}

- (void)closeAudioFileStream
{
    if (self.available)
    {
        AudioFileStreamClose(_audioFileStreamID);
        _audioFileStreamID = NULL;
    }
}

- (BOOL)available
{
    return _audioFileStreamID != NULL;
}

- (void)dealloc
{
    [self closeAudioFileStream];
}



@end
