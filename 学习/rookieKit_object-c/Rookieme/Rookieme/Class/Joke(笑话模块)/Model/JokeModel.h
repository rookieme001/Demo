//
//  JokeModel.h
//  Rookieme
//
//  Created by Rookieme on 2019/1/2.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JokeModel : NSObject
//[0]    (null)    @"unixtime" : (long)1418745227
//[1]    (null)    @"updatetime" : @"2014-12-16 23:53:47"
//[2]    (null)    @"content" : @"某先生是地方上的要人。一天，他像往常一样在书房里例览当日报纸，突然对妻子大声喊道：喂，安娜，你看到今天早报上的流言蜚语了吗？真可笑！他们说，你收拾行装出走了。你听见了吗？安娜、你在哪儿？安娜？啊！"
//[3]    (null)    @"hashId" : @"90B182FC7F74865B40B1E5807CFEBF41"

@property (nonatomic, strong) NSString *updatetime;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *hashId;
@property (nonatomic, assign) long unixtime;
@end

NS_ASSUME_NONNULL_END
