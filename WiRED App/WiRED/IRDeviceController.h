//
//  IRDeviceController.h
//  WiRED
//
//  Created by Yaadhav Raaj on 6/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkLayer.h"
#import "AddIRDeviceView.h"
#import "IRCodesController.h"

@interface IRDeviceController : UIViewController{
    NetworkLayer* networkLayer;
    NSMutableArray* irDevArray;
    AddIRDeviceView* irDeviceView;
    IRCodesController* codesController;
}

@property(nonatomic,strong)IBOutlet UITableView* table;
@property(nonatomic,strong)IBOutlet UIView* addView;
@property(nonatomic,strong)IBOutlet UIView* dimmerView;

-(void)closeIRDeviceWindow;
-(void)addNewIRDevice:(NSString*)deviceName desc:(NSString*)desc;

@end
