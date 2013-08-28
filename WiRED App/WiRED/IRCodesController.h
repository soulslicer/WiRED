//
//  IRCodesController.h
//  WiRED
//
//  Created by Yaadhav Raaj on 6/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkLayer.h"
#import "ModifyIRCode.h"
#import "AddIRCodeView.h"
#import "RemoteControlView.h"

@interface IRCodesController : UIViewController{
    NetworkLayer* networkLayer;
    NSMutableArray* irCodeArray;
    ModifyIRCode* modIRCode;
    AddIRCodeView* irCodeView;
    RemoteControlView* remoteView;
    //IRObject* selectedObject;
}

@property(nonatomic,strong)IBOutlet UITableView* table;
@property(nonatomic,strong)IBOutlet UIView* addView;
@property(nonatomic,strong)IBOutlet UIView* irView;
@property(nonatomic,strong)IBOutlet UIView* dimmerView;
@property(nonatomic,strong)IBOutlet UIView* subviewRemoteView;
@property(nonatomic,strong)IBOutlet UISegmentedControl* segmentControl;
@property(nonatomic,strong)NSString* irDeviceName;

-(void)closeAddIRCodeWindow;
-(void)closeModIRCodeView;
-(void)saveAndSendData:(NSString*)date ircommand:(NSString*)ircommand loop:(int)loop;
-(void)saveAndSendIRReceiver:(NSString*)ircommand desc:(NSString*)desc;
-(void)openAddIRCodeWindowWith:(NSString*)ircommand desc:(NSString*)desc;
-(void)openModIRWindowWith:(NSString*)ircommand;
-(void)sendIRData:(NSString*)ircommand;

-(NSMutableArray*)getCodeArray;
@end
