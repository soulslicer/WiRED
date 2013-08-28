//
//  SettingsController.h
//  WiRED
//
//  Created by Yaadhav Raaj on 7/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkLayer.h"

@interface SettingsController : UIViewController{
    NetworkLayer* networkLayer;
}

@property(nonatomic,strong)IBOutlet UILabel* ipLabel;
@property(nonatomic,strong)IBOutlet UILabel* ssidLabel;
@property(nonatomic,strong)IBOutlet UITextField* ssidField;
@property(nonatomic,strong)IBOutlet UITextField* phraseField;
@property(nonatomic,strong)IBOutlet UITextField* deviceKeyField;
@property(nonatomic,strong)IBOutlet UIButton* sendButton;
@property(nonatomic,strong)IBOutlet UIButton* verifyButton;


@end
