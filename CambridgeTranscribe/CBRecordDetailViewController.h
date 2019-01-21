//
//  CBRecordDetailViewController.h
//  CambridgeTranscribe
//
//  Created by Viet Duc Nguyen on 20.01.19.
//  Copyright © 2019 Viet Duc Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CBRecordDelegate <NSObject>
- (void)didReceiveTranscriptData:(NSString *)transcript;
- (void)didStopTranscript:(NSString *)transcript;
@end

@interface CBRecordDetailViewController : UIViewController
@property (nonatomic, assign) id <CBRecordDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
