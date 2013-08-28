//
//  AddIRCodeView.m
//  WiRED
//
//  Created by Yaadhav Raaj on 7/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "AddIRCodeView.h"
#import "IRCodesController.h"

@interface AddIRCodeView ()

@end

@implementation AddIRCodeView

@synthesize codeController,irCommandDescLabel,irCommandNameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)CloseAction {
    [codeController closeAddIRCodeWindow];
    irCommandNameLabel.text=@"";
    irCommandDescLabel.text=@"";
    [irCommandDescLabel resignFirstResponder];
    [irCommandNameLabel resignFirstResponder];
}
- (IBAction)AddAction {
    if(([irCommandNameLabel.text length]<=0) || ([irCommandDescLabel.text length]<=0)){
        [SVProgressHUD showErrorWithStatus:@"Please fill all fields"];
    }else{
        [codeController saveAndSendIRReceiver:irCommandNameLabel.text desc:irCommandDescLabel.text];
        [codeController closeAddIRCodeWindow];
        irCommandNameLabel.text=@"";
        irCommandDescLabel.text=@"";
    }
    [irCommandDescLabel resignFirstResponder];
    [irCommandNameLabel resignFirstResponder];
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
