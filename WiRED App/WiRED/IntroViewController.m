//
//  IntroViewController.m
//  WiRED
//
//  Created by Yaadhav Raaj on 4/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "IntroViewController.h"
#import "IntroScrollViewController.h"
#import "AppDelegate.h"
#import "UserDefaults.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

@synthesize scrollView,usernameField,passwordField,ssidField,phraseField,devicekeyField,ssidLabel,localipLabel,registeredButton,sendButton,verifyButton,fadeLogo,fadeText,fadeSSIDLogo,fadeSSIDText,routerImage,serverField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Update SSID Field
-(void)updateSSIDField{
    NSString* ssid=[networkLayer checkSSIDMatch];
    if([ssid isEqualToString:@"WiRED"]){
        ssidField.enabled=YES;
        phraseField.enabled=YES;
        devicekeyField.enabled=YES;
        sendButton.enabled=YES;
        verifyButton.enabled=NO;
        if(pageHit){
            pageHit=NO;
            [timerChanger stopTimer1Animation];
            [timerChanger startTimer2Animation];
        }
    }else if(ssid!=nil){
        sendButton.enabled=NO;
        verifyButton.enabled=YES;
        ssidField.enabled=NO;
        phraseField.enabled=NO;
        devicekeyField.enabled=NO;
    }else{
        sendButton.enabled=NO;
        verifyButton.enabled=NO;
        ssidField.enabled=NO;
        phraseField.enabled=NO;
        devicekeyField.enabled=NO;
    }
    ssidLabel.text=[NSString stringWithFormat:@"SSID: %@",ssid];
}

-(void)callbackUpdateSSID{
    //(CHANGE WAIT DONE IMAGE)
    [self updateSSIDField];
}

//Delegates
-(void)delegatePostRetreiveDeviceKey:(NSString*)key{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        if(key!=nil){
            [SVProgressHUD showSuccessWithStatus:@"Logged in"];
            [UserDefaults setDeviceKey:key];
            [self.scrollView dismissViewControllerAnimated:YES completion:nil];
        }else{
            [SVProgressHUD showErrorWithStatus:@"DeviceKey error"];
        }
    });

}
-(void)delegatePostLoginInfo:(ResponseTypes)responseType response:(int)response{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        NSString* respString=[UserDefaults printData:responseType response:response];
        if([UserDefaults hasNoError:respString]){
            if(newUserType){
                [SVProgressHUD showErrorWithStatus:@"Username not available"];
            }else{
                [SVProgressHUD showWithStatus:@"Retreiving DeviceKey"];
                [UserDefaults setAccount:usernameField.text password:passwordField.text];
                [networkLayer PostRetreiveDeviceKeyAsync:usernameField.text password:passwordField.text];
            }
        }else{
            if(newUserType){
                [SVProgressHUD showSuccessWithStatus:@"Username available"];
                [scrollView goToPage:2];
                [self updateSSIDField];
                [timerChanger startTimer1Animation];
                pageHit=YES;
            }else{
                [SVProgressHUD showErrorWithStatus:@"Login error"];
            }
        }
    });
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
            [timerChanger timeoutImage];
            break;
        }
            
        case WIFDATASENT:{
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Sent"];
            [self performSelector:@selector(callbackUpdateSSID) withObject:nil afterDelay:10];
            sendButton.enabled=NO;ssidField.enabled=NO;phraseField.enabled=NO;devicekeyField.enabled=NO;
            stringDeviceKey=devicekeyField.text; stringSSID=ssidField.text; stringSSID=ssidField.text;
            [UserDefaults setDeviceKey:devicekeyField.text];
            [timerChanger wifiSentImage];
            NSLog(@"Please wait for 10s..");
            //(SHOW PLEASE WAIT IMAGE, THEN SEE HOW TO REUPDATE ON CALLBACK?)
            return;
            break;
        }
            
        default:
            break;
    }
    [self updateSSIDField];
}
-(void)goToPage3{
    [scrollView goToPage:3];
}
-(void)delegateGetRegisteredStatus:(ResponseTypes)responseType response:(int)response{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        NSString* respString=[UserDefaults printData:responseType response:response];
        if([UserDefaults hasNoError:respString]){
            [SVProgressHUD showSuccessWithStatus:@"Verified!"];
            [UserDefaults setAccount:usernameField.text password:passwordField.text];
            [UserDefaults setState:NO];
            [UserDefaults setPage:3];
            [networkLayer GetLocalIPInfoAsync:[UserDefaults getUsername]];
            [timerChanger tickImage];
            [self performSelector:@selector(goToPage3) withObject:nil afterDelay:2];
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error try again!"];
            [timerChanger crossImage];
        }
    });
}
-(void)delegateGetLocalIPInfo:(NSString*)ip{
    dispatch_async(dispatch_get_main_queue(), ^{
            if(ip!=nil) localipLabel.text=[NSString stringWithFormat:@"Local IP:%@",ip];
            else localipLabel.text=[NSString stringWithFormat:@"IP Error"];
        });
}
-(void)delegateSendVerifyDeviceStatus:(ResponseTypes)responseType response:(int)response{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        NSString* respString=[UserDefaults printData:responseType response:response];
        if([UserDefaults hasNoError:respString]){
            [SVProgressHUD showSuccessWithStatus:@"Verified!"];
            [UserDefaults setPage:4];
            [scrollView goToPage:4];
        }else{
            [SVProgressHUD showErrorWithStatus:@"Unable to Verify!"];
        }
    });
}

