//
//  CBRecordViewController.m
//  CambridgeTranscribe
//
//  Created by Viet Duc Nguyen on 19.01.19.
//  Copyright © 2019 Viet Duc Nguyen. All rights reserved.
//

#import "FFPopup.h"
#import "CBRecordViewController.h"
#import "CBRecordDetailViewController.h"
#import "CBRecordTranscriptViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface CBRecordViewController () <UIPageViewControllerDataSource, CBRecordDelegate>
@property (nonatomic, strong) NSArray *pages;
@property (nonatomic, strong) UITextField *classTextfield;
@property (nonatomic, strong) NSString *currentTranscript;
@property (nonatomic, strong) FFPopup *popup;
@end

@implementation CBRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@" %@", [NSUserDefaults standardUserDefaults]);
    
    CBRecordTranscriptViewController *detailVC2 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"recordTranscript"];
    CBRecordDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"detailrecord"];
    detailVC.delegate = self;
    
    self.pages = @[detailVC, detailVC2];

    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    pageViewController.dataSource = self;
    
    [pageViewController setViewControllers:@[detailVC]
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:true
                                completion:^(BOOL finished) {
    }];
    
    [self addChildViewController:pageViewController];
    pageViewController.view.frame = self.view.frame;
    [self.view addSubview:pageViewController.view];
    [pageViewController didMoveToParentViewController:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark - Action

- (void)tap {
    [self.classTextfield resignFirstResponder];
}

- (void)save {
    NSString *class = self.classTextfield.text;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *classes = [[userDefaults objectForKey:@"classes"] mutableCopy];
    if ([classes objectForKey:class] && self.currentTranscript) {
        NSLog(@"%@", self.currentTranscript);
        NSMutableArray *lectures = [classes[class] mutableCopy];
        [lectures addObject:@{@"content": self.currentTranscript, @"date": [NSDate date]}];
        self.currentTranscript = nil;
        classes[class] = lectures;
    } else {
        NSLog(@"First time");
        NSArray *lectures = @[@{@"content": self.currentTranscript, @"date": [NSDate date]}];
        classes[class] = lectures;
    }
    
    classes[@"Chemistry"] = @[@{
                              @"date": [NSDate date],
                              @"content": @"But electronegativity in the sense of organic chemistry, or inorganic chemistry for that matter, was popularized by Linus Pauling, beginning with this paper in 1933--or 1932 it was published. So this is a key passage in that paper. And remember that Pauling was pushing this idea of resonance--that you get stabilization when you can draw different resonance structures. So he's talking about the additivity of the energies of normal covalent bonds. He says, There's empirical evidence in support of the postulate that the energies of normal covalent bonds are additive. Now what does he mean by additive? That is, that if you have atoms A and B, you could have AA, you could have AB, BB, and you could have AB. And his idea is that the bond strength in AB should be the average of what you have in AA and what you have in BB. So he was a little confusing about that, because in some papers he used this concept using the arithmetic mean, but in others he talked about the geometric mean where it was the square root of the product instead of half the sum. But at any rate, the idea was that normal covalent bonds should be the average of the homonuclear bonds. So he uses, then, this plot where he's measuring the energies of the bonds, bond disassociation energies, in unusual units for us, electron volts. You multiply by 23 to get kilocalories per mole. So here are H-X bonds that are normal, that is, calculated if they were normal. They're the average of the H-H and the X-X for the different halogens, as you see, fluorine, chlorine, bromine and iodine. Now incidentally, there's a little problem here because he was using the wrong value for the fluorine-fluorine bond energy in all of this work. He thought it was 65 kilocalories per mole; actually it's 38. It's a rather weak bond because of all these electron-pair repulsions that we talked about. So his numbers are a little bit skewed, but at any rate, that was what he was doing. So this is theoretical. To get these red numbers he used H-H and X-X and just took their average. Now observed values are this; the bonds are actually stronger than you expect. But they're not all stronger by the same amount. And the reason is in Pauling's theory, this resonance theory, that you could have the polar resonance structure, which makes it more stable. What this suggests is that there's this difference, ∆, between what you would expect if it were normal, the average, and what you observe, which is what you have when you have this polar resonance structure. And what he says here, the greater the ionic character of the bond the greater will be the value of ∆. So the neat idea now is we could use ∆, which is based on experimental numbers, as a way to measure how important resonance is. So you could measure resonance stabilization by ∆, if you adopt his assumptions that normal bonds are the average, and now you measure these and the difference tells you how important resonance stabilization is. And then you try to see if there's something you can correlate to predict how important resonance stabilization should be."
    }];
    [userDefaults setObject:classes forKey:@"classes"];

    [self.popup dismissAnimated:true];
}

- (void)discard {
    [self.popup dismissAnimated:true];
}

#pragma mark - Record

- (void)didReceiveTranscriptData:(NSString *)transcript
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentTranscript = transcript;
        [self.pages[1] setTranscript:transcript];
    });
}

