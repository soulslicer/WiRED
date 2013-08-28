//
//  IntroViewController.h
//  WiRED
//
//  Created by Yaadhav Raaj on 4/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkLayer.h"
#import "TimerImageChanger.h"

@class IntroScrollViewController;
@interface IntroViewController : UIViewController{
    NetworkLayer* networkLayer;
    TimerImageChanger* timerChanger;
    bool newUserType;
    
    NSString* stringSSID;
    NSString* stringPhrase;
    NSString* stringDeviceKey;
    bool pageHit;
}

@property(nonatomic,strong)IntroScrollViewController* scrollView;

@property(nonatomic,strong)IBOutlet UITextField* usernameField;
@property(nonatomic,strong)IBOutlet UITextField* passwordField;
@property(nonatomic,strong)IBOutlet UITextField* ssidField;
@property(nonatomic,strong)IBOutlet UITextField* phraseField;
@property(nonatomic,strong)IBOutlet UITextField* devicekeyField;
@property(nonatomic,strong)IBOutlet UITextField* serverField;

@property(nonatomic,strong)IBOutlet UILabel* ssidLabel;
@property(nonatomic,strong)IBOutlet UILabel* localipLabel;
@property(nonatomic,strong)IBOutlet UIButton* registeredButton;
@property(nonatomic,strong)IBOutlet UIButton* sendButton;
@property(nonatomic,strong)IBOutlet UIButton* verifyButton;

@property(nonatomic,strong)IBOutlet UILabel* fadeText;
@property(nonatomic,strong)IBOutlet UIImageView* fadeLogo;
@property(nonatomic,strong)IBOutlet UILabel* fadeSSIDText;
@property(nonatomic,strong)IBOutlet UIImageView* fadeSSIDLogo;
@property(nonatomic,strong)IBOutlet UIImageView* routerImage;

-(void)animateImgView:(UIImageView*)imgView label:(UILabel*)label imgName:(NSString*)imgName textString:(NSString*)textString;

@end
