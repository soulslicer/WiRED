//
//  AddIRCodeView.h
//  WiRED
//
//  Created by Yaadhav Raaj on 7/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IRCodesController;
@interface AddIRCodeView : UIViewController

@property(nonatomic,assign)IRCodesController* codeController;
@property(nonatomic,strong)IBOutlet UITextField* irCommandNameLabel;
@property(nonatomic,strong)IBOutlet UITextField* irCommandDescLabel;

@end
