//
//  CBRecordTranscriptViewController.m
//  CambridgeTranscribe
//
//  Created by Viet Duc Nguyen on 20.01.19.
//  Copyright © 2019 Viet Duc Nguyen. All rights reserved.
//

#import "CBRecordTranscriptViewController.h"

@interface CBRecordTranscriptViewController ()
@property (weak, nonatomic) IBOutlet UITextView *transcriptTextview;
@end

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation CBRecordTranscriptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.transcriptTextview.text = self.transcript;
    
    // Gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)UIColorFromRGB(0x667EEA).CGColor, (id)UIColorFromRGB(0x764BA2).CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)setTranscript:(NSString *)transcript
{
    _transcript = [transcript copy];
    self.transcriptTextview.text = _transcript;
}

@end
