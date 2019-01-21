//
//  CBChatbotViewController.m
//  CambridgeTranscribe
//
//  Created by Viet Duc Nguyen on 20.01.19.
//  Copyright © 2019 Viet Duc Nguyen. All rights reserved.
//

#import "CBChatbotViewController.h"
#import <Shift/Shift-umbrella.h>
#import <Speech/Speech.h>
#import <ApiAI/ApiAI.h>

@interface CBChatbotViewController ()
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *request;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) NSTimer *detectionTimer;

@property (nonatomic, strong) ShiftView_Objc *shiftView;

@property (nonatomic, strong) UILabel *welcome;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, assign) BOOL isRecording;

@property(nonatomic, strong) ApiAI *apiAI;

@property (nonatomic, strong) NSString *currentClass;

@end

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation CBChatbotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.speechRecognizer= [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-UK"]];
    self.request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    ShiftView_Objc *shiftView = [[ShiftView_Objc alloc] initWithFrame:self.view.bounds];
    [shiftView setColors:@[
                           [UIColor colorWithRed:156/255.0 green:39.0/255.0 blue:176.0/255.0 alpha:1],
                           [UIColor colorWithRed:255/255.0 green:64/255.0 blue:129.0/255.0 alpha:1],
                           [UIColor colorWithRed:123/255.0 green:31.0/255.0 blue:162.0/255.0 alpha:1],
                           [UIColor colorWithRed:32/255.0 green:76.0/255.0 blue:255.0/255.0 alpha:1],
                           [UIColor colorWithRed:32/255.0 green:158.0/255.0 blue:255.0/255.0 alpha:1],
                           [UIColor colorWithRed:90/255.0 green:120.0/255.0 blue:127.0/255.0 alpha:1],
                           [UIColor colorWithRed:58/255.0 green:255.0/255.0 blue:217.0/255.0 alpha:1],
    ]];
    shiftView.backgroundColor = [UIColor redColor];
    [shiftView startTimedAnimation];
    [self.view addSubview:shiftView];
    self.shiftView = shiftView;
    
    UIButton *record = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
    [record setTitle:@"Record" forState:UIControlStateNormal];
    record.center = self.view.center;
    record.frame = CGRectOffset(record.frame, 0, 200);
    record.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    [record addTarget:self action:@selector(record) forControlEvents:UIControlEventTouchUpInside];
    record.layer.cornerRadius = 20;
    record.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:20];
    self.recordButton = record;
    [self.view addSubview:record];
    
    UILabel *welcome = [[UILabel alloc] initWithFrame:CGRectMake(32, 50, 300, 200)];
    welcome.text = @"Hey there! What class do you want to polish up on?";
    welcome.numberOfLines = 9;
    welcome.textColor = [UIColor whiteColor];
    welcome.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:24];
    self.welcome = welcome;
    [self.view addSubview:welcome];
    self.isRecording = false;
    
    
    // API
    self.apiAI = [[ApiAI alloc] init];
    
    // Define API.AI configuration here.
    id <AIConfiguration> configuration = [[AIDefaultConfiguration alloc] init];
    configuration.clientAccessToken = @"52de39d3cd5748ae8d72a11dbfba5f6a";
    
    self.apiAI.configuration = configuration;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.shiftView startTimedAnimation];
    
    

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.welcome.frame = CGRectMake(32, 50, 300, 200);
}

-  (void)record {
    if (!self.isRecording) {
        self.isRecording = true;
        [self recordAndRecognizeSpeech];
    } else {
        self.isRecording = false;
        [self handleSend];
    }
}

