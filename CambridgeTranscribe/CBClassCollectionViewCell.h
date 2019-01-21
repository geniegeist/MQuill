//
//  CBClassCollectionViewCell.h
//  CambridgeTranscribe
//
//  Created by Viet Duc Nguyen on 20.01.19.
//  Copyright © 2019 Viet Duc Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBClassCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *classTitle;
@property (weak, nonatomic) IBOutlet UILabel *numberOfLectures;

@end

NS_ASSUME_NONNULL_END
