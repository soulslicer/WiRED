//
//  RemoteControlView.h
//  WiRED
//
//  Created by Yaadhav Raaj on 8/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SETCOLOR [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]
#define UNSETCOLOR [UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]

@class IRCodesController;
@interface RemoteControlView : UIViewController{
    NSTimer* timerMain;
    UIButton* selectedButton;
}

@property(nonatomic,assign)IRCodesController* codeController;

-(void)updateUIButtonLabels;
-(void)clearOutButtons;

@end
