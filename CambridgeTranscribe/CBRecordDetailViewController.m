//
//  CBRecordDetailViewController.m
//  CambridgeTranscribe
//
//  Created by Viet Duc Nguyen on 20.01.19.
//  Copyright © 2019 Viet Duc Nguyen. All rights reserved.
//

#import "CBRecordDetailViewController.h"
#import <MicrosoftCognitiveServicesSpeech/SPXSpeechApi.h>
#import <PulsingHalo/PulsingHaloLayer.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface CBRecordDetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) SPXSpeechRecognizer *speechRecognizer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) PulsingHaloLayer *halo;
@property (nonatomic, strong) UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (nonatomic, copy) NSString *transcript;
@property (nonatomic, copy) NSString *sofar;
@end

@implementation CBRecordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // model
    self.isPlaying = false;
    self.transcript = @"";
    self.sofar = @"";
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor purpleColor];
    
    // UI Setup
    self.recordButton.backgroundColor = [UIColor whiteColor];

    // Pulsing
    self.halo = [PulsingHaloLayer layer];
    self.halo.position = self.view.center;
    self.halo.radius = 340;
    [self.halo start];
    self.halo.hidden = true;
    [self.view.layer insertSublayer:self.halo atIndex:1];
    
    // Gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)UIColorFromRGB(0x764BA2).CGColor, (id)UIColorFromRGB(0x667EEA).CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hackcambridge-logo"]];
    logo.frame = CGRectMake(0, 0, 150, 150);
    logo.center = CGPointMake(self.recordButton.bounds.size.width/2.0, self.recordButton.bounds.size.height/2.0);
    logo.contentMode = UIViewContentModeScaleAspectFit;
    logo.alpha = 0.5;
    [self.recordButton addSubview:logo];
    self.recordButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    self.logo = logo;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.recordButton.layer.cornerRadius = self.recordButton.frame.size.width / 2.0;
    self.halo.position = self.view.center;
}

#pragma mark - Getter

- (SPXSpeechRecognizer *)speechRecognizer
{
    if (!_speechRecognizer) {
        SPXSpeechConfiguration *speechConfig = [[SPXSpeechConfiguration alloc] initWithSubscription:@"9ffbf97363c6488a8a3b8db23d9ddf77" region:@"westus"];
        if (!speechConfig) {
            NSLog(@"Could not load speech config");
            [self updateRecognitionErrorText:(@"Speech Config Error")];
            return nil;
        }
        
        _speechRecognizer = [[SPXSpeechRecognizer alloc] init:speechConfig];
    }
    return _speechRecognizer;
}

#pragma mark - Record

- (void)recognizeFromMicrophone {
    if (self.isPlaying) return;
    
    NSLog(@"Click me");
    [self updateRecognitionStatusText:(@"Recognizing...")];
    
    SPXSpeechRecognizer* speechRecognizer = self.speechRecognizer;
    if (!speechRecognizer) {
        NSLog(@"Could not create speech recognizer");
        [self updateRecognitionResultText:(@"Speech Recognition Error")];
        return;
    }
    
    [speechRecognizer addRecognizedEventHandler:^(SPXSpeechRecognizer * _Nonnull recognizer, SPXSpeechRecognitionEventArgs * _Nonnull args) {
        SPXRecognitionResult *result = args.result;
        NSLog(@"Recognized");
        NSLog(@"%@", result.text);
        self.sofar = [NSString stringWithFormat:@"%@ %@", self.sofar, result.text];
    }];
    [speechRecognizer addRecognizingEventHandler:^(SPXSpeechRecognizer * _Nonnull recognizer, SPXSpeechRecognitionEventArgs * _Nonnull args) {
        SPXRecognitionResult *result = args.result;
        NSLog(@"%@", result.text);
        
        if (result.text) {
            self.transcript = [NSString stringWithFormat:@"%@ %@", self.sofar, result.text];
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveTranscriptData:)]) {
                [self.delegate didReceiveTranscriptData:self.transcript];
            }
        }
    }];
    [speechRecognizer addCanceledEventHandler:^(SPXSpeechRecognizer * _Nonnull recognizer, SPXSpeechRecognitionCanceledEventArgs * _Nonnull args) {
        NSLog(@"Error");
    }];
    [speechRecognizer startContinuousRecognition];
    self.isPlaying = true;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logo.alpha = 1;
        self.halo.hidden = false;
        self.headerLabel.text = @"Transcribing...";
    });
}

- (void)stopRecording {
    if (!self.isPlaying) return;
    
    NSLog(@"Stop recording");
    
    [self.speechRecognizer stopContinuousRecognition];
    self.isPlaying = false;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logo.alpha = 0.5;
        self.halo.hidden = true;
        self.headerLabel.text = @"Tap to transcribe";
    });
}

- (IBAction)click:(id)sender {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        if (!self.isPlaying) {
            [self recognizeFromMicrophone];
        } else {
            [self stopRecording];
            [self.delegate didStopTranscript:self.transcript];
        }
    });
}

- (void)updateRecognitionResultText:(NSString *) resultText {
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

- (void)updateRecognitionErrorText:(NSString *) errorText {
    dispatch_async(dispatch_get_main_queue(), ^{


    });
}

- (void)updateRecognitionStatusText:(NSString *) statusText {
    dispatch_async(dispatch_get_main_queue(), ^{


    });
}


@end
