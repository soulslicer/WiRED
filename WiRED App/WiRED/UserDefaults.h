//
//  UserDefaults.h
//  WiRED
//
//  Created by Yaadhav Raaj on 3/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NetworkLayer.h"

#define DEFAULTS_USERNAME   @"USERNAME"
#define DEFAULTS_PASSWORD   @"PASSWORD"
#define DEFAULTS_DEVICEKEY  @"DEVICEKEY"
#define DEFAULTS_STATE      @"STATE"
#define DEFAULTS_PAGENUM    @"PAGENUM"
#define DEFAULTS_SERVERIP   @"SERVERIP"

@interface UserDefaults : UIView

+(void)setAccount:(NSString*)username password:(NSString*)password;
+(void)setDeviceKey:(NSString*)deviceKey;
+(void)setServerIP:(NSString*)serverIP;
+(void)setPage:(int)page;
+(void)setState:(bool)state;
+(void)clearAllInfo;

+(NSString*)getUsername;
+(NSString*)getPassword;
+(NSString*)getDeviceKey;
+(NSString*)getServerIP;
+(int)getPage;
+(bool)getState;

+(NSString*)printData:(ResponseTypes)responseType response:(int)response;

+(NSString*)clearErrorData:(NSString*)string;

+(bool)hasNoError:(NSString*)string;

+(int)processLoopAmount:(NSString*)dataString;

+(NSMutableArray*)convertJSONArray:(NSMutableArray*)array;

+(NSInteger)getAsciiCount:(NSString*)string;

+(bool)checkRemoteWord:(NSString*)compare;

@end
