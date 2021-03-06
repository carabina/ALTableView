//
//  DetailViewController.m
//  ALTableViewFrameworkExamples
//
//  Created by Abimael Barea Puyana on 20/11/15.
//  Copyright © 2015 Abimael Barea Puyana. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setup ViewController

- (void) setupViewController:(UIViewController *) controller {
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    for (UIViewController *vC in self.childViewControllers) {
        [vC.view removeFromSuperview];
        [vC removeFromParentViewController];
    }
    self.controller = nil;
    
    self.view.autoresizesSubviews = YES;
    
    self.controller = (UIViewController *) controller;
    [self addChildViewController:self.controller];
    [self.view addSubview:self.controller.view];
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    self.controller.view.frame = frame;
    self.title = self.controller.title;
}

@end