- (void)recordAndRecognizeSpeech {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isRecording = true;
        [self.recordButton setTitle:@"Stop recording" forState:UIControlStateNormal];
        self.recordButton.backgroundColor = [UIColor redColor];
    });

    AVAudioInputNode *node = self.audioEngine.inputNode;
    AVAudioFormat *recordingFormat = [node outputFormatForBus:0];
    [node installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.request appendAudioPCMBuffer:buffer];
    }];
    [self.audioEngine prepare];
    NSError *error;
    [self.audioEngine startAndReturnError:&error];
    
    
    if (error) {
        NSLog(@"%@", error);
    }

    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (result) {
            NSString *bestString = [result.bestTranscription formattedString];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.welcome.text = bestString;
            });
            __block BOOL isFinal =false;
            
            if (!result) {
                isFinal = [result isFinal];
            }

            if (self.detectionTimer.isValid) {
                [NSTimer scheduledTimerWithTimeInterval:1 repeats:false block:^(NSTimer * _Nonnull timer) {
                    [self.detectionTimer invalidate];
                }];
            } else {
                self.detectionTimer = [NSTimer scheduledTimerWithTimeInterval:4 repeats:false block:^(NSTimer * _Nonnull timer) {
                    [self handleSend];
                    isFinal = true;
                    [self.detectionTimer invalidate];
                }];
            }
            NSLog(@"%@", bestString);
        } else {
            NSLog(@"%@", error);
        }
    }];
}
        
- (void)handleSend {
    NSLog(@"Handle send");
    [self stop];
    
    AITextRequest *request = [self.apiAI textRequest];
    request.query = @[self.welcome.text];
    //self.currentClass = @"Chemistry";
#warning delete current class
    [request setCompletionBlockSuccess:^(AIRequest *request, id response) {
        // Handle success ...
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", request);
            NSLog(@"%@", response);
            NSString *speech = response[@"result"][@"fulfillment"][@"speech"];
            NSString *intent = response[@"result"][@"metadata"][@"intentName"];
            NSDictionary *parameters = response[@"result"][@"parameters"];
            self.welcome.text = speech;
            
            if ([intent isEqualToString:@"Key Words"]) {
                NSDictionary *allClasses = [[NSUserDefaults standardUserDefaults] objectForKey:@"classes"];
                for (NSString *key in [allClasses allKeys]) {
                    if ([key.lowercaseString isEqualToString:self.currentClass.lowercaseString]) {
                        // is equal key
                        NSArray *lectures = allClasses[key];
                        NSDictionary *lecture = [lectures lastObject];
                        NSString *content = lecture[@"content"];
                        NSDate *date = lecture[@"date"];
                        NSDictionary *dict = [self keywordSearch:content];
                        NSUInteger i = 0;
                        NSString *output = @"";
                        NSArray *documents = dict[@"documents"];
                        if (![documents firstObject]) {
                            self.welcome.text = @"I am sorry no keywords could be found :(";
                            return;
                        }
                        for (NSString *keyword in documents[0][@"keyPhrases"]) {
                            i++;
                            if (i > 6) {
                                break;
                            }
                            NSLog(@"%@", keyword);
                            if (i==1) {
                                output = [NSString stringWithFormat:@"%@", keyword];
                            } else {
                                output = [NSString stringWithFormat:@"%@, %@", output, keyword];
                            }
                        }
                        NSLog(@"%@", output);
                        self.welcome.text = [NSString stringWithFormat:@"I have found the following key words: %@", output];
                        
                        break;
                    }
                }
            } else if ([intent isEqualToString:@"Find Class"]) {
                NSLog(@"%@", parameters[@"classes"][0]);
                NSString *myClass;
                if (![parameters[@"classes"] isKindOfClass:[NSString class]]) {
                    myClass = parameters[@"classes"][0];
                    NSLog(@"adneafnejk");
                } else {
                    myClass = parameters[@"classes"];
                }
                self.currentClass = myClass;
                self.welcome.text = [NSString stringWithFormat:@"What are you looking for in your %@ class?", myClass];
            } else if ([intent.lowercaseString isEqualToString:[NSString stringWithFormat: @"Further questions"].lowercaseString]) {
                NSString *objectToSearch = [[parameters allValues] firstObject];
                NSLog(@"%@", objectToSearch);
                NSDictionary *result = [self bingSearch: objectToSearch];
                NSLog(@"%@", result[@"entities"][@"value"][0][@"description"]);
                self.welcome.text = result[@"entities"][@"value"][0][@"description"];
                if (!self.welcome.text) {
                    self.welcome.text = @"Unfortunately, I have found nothing";
                }
            } else if ([intent.lowercaseString isEqualToString:@"switch class"]) {
                
            }
        });
    } failure:^(AIRequest *request, NSError *error) {
        // Handle error ...
    }];
    
    [self.apiAI enqueue:request];
}