//Actions
- (IBAction)LoginAction {
    newUserType=false;
    [SVProgressHUD showWithStatus:@"Authenticating" maskType:SVProgressHUDMaskTypeClear];
    [UserDefaults setServerIP:serverField.text];
    [networkLayer setHostPortName:[UserDefaults getServerIP] port:PORT];
    [networkLayer PostLoginInfoAsync:usernameField.text password:passwordField.text];
}
- (IBAction)NewUserAction {
    newUserType=true;
    [SVProgressHUD showWithStatus:@"Authenticating" maskType:SVProgressHUDMaskTypeClear];
    [UserDefaults setServerIP:serverField.text];
    [networkLayer setHostPortName:[UserDefaults getServerIP] port:PORT];
    [networkLayer PostLoginInfoAsync:usernameField.text password:passwordField.text];
}
- (IBAction)SendWiFiDataAction {
    WiFiSettings* wifiSettings=[[WiFiSettings alloc]init];
    NSString* ssid=ssidField.text; NSString* user=usernameField.text;
    NSString* pass=passwordField.text; NSString* phrase=phraseField.text;
    NSString* devkey=devicekeyField.text;
    if(([ssid length]<=0) || ([phrase length]<=0) || ([devkey length]<=0)){
        [SVProgressHUD showErrorWithStatus:@"Please fill all fields"];
        return;
    }
    [timerChanger stopTimer2Animation];
    [timerChanger arrowImage];
    wifiSettings.SSID=ssid; wifiSettings.Username=user; wifiSettings.Password=pass;
    wifiSettings.Phrase=phrase; wifiSettings.DeviceKey=devkey;
    [networkLayer SendWiFiSettings:wifiSettings];
}
- (IBAction)VerifyAction {
    [networkLayer GetRegisteredStatusAsync:usernameField.text devicekey:devicekeyField.text];
}
- (IBAction)TestConnectionAction {
    [networkLayer SendVerifyDeviceStatusAsync:[UserDefaults getUsername] password:[UserDefaults getPassword]];
}
- (IBAction)LetsGoDismiss {
    [UserDefaults setPage:0];
    [UserDefaults setState:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.scrollView dismissViewControllerAnimated:YES completion:NULL];
}

//Keyboard dismiss
-(void)setupGestures{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
}
-(void)dismissKeyboard {
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
    [ssidField resignFirstResponder];
    [phraseField resignFirstResponder];
    [devicekeyField resignFirstResponder];
}

-(void)setNetworkLayer{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    networkLayer = appDelegate.networkLayer;
    [networkLayer setDelegate:(id)self];
}

-(void)viewDidAppear:(BOOL)animated{
    [networkLayer setDelegate:(id)self];
    [self updateSSIDField];
    [timerChanger initialize];
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

-(void)animateImgView:(UIImageView*)imgView label:(UILabel*)label imgName:(NSString*)imgName textString:(NSString*)textString{
    if([imgView image]==nil){
        imgView.alpha=0;
        imgView.image = [UIImage imageNamed:imgName];
        [UIView animateWithDuration:1
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [imgView setAlpha:1];
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                         }];
    }else{
        [UIView animateWithDuration:1
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [imgView setAlpha:0];
                         }
                         completion:^(BOOL finished){
                             
                             imgView.image = [UIImage imageNamed:imgName];
                             [UIView animateWithDuration:1
                                                   delay:0.0
                                                 options:UIViewAnimationOptionBeginFromCurrentState
                                              animations:^{
                                                  [imgView setAlpha:1];
                                              }
                                              completion:^(BOOL finished){
                                              }];
                         }];
    }
    
    if([label.text isEqualToString:textString]){
        label.alpha=0;
        [UIView animateWithDuration:1
                              delay:0.5
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [label setAlpha:1];
                         }
                         completion:^(BOOL finished){   
                         }];
    }else{
        [UIView animateWithDuration:1
                              delay:0.5
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [label setAlpha:0];
                         }
                         completion:^(BOOL finished){
                             
                             label.text=textString;
                             [UIView animateWithDuration:1
                                                   delay:0.0
                                                 options:UIViewAnimationOptionBeginFromCurrentState
                                              animations:^{
                                                  [label setAlpha:1];
                                              }
                                              completion:^(BOOL finished){
                                              }];
                         }];
    }

    
}

-(void)animateLogoText{
    [self animateImgView:fadeLogo label:fadeText imgName:@"LogoBig.png" textString:@"InfraRed Control on the Cloud"];
}

- (void)viewDidLoad
{
    fadeLogo.alpha=0;
    fadeText.alpha=0;
    fadeSSIDLogo.alpha=0;
    fadeSSIDText.alpha=0;
    routerImage.alpha=0.7;
    
    timerChanger=[[TimerImageChanger alloc]init];
    timerChanger.introController=self;
    [scrollView goToPage:[UserDefaults getPage]];
    [self setNetworkLayer];
    [self setupGestures];
    [self addSSIDGesture];
    [self setUpForegroundListen];
    [self performSelector:@selector(animateLogoText) withObject:nil afterDelay:1];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
