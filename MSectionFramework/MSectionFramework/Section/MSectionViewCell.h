//
//  MSectionViewCell.h
//  MSectionFramework
//
//  Created by Micker on 16/6/12.
//  Copyright © 2016年 Micker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *nameLabel;

- (void) doSetContentData:(id) content;

- (id) updateTextColor:(UIColor *)textColor;

- (id) updateTransform:(CGAffineTransform ) transform;

@end
