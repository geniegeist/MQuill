//
//  CBLecturesCollectionViewController.h
//  CambridgeTranscribe
//
//  Created by Viet Duc Nguyen on 20.01.19.
//  Copyright © 2019 Viet Duc Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBLecturesCollectionViewController : UICollectionViewController
@property (nonatomic, strong) NSArray *lectures;
@property (nonatomic, strong) NSString *title;
@end

NS_ASSUME_NONNULL_END