- (void)stop {
    self.isRecording = false;
    [self.audioEngine.inputNode removeTapOnBus:0];
    [self.audioEngine stop];
    [self.recognitionTask cancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recordButton setTitle:@"Start recording" forState:UIControlStateNormal];
        self.recordButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    });
}

- (NSDictionary *)keywordSearch:(NSString *)text
{
        NSString* path = @"https://uksouth.api.cognitive.microsoft.com/text/analytics/v2.0/keyPhrases";
        
        NSMutableURLRequest* _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
        [_request setHTTPMethod:@"POST"];
        // Request headers
        [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [_request setValue:@"e76d6d65d71c43bfa5e8d21be0d3dd30" forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
        // Request body
        [_request setHTTPBody:[[NSString stringWithFormat:@"{\"documents\":[{\"language\": \"en\", \"id\": 1,\"text\":\"%@\"}]}", text] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData* _connectionData = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];
        
        if (nil != error)
        {
            NSLog(@"Error: %@", error);
        }
        else
        {
            NSError* error = nil;
            NSMutableDictionary* json = nil;
            NSString* dataString = [[NSString alloc] initWithData:_connectionData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", dataString);
            
            if (nil != _connectionData)
            {
                json = [NSJSONSerialization JSONObjectWithData:_connectionData options:NSJSONReadingMutableContainers error:&error];
            }
            
            if (error || !json)
            {
                NSLog(@"Could not parse loaded json with error:%@", error);
            }
            
            NSLog(@"%@", json);
            _connectionData = nil;
            
            return json;
        }
    return nil;
}

- (BOOL)findSimilarity:(NSString *)s1 and:(NSString *)s2 {
    NSString* path = [NSString stringWithFormat:@"https://westus.api.cognitive.microsoft.com/academic/v1.0/similarity?s1=%@&%@", s1, s2];
    
    NSMutableURLRequest* _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [_request setHTTPMethod:@"POST"];
    // Request headers
    [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_request setValue:@"e76d6d65d71c43bfa5e8d21be0d3dd30" forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData* _connectionData = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];
    
    if (nil != error)
    {
        NSLog(@"Error: %@", error);
    }
    else
    {
        NSError* error = nil;
        NSMutableDictionary* json = nil;
        NSString* dataString = [[NSString alloc] initWithData:_connectionData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", dataString);
        
        if (nil != _connectionData)
        {
            json = [NSJSONSerialization JSONObjectWithData:_connectionData options:NSJSONReadingMutableContainers error:&error];
        }
        
        if (error || !json)
        {
            NSLog(@"Could not parse loaded json with error:%@", error);
        }
        
        NSLog(@"%@", json);
        _connectionData = nil;
        
        return false;
    }
    
    return false;
}



- (NSDictionary *)bingSearch:(NSString *)keyword
{
    NSString* path = [NSString stringWithFormat:@"https://api.cognitive.microsoft.com/bing/v7.0/entities/?q=%@&mkt=en-us&count=5&offset=0&safesearch=Moderate", keyword];
    
    NSMutableURLRequest* _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [_request setHTTPMethod:@"GET"];
    // Request headers
    [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_request setValue:@"7155ef8c9bde4ff4bdaf3f2057cb21b8" forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData* _connectionData = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];
    
    if (nil != error)
    {
        NSLog(@"Error: %@", error);
    }
    else
    {
        NSError* error = nil;
        NSMutableDictionary* json = nil;
        NSString* dataString = [[NSString alloc] initWithData:_connectionData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", dataString);
        
        if (nil != _connectionData)
        {
            json = [NSJSONSerialization JSONObjectWithData:_connectionData options:NSJSONReadingMutableContainers error:&error];
        }
        
        if (error || !json)
        {
            NSLog(@"Could not parse loaded json with error:%@", error);
        }
        
        NSLog(@"%@", json);
        _connectionData = nil;
        
        return json;
    }
    
    return @{};
}

@end
