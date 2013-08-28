//
//  TimerImageChanger.h
//  WiRED
//
//  Created by Yaadhav Raaj on 8/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IntroViewController;
@interface TimerImageChanger : NSObject{
    int T1State;
    int T2State;
    
    NSTimer* timer1;
    NSTimer* timer2;
}

@property(nonatomic,assign)IntroViewController* introController;

-(void)startTimer1Animation;
-(void)stopTimer1Animation;
-(void)startTimer2Animation;
-(void)stopTimer2Animation;
-(void)arrowImage;
-(void)timeoutImage;
-(void)wifiSentImage;
-(void)tickImage;
-(void)crossImage;
-(void)initialize;

@end
