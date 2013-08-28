//
//  AppDelegate.h
//  WiRED
//
//  Created by Yaadhav Raaj on 3/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkLayer.h"
#import "ModifyIRCode.h"
#import "AddIRDeviceView.h"
#import "AddIRCodeView.h"
#import "RemoteControlView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NetworkLayer* networkLayer;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NetworkLayer* networkLayer;
@property (nonatomic, strong) ModifyIRCode* modIRCode;
@property (nonatomic, strong) AddIRDeviceView* irDeviceView;
@property (nonatomic, strong) AddIRCodeView* irCodeView;
@property (nonatomic, strong) RemoteControlView* remoteView;

@end
