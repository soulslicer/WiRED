//
//  AddIRDeviceView.m
//  WiRED
//
//  Created by Yaadhav Raaj on 6/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "AddIRDeviceView.h"
#import "IRDeviceController.h"
#import "SVProgressHUD.h"

@interface AddIRDeviceView ()

@end

@implementation AddIRDeviceView

@synthesize deviceController,irDeviceDescLabel,irDeviceNameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)CloseAction {
    [deviceController closeIRDeviceWindow];
    [irDeviceNameLabel resignFirstResponder];
    [irDeviceDescLabel resignFirstResponder];
}
- (IBAction)AddAction {
    if(([irDeviceNameLabel.text length]<=0) || ([irDeviceDescLabel.text length]<=0)){
        [SVProgressHUD showErrorWithStatus:@"Please fill all fields"];
    }else{
        [deviceController addNewIRDevice:irDeviceNameLabel.text desc:irDeviceDescLabel.text];
        irDeviceNameLabel.text=@""; irDeviceDescLabel.text=@"";
        [deviceController closeIRDeviceWindow];
    }
    [irDeviceNameLabel resignFirstResponder];
    [irDeviceDescLabel resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
