//
//  AccountController.m
//  WiRED
//
//  Created by Yaadhav Raaj on 7/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "AccountController.h"
#import "UserDefaults.h"

@interface AccountController ()

@end

@implementation AccountController

@synthesize devKeyLabel,usernameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)LogOutAction {
    [UserDefaults clearAllInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
