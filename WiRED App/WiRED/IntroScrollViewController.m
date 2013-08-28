//
//  IntroScrollViewController.m
//  WiRED
//
//  Created by Yaadhav Raaj on 4/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "IntroScrollViewController.h"
#import "UserDefaults.h"

@interface IntroScrollViewController ()

@end

@implementation IntroScrollViewController

@synthesize scrollView,introViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)goToPage:(int)page{
    switch (page) {
        case 1:
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            break;
            
        case 2:
            [self.scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
            break;
            
        case 3:
            [self.scrollView setContentOffset:CGPointMake(640, 0) animated:YES];
            break;
            
        case 4:
            [self.scrollView setContentOffset:CGPointMake(960, 0) animated:YES];
            break;
            
        default:
            break;
    }
}

- (void)viewDidLoad
{
    introViewController=[[IntroViewController alloc]init];
    introViewController.scrollView=self;
    [scrollView setContentSize:(CGSizeMake(introViewController.view.frame.size.width, introViewController.view.frame.size.height))];
    [scrollView addSubview:introViewController.view];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
