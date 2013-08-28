//
//  ModifyIRCode.m
//  WiRED
//
//  Created by Yaadhav Raaj on 6/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "ModifyIRCode.h"
#import "IRCodesController.h"

@interface ModifyIRCode ()

@end

@implementation ModifyIRCode

@synthesize codeController,datePicker,nameLabel,descLabel,stepper,loopLabel,dateLabel,switcher;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)CloseAction {
    [codeController closeModIRCodeView];
    loopModified=NO;
    dateModified=NO;
}
- (IBAction)SaveAction {
    if([switcher isOn]){
        if(loopModified){
            [codeController saveAndSendData:myDate ircommand:irCommand loop:myLoopCount];
        }else{
            [codeController saveAndSendData:myDate ircommand:irCommand loop:-1];
        }
    }else{
        if(loopModified){
            [codeController saveAndSendData:@"null" ircommand:irCommand loop:myLoopCount];
        }else{
            [codeController saveAndSendData:@"null" ircommand:irCommand loop:-1];
        }
    }
    [codeController closeModIRCodeView];
    loopModified=NO;
    dateModified=NO;
}
-(IBAction)dateChanged{
    NSDate *date = datePicker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *toSendVersion = [dateFormat stringFromDate:date];
    myDate=toSendVersion;
    [self updateUIWithData];
}
-(IBAction)stepperHit{
    loopModified=YES;
    myLoopCount=[stepper value];
    loopLabel.text=[NSString stringWithFormat:@"%d",myLoopCount];
}
-(IBAction)switchHit{
    
}

-(void)updateUIWithData{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    if(myDate!=nil){
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateD = [dateFormat dateFromString:myDate];
        
        [datePicker setDate:dateD animated:NO];
        
        [dateFormat setDateFormat:@"HH:mm:SS"];
        NSString *displayVersion = [dateFormat stringFromDate:dateD];
        dateLabel.text=displayVersion;
    }
    loopLabel.text=[NSString stringWithFormat:@"%d",myLoopCount];
    stepper.value=myLoopCount;
}

-(void)setData:(NSString*)irCom desc:(NSString*)desc{
    irCommand=irCom;
    descCommand=desc;
    descLabel.text=descCommand;
}

-(void)updateUI:(NSString*)date loop:(int)loop{
    descLabel.text=descCommand;
    if(date!=nil){
        date = [date substringToIndex:[date length] - 2];
        myDate=date;
        [switcher setOn:YES];
    }else{
        myDate=nil;
        [switcher setOn:NO];
    }
    if(loop==-1){
        myLoopCount=3;
        stepper.enabled=NO;
    }else{
        myLoopCount=loop;
    }
    [self updateUIWithData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
