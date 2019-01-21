//
//  ViewController.m
//  CambridgeTranscribe
//
//  Created by Viet Duc Nguyen on 19.01.19.
//  Copyright © 2019 Viet Duc Nguyen. All rights reserved.
//

#import "ViewController.h"
#import "CBRecordViewController.h"
#import "CBClassesViewController.h"
#import "CBChatbotViewController.h"

@interface ViewController () <UIPageViewControllerDataSource>
@property (nonatomic, copy) NSString *serviceRegion;
@property (nonatomic, copy) NSString *speechKey;

@property (nonatomic, strong) CBRecordViewController *recordVC;
@property (nonatomic, strong) CBClassesViewController *classesVC;
@property (nonatomic, strong) CBChatbotViewController *chatbotVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceRegion = @"westus";
    self.speechKey = @"e508068e871a45e881a58543354061ff";
    
    self.recordVC = [[CBRecordViewController alloc] init];
    self.classesVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"classesVC"];
    self.chatbotVC = [[CBChatbotViewController alloc] init];
    
    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{}];
    pageViewController.dataSource = self;
    //pageViewController.delegate = self;
    //pageVIewController.dataSource = self;
    [pageViewController setViewControllers:@[self.recordVC]
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:true
                                completion:^(BOOL finished) {
        
    }];
    pageViewController.view.backgroundColor = [UIColor whiteColor];
    
    [self addChildViewController:pageViewController];
    pageViewController.view.frame = self.view.frame;
    [self.view addSubview:pageViewController.view];
    [pageViewController didMoveToParentViewController:self];
}

#pragma mark - UIPageViewController Data Source


- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (self.recordVC == viewController) {
        return self.classesVC;
    }
    
    if (self.chatbotVC == viewController) {
        return self.recordVC;
    }
    
    return nil;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (self.recordVC == viewController) {
        return self.chatbotVC;
    }
    
    if (self.classesVC == viewController) {
        return self.recordVC;
    }
    
    return nil;
}

#pragma mark - Other


@end
