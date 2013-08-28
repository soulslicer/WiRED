//
//  TimerImageChanger.m
//  WiRED
//
//  Created by Yaadhav Raaj on 8/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "TimerImageChanger.h"
#import "IntroViewController.h"

@implementation TimerImageChanger

-(void)initialize{
    T1State=0;
    T2State=0;
}

-(void)t1Animate{
    NSLog(@"(TIME1TICK");
    if(T1State==0){
        T1State=1;
        [self.introController animateImgView:self.introController.fadeSSIDLogo label:self.introController.fadeSSIDText imgName:@"1RedBut@2x.png" textString:@"Hit the red button on WiRED to continue"];
    }else if(T1State==1){
        T1State=2;
        [self.introController animateImgView:self.introController.fadeSSIDLogo label:self.introController.fadeSSIDText imgName:@"2LED@2x.png" textString:@"Wait for the Green Light to stop flashing"];
    }else if(T1State==2){
        T1State=0;
        [self.introController animateImgView:self.introController.fadeSSIDLogo label:self.introController.fadeSSIDText imgName:@"3Settings@2x.png" textString:@"Go to WiFi settings and select WiRED"];
    }
}

-(void)t2Animate{
    NSLog(@"(TIME2TICK");
    if(T2State==0){
        T2State=1;
        [self.introController animateImgView:self.introController.fadeSSIDLogo label:self.introController.fadeSSIDText imgName:@"GreenYellow@2x.png" textString:@"Ensure Green and Yellow LEDS are on"];
    }else if(T2State==1){
        T2State=0;
        [self.introController animateImgView:self.introController.fadeSSIDLogo label:self.introController.fadeSSIDText imgName:@"Tick@2x.png" textString:@"Enter your credentials and hit send"];
    }
}

-(void)stopTimer1Animation{
    NSLog(@"(STOP TIMER1)");
    [timer1 invalidate];
}

-(void)startTimer1Animation{
    NSLog(@"(START TIMER1)");
    timer1=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(t1Animate) userInfo:nil repeats:YES];
}

-(void)startTimer2Animation{
    NSLog(@"(START TIMER2)");
    timer2=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(t2Animate) userInfo:nil repeats:YES];
}

-(void)stopTimer2Animation{
    NSLog(@"(STOP TIMER2)");
    [timer2 invalidate];
}

-(void)arrowImage{
    [self.introController animateImgView:self.introController.fadeSSIDLogo label:self.introController.fadeSSIDText imgName:@"Sending@2x.png" textString:@"Sending Data to WiRED"];
}
-(void)timeoutImage{
    [self.introController animateImgView:self.introController.fadeSSIDLogo label:self.introController.fadeSSIDText imgName:@"Timeout@2x.png" textString:@"Timeout. Hit Send again"];
}
-(void)wifiSentImage{
    [self.introController animateImgView:self.introController.fadeSSIDLogo label:self.introController.fadeSSIDText imgName:@"GreenYellow@2x.png" textString:@"Wait for Green Yellow LEDS to turn on"];
}
-(void)tickImage{
    [self.introController animateImgView:self.introController.fadeSSIDLogo label:self.introController.fadeSSIDText imgName:@"Tick@2x.png" textString:@"Verified"];
}
-(void)crossImage{
    [self.introController animateImgView:self.introController.fadeSSIDLogo label:self.introController.fadeSSIDText imgName:@"Cross@2x.png" textString:@"Ensure you are reconnected to your WiFi"];
}

@end
