//
//  JokeTableViewCell.m
//  Rookieme
//
//  Created by Rookieme on 2019/1/2.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "JokeTableViewCell.h"

@interface JokeTableViewCell ()

@property (nonatomic, strong) UILabel      *contentLabel;

@property (nonatomic, strong) UILabel      *updateTimeLabel;

@end

@implementation JokeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self creatSubviews];
    }
    return self;
}

- (void)creatSubviews
{
   
    

    
    _contentLabel = [self quickCreatLabelWithFont:[UIFont systemFontOfSize:14.f]
                                        textColor: [UIColor colorWithRed:155/255.0
                                                                   green:155/255.0
                                                                    blue:155/255.0
                                                                   alpha:1/1.0]];
    _contentLabel.numberOfLines = 0;
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15.f);
        make.top.equalTo(self.contentView.mas_top).offset(15.f);
        make.right.equalTo(self.contentView.mas_right).offset(-15.f);
    }];
    
    
    
   
    _updateTimeLabel = [self quickCreatLabelWithFont:[UIFont systemFontOfSize:12.f]
                                           textColor: [UIColor colorWithRed:202/255.0
                                                                      green:202/255.0
                                                                       blue:202/255.0
                                                                      alpha:1/1.0]];
    [_updateTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15.f);
        make.top.equalTo(self->_contentLabel.mas_bottom).offset(5.f);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-15.f);
    }];
    
    UIView *shadowView = [[UIView alloc] init];
    [self.contentView insertSubview:shadowView atIndex:0];
    shadowView.backgroundColor = [UIColor whiteColor];
    [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(7.5f);
        make.right.equalTo(self.contentView.mas_right).offset(-7.5f);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-7.5f);
        make.top.equalTo(self.contentView.mas_top).offset(7.5f);
    }];
    shadowView.layer.cornerRadius = 5.f;
    shadowView.layer.shadowOpacity = 0.5;
    shadowView.layer.shadowOffset  = CGSizeMake(5.f, 5.f);
    shadowView.layer.shadowRadius  = 2;
    shadowView.layer.shadowColor   = [UIColor colorWithWhite:0.6 alpha:0.6].CGColor;
    
}

- (UILabel *)quickCreatLabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    [self.contentView addSubview:label];
    label.font      = font;
    label.textColor = textColor;
    return label;
}

- (void)setModel:(JokeModel *)model {
    _model = model;
    _contentLabel.text = model.content;
    _updateTimeLabel.text = model.updatetime;
}

@end
