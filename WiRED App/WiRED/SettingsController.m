//
//  SettingsController.m
//  WiRED
//
//  Created by Yaadhav Raaj on 7/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "SettingsController.h"
#import "AppDelegate.h"
#import "UserDefaults.h"

@interface SettingsController ()

@end

@implementation SettingsController

@synthesize ipLabel,ssidField,ssidLabel,phraseField,deviceKeyField,sendButton,verifyButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)delegateWiFlySetUpSent:(WiFlyTypes)wiflyType{
    switch (wiflyType) {
        case WIFCONNECTING:{
            [SVProgressHUD showWithStatus:@"Connecting"];
            break;
        }
            
        case WIFTIMEOUT:{
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"Timeout"];
            break;
        }
            
        case WIFDATASENT:{
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Sent. Please wait for 10s"];
            [self performSelector:@selector(updateSSIDField) withObject:nil afterDelay:10];
            sendButton.enabled=NO;ssidField.enabled=NO;phraseField.enabled=NO;deviceKeyField.enabled=NO;
            [UserDefaults setDeviceKey:deviceKeyField.text];
            NSLog(@"Please wait for 10s..");
            return;
            break;
        }
            
        default:
            break;
    }
    [self updateSSIDField];
}
-(void)delegateGetRegisteredStatus:(ResponseTypes)responseType response:(int)response{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        NSString* respString=[UserDefaults printData:responseType response:response];
        if([UserDefaults hasNoError:respString]){
            [SVProgressHUD showSuccessWithStatus:@"Verified!"];
            [networkLayer GetLocalIPInfoAsync:[UserDefaults getUsername]];
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error try again!"];
        }
    });
}
-(void)delegateGetLocalIPInfo:(NSString*)ip{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(ip!=nil) ipLabel.text=[NSString stringWithFormat:@"Local IP:%@",ip];
        else ipLabel.text=[NSString stringWithFormat:@"IP Error"];
    });
}-(void)delegateSendVerifyDeviceStatus:(ResponseTypes)responseType response:(int)response{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        NSString* respString=[UserDefaults printData:responseType response:response];
        if([UserDefaults hasNoError:respString]){
            [SVProgressHUD showSuccessWithStatus:@"Verified!"];
        }else{
            [SVProgressHUD showErrorWithStatus:@"Unable to Verify!"];
        }
    });
}

-(void)updateSSIDField{
    NSString* ssid=[networkLayer checkSSIDMatch];
    if([ssid isEqualToString:@"WiRED"]){
        ssidField.enabled=YES;
        phraseField.enabled=YES;
        deviceKeyField.enabled=YES;
        sendButton.enabled=YES;
        verifyButton.enabled=NO;
    }else if(ssid!=nil){
        sendButton.enabled=NO;
        verifyButton.enabled=YES;
        ssidField.enabled=NO;
        phraseField.enabled=NO;
        deviceKeyField.enabled=NO;
    }else{
        sendButton.enabled=NO;
        verifyButton.enabled=NO;
        ssidField.enabled=NO;
        phraseField.enabled=NO;
        deviceKeyField.enabled=NO;
    }
    ssidLabel.text=[NSString stringWithFormat:@"SSID: %@",ssid];
}

- (IBAction)TestConnectionAction {
    [SVProgressHUD showWithStatus:@"Testing"];
    [networkLayer SendVerifyDeviceStatusAsync:[UserDefaults getUsername] password:[UserDefaults getPassword]];
}
- (IBAction)SendAction {
    WiFiSettings* wifiSettings=[[WiFiSettings alloc]init];
    NSString* ssid=ssidField.text; 
    NSString* phrase=phraseField.text;
    NSString* devkey=deviceKeyField.text;
    if(([ssid length]<=0) || ([phrase length]<=0) || ([devkey length]<=0)){
        [SVProgressHUD showErrorWithStatus:@"Please fill all fields"];
        return;
    }
    wifiSettings.SSID=ssid; wifiSettings.Username=[UserDefaults getUsername]; wifiSettings.Password=[UserDefaults getPassword];
    wifiSettings.Phrase=phrase; wifiSettings.DeviceKey=devkey;
    [networkLayer SendWiFiSettings:wifiSettings];
}
- (IBAction)VerifyAction {
    [SVProgressHUD showWithStatus:@"Verifying"];
    [networkLayer GetRegisteredStatusAsync:[UserDefaults getUsername] devicekey:[UserDefaults getDeviceKey]];
}

-(void)addSSIDGesture{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateSSIDField)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [ssidLabel addGestureRecognizer:tapGestureRecognizer];
    ssidLabel.userInteractionEnabled = YES;
}

-(void)setUpForegroundListen{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSSIDField)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

-(void)setupGestures{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
}
-(void)dismissKeyboard {
    [ssidField resignFirstResponder];
    [phraseField resignFirstResponder];
    [deviceKeyField resignFirstResponder];
}

-(void)setNetworkLayer{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    networkLayer = appDelegate.networkLayer;
    [networkLayer setDelegate:(id)self];
}

-(void)viewDidAppear:(BOOL)animated{
    [networkLayer setDelegate:(id)self];
    [self updateSSIDField];
}

- (void)viewDidLoad
{
    [self setNetworkLayer];
    [self setupGestures];
    [self addSSIDGesture];
    [self setUpForegroundListen];
    [networkLayer GetLocalIPInfoAsync:[UserDefaults getUsername]];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