- (void)didStopTranscript:(NSString *)transcript
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"END");
        NSLog(@"%@", transcript);
        
        UIView *lol = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 340, 500)];
        lol.backgroundColor = [UIColor whiteColor];
        lol.frame = CGRectOffset(lol.frame, (self.view.bounds.size.width  - 340) / 2.0, 60);
        lol.layer.cornerRadius = 8;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"h1"]];
        imageView.frame = CGRectMake((lol.bounds.size.width - 200) / 2.0, 30, 200, 200);
        [lol addSubview:imageView];
        
        const CGFloat width = lol.frame.size.width * 0.8;
        self.classTextfield = [[UITextField alloc] initWithFrame:CGRectMake((lol.frame.size.width - width) / 2.0, CGRectGetMaxY(imageView.frame) + 30, width, 40)];
        self.classTextfield.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:34];
        self.classTextfield.textColor = UIColorFromRGB(0x6640FF);
        self.classTextfield.textAlignment = NSTextAlignmentCenter;
        self.classTextfield.text = @"Class";
        [lol addSubview:self.classTextfield];
        
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(self.classTextfield.frame.origin.x, CGRectGetMaxY(self.classTextfield.frame)+10, width, 2)];
        border.backgroundColor = UIColorFromRGB(0x6640FF);
        [lol addSubview:border];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [lol addGestureRecognizer:tap];
        
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(self.classTextfield.frame.origin.x, CGRectGetMaxY(border.frame) + 30, width, 56)];
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        saveButton.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:24];
        saveButton.backgroundColor = UIColorFromRGB(0x6640FF);
        saveButton.layer.cornerRadius = 8;
        [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        [lol addSubview:saveButton];
        
        UIButton *discardButton = [[UIButton alloc] initWithFrame:CGRectMake(self.classTextfield.frame.origin.x, CGRectGetMaxY(saveButton.frame) + 14, width, 56)];
        [discardButton setTitle:@"Discard" forState:UIControlStateNormal];
        [discardButton setTitleColor:UIColorFromRGB(0x6640FF) forState:UIControlStateNormal];
        discardButton.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:24];
        discardButton.backgroundColor = [UIColor clearColor];
        discardButton.layer.cornerRadius = 8;
        discardButton.layer.borderColor = UIColorFromRGB(0x6640FF).CGColor;
        discardButton.layer.borderWidth = 2;
        [discardButton addTarget:self action:@selector(discard) forControlEvents:UIControlEventTouchUpInside];
        [lol addSubview:discardButton];
        
        FFPopup *popUp = [FFPopup popupWithContentView:lol];
        popUp.showType = FFPopupShowType_BounceInFromBottom;
        [popUp show];
        self.popup = popUp;
    });
}

#pragma mark - UIPageViewControllerDataSource

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (viewController == self.pages[0]) {
        return nil;
    }
    
    return self.pages[0];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (viewController == self.pages[1]) {
        return nil;
    }
    
    return self.pages[1];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
