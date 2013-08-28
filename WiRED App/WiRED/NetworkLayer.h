//
//  NetworkLayer.h
//  WiRED
//
//  Created by Yaadhav Raaj on 3/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "SVProgressHUD.h"

//Host and general errors
#define PORT     @"8080"

//Phone return constants
#define PHONERET_WRONGUSERPASS  0
#define PHONERET_IPNOTFOUND     1
#define PHONERET_TIMEOUT        2
#define PHONERET_DATAERROR      3
#define PHONERET_VERIFYSUCCESS  4
#define PHONERET_IRTIMEOUT      5

//Database error constants
#define ERROR_NODEVICE          1
#define ERROR_DEVICETIED        2
#define ERROR_USEREXISTS        3
#define ERROR_USERPASSWRONG     4
#define ERROR_INVALID           5
#define ERROR_IRCODEEXISTS      6

//Database return constants
#define USER_ADDED              7
#define USER_UNTIED             8
#define USER_TIED               9
#define USER_UPDATED            10
#define USER_IRTABLEUPDATED     11
#define USER_IRTABLEADDED       12
#define USER_IRTABLEREMOVED     13
#define USER_IRCODEADDED        14
#define USER_IRCODEREMOVED      15
#define USER_LOOPUPDATED        16
#define USER_LOGINCORRECT       17
#define USER_DEVICEREGISTERED   18
#define USER_RUNDATESET         19

@interface WiFiSettings : NSObject

@property(nonatomic,strong)NSString* SSID;
@property(nonatomic,strong)NSString* Phrase;
@property(nonatomic,strong)NSString* Username;
@property(nonatomic,strong)NSString* Password;
@property(nonatomic,strong)NSString* DeviceKey;

@end

@interface IRObject : NSObject

@property(nonatomic,strong)NSString* IRDevice;
@property(nonatomic,strong)NSString* Image;
@property(nonatomic,strong)NSString* DescIRDevice;
@property(nonatomic,strong)NSString* IRCommand;
@property(nonatomic,strong)NSString* DescIRCommand;
@property(nonatomic,strong)NSString* DataString;
@property(nonatomic,strong)NSString* RunDate;
@property(nonatomic)int loopCount;

@end

typedef enum
{RESPDEVICE = 1,RESPDATABASE = 2,RESPERROR = 3}
ResponseTypes;
typedef enum
{WIFCONNECTING = 1,WIFDATASENT = 2,WIFTIMEOUT = 3}
WiFlyTypes;

@protocol NetworkLayerDelegate<NSObject>
@required
//Make protocols based on UI Requirements
-(void)delegateWiFlySetUpSent:(WiFlyTypes)wiflyType;
-(void)delegateIRCodeFromDevice:(ResponseTypes)responseType response:(int)response;
-(void)delegatePostRawLoopCount:(ResponseTypes)responseType response:(int)response;
-(void)delegatePostLoginInfo:(ResponseTypes)responseType response:(int)response;
-(void)delegateGetRegisteredStatus:(ResponseTypes)responseType response:(int)response;
-(void)delegateSendVerifyDeviceStatus:(ResponseTypes)responseType response:(int)response;
-(void)delegatePostRemoveIRCode:(ResponseTypes)responseType response:(int)response;
-(void)delegatePostRemoveIRDevice:(ResponseTypes)responseType response:(int)response;
-(void)delegatePostAddIRDevice:(ResponseTypes)responseType response:(int)response;
-(void)delegatePostRunDate:(ResponseTypes)responseType response:(int)response;
-(void)delegateGetLocalIPInfo:(NSString*)ip;
-(void)delegatePostRetreiveDeviceKey:(NSString*)key;
-(void)delegateGetIRDeviceList:(NSMutableArray*)irArr;
-(void)delegateGetIRCodeList:(NSMutableArray*)irArr;
-(void)delegateSendIRData:(ResponseTypes)responseType response:(int)response ircommand:(NSString*)ircommand;
@end

@class UserDefaults;
@interface NetworkLayer : NSObject<NetworkLayerDelegate>{
    id<NetworkLayerDelegate> delegate;
    GCDAsyncSocket *asyncSocket;
    NSTimer* timer;
    WiFiSettings* wifiSettings;
    NSString* hostName;
    NSString* portName;
}

-(id)init;
-(void)setDelegate:(id<NetworkLayerDelegate>)setDelegate;
-(void)setHostPortName:(NSString*)name port:(NSString*)port;
-(NSString*)getHostName;

-(void)SendWiFiSettings:(WiFiSettings*)passWiFiSettings;
-(NSString*)checkSSIDMatch;

-(void)SendIRCodeFromDeviceSync:(NSString*)username password:(NSString*)password irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand desc:(NSString*)desc;
-(void)SendIRCodeFromDeviceAsync:(NSString*)username password:(NSString*)password irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand desc:(NSString*)desc;

-(void)SendIRDataSync:(NSString*)username password:(NSString*)password irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand;
-(void)SendIRDataAsync:(NSString*)username password:(NSString*)password irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand;

-(void)SendVerifyDeviceStatusSync:(NSString*)username password:(NSString*)password;
-(void)SendVerifyDeviceStatusAsync:(NSString*)username password:(NSString*)password;

-(void)PostRawLoopCountSync:(NSString*)username irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand loopcount:(int)loopcount;
-(void)PostRawLoopCountAsync:(NSString*)username irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand loopcount:(int)loopcount;

-(void)PostRunDateSync:(NSString*)username irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand rundate:(NSString*)rundate;
-(void)PostRunDateAsync:(NSString*)username irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand rundate:(NSString*)rundate;

-(void)PostLoginInfoSync:(NSString*)username password:(NSString*)password;
-(void)PostLoginInfoAsync:(NSString*)username password:(NSString*)password;

-(void)GetRegisteredStatusSync:(NSString*)username devicekey:(NSString*)devicekey;
-(void)GetRegisteredStatusAsync:(NSString*)username devicekey:(NSString*)devicekey;

-(bool)PostRemoveIRCodeSync:(NSString*)username irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand delegate:(bool)del;
-(void)PostRemoveIRCodeAsync:(NSString*)username irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand;

-(bool)PostRemoveIRDeviceSync:(NSString*)username irdevice:(NSString*)irdevice delegate:(bool)del;
-(void)PostRemoveIRDeviceAsync:(NSString*)username irdevice:(NSString*)irdevice;

-(bool)PostAddIRDeviceSync:(NSString*)username irdevice:(NSString*)irdevice desc:(NSString*)desc delegate:(bool)del;
-(void)PostAddIRDeviceAsync:(NSString*)username irdevice:(NSString*)irdevice desc:(NSString*)desc;

-(void)PostRetreiveDeviceKeyAsync:(NSString*)username password:(NSString*)password;
-(void)PostRetreiveDeviceKeySync:(NSString*)username password:(NSString*)password;

-(void)GetLocalIPInfoSync:(NSString*)username;
-(void)GetLocalIPInfoAsync:(NSString*)username;

-(void)GetIRDeviceListSync:(NSString*)username;
-(void)GetIRDeviceListAsync:(NSString*)username;

-(void)GetIRCodeListSync:(NSString*)username irdevice:(NSString*)irdevice;
-(void)GetIRCodeListAsync:(NSString*)username irdevice:(NSString*)irdevice;

@end
