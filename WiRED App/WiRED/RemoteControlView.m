//
//  RemoteControlView.m
//  WiRED
//
//  Created by Yaadhav Raaj on 8/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "RemoteControlView.h"
#import "IRCodesController.h"
#import "UserDefaults.h"

@interface RemoteControlView ()

@end

@implementation RemoteControlView

@synthesize codeController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)checIfHeldDown:(NSTimer *)timer{
    NSDictionary *userInfo = [timer userInfo];
    UIButton* myButton=[userInfo objectForKey:@"Button"];
    if(myButton.state==1){
        NSLog(@"%@ held down",myButton.currentTitle);
        myButton.highlighted=NO;
        selectedButton=myButton;
        [codeController openModIRWindowWith:myButton.currentTitle];
    }
    [timerMain invalidate];
}
- (IBAction)StartTimer:(id)sender {
    if([timerMain isValid]) [timerMain invalidate];
    UIButton* myButton = (UIButton*)sender;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:myButton, @"Button", nil];
    timerMain=[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checIfHeldDown:) userInfo:userInfo repeats:NO];
}

- (IBAction)ButtonAction:(id)sender{
    UIButton* myButton = (UIButton*)sender;
    if(selectedButton==myButton){
        selectedButton=nil;
        return;
    }
    NSLog(@" The button's title is %@.",myButton.currentTitle);
    if([[myButton titleColorForState:UIControlStateNormal] isEqual:SETCOLOR])
        [codeController sendIRData:myButton.currentTitle];
    else if([[myButton titleColorForState:UIControlStateNormal] isEqual:UNSETCOLOR])
        [codeController openAddIRCodeWindowWith:myButton.currentTitle desc:myButton.currentTitle];
}

-(void)clearOutButtons{
    for (id object in [self.view subviews]) {
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton* myButton = (UIButton*)object;
            [myButton setTitleColor:UNSETCOLOR forState:UIControlStateNormal];
        }
    }
}

-(void)updateUIButtonLabels{
    NSMutableArray* setRemoteWords=[[NSMutableArray alloc]init];
    for(IRObject* irObj in [codeController getCodeArray]){
        if([UserDefaults checkRemoteWord:irObj.IRCommand]){
            [setRemoteWords addObject:irObj.IRCommand];
        }
    }
    
    for (id object in [self.view subviews]) {
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton* myButton = (UIButton*)object;
            NSString* buttonTitle=myButton.currentTitle;
            if([setRemoteWords containsObject:buttonTitle]){
                [myButton setTitleColor:SETCOLOR forState:UIControlStateNormal];
            }else{
                [myButton setTitleColor:UNSETCOLOR forState:UIControlStateNormal];
            }
        }
    }
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
