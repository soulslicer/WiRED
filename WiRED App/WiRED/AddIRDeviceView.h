//
//  AddIRDeviceView.h
//  WiRED
//
//  Created by Yaadhav Raaj on 6/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IRDeviceController;
@interface AddIRDeviceView : UIViewController

@property(nonatomic,assign)IRDeviceController* deviceController;
@property(nonatomic,strong)IBOutlet UITextField* irDeviceNameLabel;
@property(nonatomic,strong)IBOutlet UITextField* irDeviceDescLabel;


@end
