//
//  MSectionViewCell.m
//  MSectionFramework
//
//  Created by Micker on 16/6/12.
//  Copyright © 2016年 Micker. All rights reserved.
//

#import "MSectionViewCell.h"

@implementation MSectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.nameLabel];
    }
    return self;
}


- (UILabel *) nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.numberOfLines = 0;
        _nameLabel.font = [UIFont systemFontOfSize:15.0f];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

#pragma mark protocol

- (void) doSetContentData:(id) content {
    
    self.nameLabel.text = content;
}

#pragma mark --Animtate

- (id) updateTextColor:(UIColor *)textColor {
    _nameLabel.textColor = textColor;
    return self;
}

- (id) updateTransform:(CGAffineTransform ) transform {
    _nameLabel.transform = transform;
    return self;
}
@end
