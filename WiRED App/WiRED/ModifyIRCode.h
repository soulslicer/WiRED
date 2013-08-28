//
//  ModifyIRCode.h
//  WiRED
//
//  Created by Yaadhav Raaj on 6/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IRCodesController;
@interface ModifyIRCode : UIViewController{
    NSString* myDate;
    int myLoopCount;
    NSString* irCommand;
    NSString* descCommand;
    bool loopModified;
    bool dateModified;
    bool switchModified;
}

@property(nonatomic,assign)IRCodesController* codeController;
@property(nonatomic,weak)IBOutlet UIDatePicker* datePicker;
@property(nonatomic,weak)IBOutlet UILabel* nameLabel;
@property(nonatomic,weak)IBOutlet UILabel* descLabel;
@property(nonatomic,weak)IBOutlet UIStepper* stepper;
@property(nonatomic,weak)IBOutlet UISwitch* switcher;
@property(nonatomic,weak)IBOutlet UILabel* loopLabel;
@property(nonatomic,weak)IBOutlet UILabel* dateLabel;

-(IBAction)dateChanged;
-(IBAction)stepperHit;
-(IBAction)switchHit;
-(void)updateUI:(NSString*)date loop:(int)loop;
-(void)setData:(NSString*)irCom desc:(NSString*)desc;

@end
