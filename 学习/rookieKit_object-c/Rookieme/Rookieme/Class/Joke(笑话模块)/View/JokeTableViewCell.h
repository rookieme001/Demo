//
//  JokeTableViewCell.h
//  Rookieme
//
//  Created by Rookieme on 2019/1/2.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JokeModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface JokeTableViewCell : UITableViewCell
@property (nonatomic, strong) JokeModel *model;
@end

NS_ASSUME_NONNULL_END
