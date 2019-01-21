//
//  CBClassCollectionViewCell.m
//  CambridgeTranscribe
//
//  Created by Viet Duc Nguyen on 20.01.19.
//  Copyright © 2019 Viet Duc Nguyen. All rights reserved.
//

#import "CBClassCollectionViewCell.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation CBClassCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = @[(id)UIColorFromRGB(0xA5C0EE).CGColor, (id)UIColorFromRGB(0xFBC5EC).CGColor];
    [self.layer insertSublayer:gradient atIndex:0];
    
    self.layer.cornerRadius = 12;
}

@end
