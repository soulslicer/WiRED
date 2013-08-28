//
//  NetworkLayer.m
//  WiRED
//
//  Created by Yaadhav Raaj on 3/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "NetworkLayer.h"
#import "UserDefaults.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation WiFiSettings
@synthesize SSID,Phrase,Username,Password,DeviceKey;
@end

@implementation IRObject
@synthesize IRDevice,Image,DescIRDevice,IRCommand,DescIRCommand,DataString,loopCount,RunDate;
@end

@implementation NetworkLayer

-(id) init{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

-(void)setDelegate:(id<NetworkLayerDelegate>)setDelegate {
    if (delegate != setDelegate) {
        delegate = setDelegate;
    }
}

-(void)setHostPortName:(NSString*)name port:(NSString*)port{
    hostName=name;
    portName=port;
}

-(NSString*)getHostName{
    return hostName;
}

-(NSString*)getHostLink{
    return [NSString stringWithFormat:@"http://%@:%@/",hostName,portName];
}

/* WiFly Driver Code */

NSString* serverAdd=@"169.254.1.1";
uint16_t port = 2000;

-(NSString*)checkSSIDMatch{
    // Does not work on the simulator.
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }
    NSLog(@"SSID: %@",ssid);
    return ssid;
}

-(void)timeOut{
    NSLog(@"Timed out");
    [timer invalidate];
    [asyncSocket disconnect];
    [delegate delegateWiFlySetUpSent:WIFTIMEOUT];
}

- (void)startTimer{
    timer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timeOut) userInfo:nil repeats:YES];
}

- (void)SendWiFiSettings:(WiFiSettings*)passWiFiSettings;
{
    [delegate delegateWiFlySetUpSent:WIFCONNECTING];
    wifiSettings=passWiFiSettings;
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    
    if (![asyncSocket connectToHost:serverAdd onPort:port error:&error])
    {
        NSLog(@"Unable to connect due to invalid configuration: %@", error);
    }
    else
    {
        NSLog(@"Connecting...IP:%@, port:%i", serverAdd, port);
    }
    
    [self startTimer];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [timer invalidate];
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    [sock readDataWithTimeout:-1 tag:0];
    [self sendBuf];
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socket:didWriteDataWithTag:");
    [sock readDataWithTimeout:-1 tag:0];
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *response = [[NSString alloc] initWithData:data  encoding:NSASCIIStringEncoding];
    NSLog(@"read response:%@", response);
    [sock readDataWithTimeout:-1 tag:0];    
}

//Write serial to WiFly via telnet
-(void)writeData:(NSString*)command{
    NSLog(@"write: %@",command);
    NSData *requestData = [command dataUsingEncoding:NSASCIIStringEncoding];
    [self delay:0.5];
    [asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
}

-(void)delay:(double)time{
    double startTime = CACurrentMediaTime();
    while(1){
        if((CACurrentMediaTime()-startTime)>time)
            break;
    }
}

-(void)sendBuf{
    [self writeData:@"$$$"];
    NSString* buildSSID=[NSString stringWithFormat:@"set wlan ssid %@\r",wifiSettings.SSID];
    [self writeData:buildSSID];
    NSString* buildPass=[NSString stringWithFormat:@"set wlan phrase %@\r",wifiSettings.Phrase];
    [self writeData:buildPass];
    NSString* buildComm=[NSString stringWithFormat:@"set comm remote %@:%@:%@:\r",wifiSettings.Username,wifiSettings.Password,wifiSettings.DeviceKey];
    NSLog(@"%@",buildComm);
    [self writeData:buildComm];
    NSString* buildDevIP=[NSString stringWithFormat:@"set opt deviceid %@:\r",hostName];
    [self writeData:buildDevIP];
    
    
    [self writeData:@"set wlan join 1\r"];
    [self writeData:@"set wlan channel 0\r"];
    [self writeData:@"set ip dhcp 1\r"];
    [self writeData:@"save\r"];
    [self writeData:@"reboot\r"];
    
    [delegate delegateWiFlySetUpSent:WIFDATASENT];
}


/*Server Code */

-(void)SendIRCodeFromDeviceSync:(NSString*)username password:(NSString*)password irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand desc:(NSString*)desc{
    NSString* post=[NSString stringWithFormat:@"username=%@&password=%@&irdevice=%@&ircommand=%@&desc=%@",username,password,irdevice,ircommand,desc];
    post=[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSString* restAPI=[NSString stringWithFormat:@"%@SendIRCodeFromDevice",[self getHostLink]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:restAPI]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];

    if(!error){
        NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultString);
        NSArray *stringArray = [resultString componentsSeparatedByString: @":"];
        NSString* respType=[stringArray objectAtIndex:0];
        ResponseTypes responseType;
        int intResponse=-1;
        if([respType isEqualToString:@"DB"]) responseType=RESPDATABASE;
        else if([respType isEqualToString:@"DV"]) responseType=RESPDEVICE;
        else responseType=RESPERROR;
        if(responseType!=RESPERROR) intResponse=[[stringArray objectAtIndex:1] integerValue];
        [delegate delegateIRCodeFromDevice:responseType response:intResponse];
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        [delegate delegateIRCodeFromDevice:RESPERROR response:-1];
    }
}

-(void)SendIRCodeFromDeviceAsync:(NSString*)username password:(NSString*)password irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand desc:(NSString*)desc{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self SendIRCodeFromDeviceSync:username password:password irdevice:irdevice ircommand:ircommand desc:desc];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegateIRCodeFromDevice:RESPERROR response:-1];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(void)SendIRDataSync:(NSString*)username password:(NSString*)password irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand{
    
    NSString* post=[NSString stringWithFormat:@"username=%@&password=%@&irdevice=%@&ircommand=%@",username,password,irdevice,ircommand];
    post=[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSString* restAPI=[NSString stringWithFormat:@"%@SendIRData",[self getHostLink]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:restAPI]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultString);
        NSArray *stringArray = [resultString componentsSeparatedByString: @":"];
        NSString* respType=[stringArray objectAtIndex:0];
        ResponseTypes responseType;
        int intResponse=-1;
        if([respType isEqualToString:@"DB"]) responseType=RESPDATABASE;
        else if([respType isEqualToString:@"DV"]) responseType=RESPDEVICE;
        else responseType=RESPERROR;
        if(responseType!=RESPERROR){ intResponse=[[stringArray objectAtIndex:1] integerValue];
            if(intResponse==PHONERET_VERIFYSUCCESS){
                NSString* ircommand=[stringArray objectAtIndex:2];
                ircommand=[ircommand stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                [delegate delegateSendIRData:responseType response:intResponse ircommand:ircommand];
            }else{
                [delegate delegateSendIRData:responseType response:intResponse ircommand:ircommand];
            }
        }else
        [delegate delegateSendIRData:responseType response:intResponse ircommand:nil];
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        [delegate delegateSendIRData:RESPERROR response:-1 ircommand:nil];
    }
    
}

-(void)SendIRDataAsync:(NSString*)username password:(NSString*)password irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self SendIRDataSync:username password:password irdevice:irdevice ircommand:ircommand];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegateSendIRData:RESPERROR response:-1 ircommand:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
    
}

-(void)SendVerifyDeviceStatusSync:(NSString*)username password:(NSString*)password{
    NSString* post=[NSString stringWithFormat:@"username=%@&password=%@",username,password];
    post=[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSString* restAPI=[NSString stringWithFormat:@"%@SendVerifyDeviceStatus",[self getHostLink]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:restAPI]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultString);
        NSArray *stringArray = [resultString componentsSeparatedByString: @":"];
        NSString* respType=[stringArray objectAtIndex:0];
        ResponseTypes responseType;
        int intResponse=-1;
        if([respType isEqualToString:@"DB"]) responseType=RESPDATABASE;
        else if([respType isEqualToString:@"DV"]) responseType=RESPDEVICE;
        else responseType=RESPERROR;
        if(responseType!=RESPERROR) intResponse=[[stringArray objectAtIndex:1] integerValue];
        [delegate delegateSendVerifyDeviceStatus:responseType response:intResponse];
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        [delegate delegateSendVerifyDeviceStatus:RESPERROR response:-1];
    }
    
}

-(void)SendVerifyDeviceStatusAsync:(NSString*)username password:(NSString*)password{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self SendVerifyDeviceStatusSync:username password:password];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegateSendVerifyDeviceStatus:RESPERROR response:-1];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(void)PostRawLoopCountSync:(NSString*)username irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand loopcount:(int)loopcount{
    
    NSString* strLoopCount=[NSString stringWithFormat:@"%d",loopcount];
    NSString* post=[NSString stringWithFormat:@"username=%@&irdevice=%@&ircommand=%@&loopcount=%@",username,irdevice,ircommand,strLoopCount];
    post=[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSString* restAPI=[NSString stringWithFormat:@"%@PostRawLoopCount",[self getHostLink]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:restAPI]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultString);
        NSArray *stringArray = [resultString componentsSeparatedByString: @":"];
        NSString* respType=[stringArray objectAtIndex:0];
        ResponseTypes responseType;
        int intResponse=-1;
        if([respType isEqualToString:@"DB"]) responseType=RESPDATABASE;
        else if([respType isEqualToString:@"DV"]) responseType=RESPDEVICE;
        else responseType=RESPERROR;
        if(responseType!=RESPERROR) intResponse=[[stringArray objectAtIndex:1] integerValue];
        [delegate delegatePostRawLoopCount:responseType response:intResponse];
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        [delegate delegatePostRawLoopCount:RESPERROR response:-1];
    }
    
    
}


-(void)PostRawLoopCountAsync:(NSString*)username irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand loopcount:(int)loopcount{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self PostRawLoopCountSync:username irdevice:irdevice ircommand:ircommand loopcount:loopcount];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegatePostRawLoopCount:RESPERROR response:-1];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
    
}

-(void)PostLoginInfoSync:(NSString*)username password:(NSString*)password{
    
    NSString* post=[NSString stringWithFormat:@"username=%@&password=%@",username,password];
    post=[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSString* restAPI=[NSString stringWithFormat:@"%@PostLoginInfo",[self getHostLink]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:restAPI]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultString);
        NSArray *stringArray = [resultString componentsSeparatedByString: @":"];
        NSString* respType=[stringArray objectAtIndex:0];
        ResponseTypes responseType;
        int intResponse=-1;
        if([respType isEqualToString:@"DB"]) responseType=RESPDATABASE;
        else if([respType isEqualToString:@"DV"]) responseType=RESPDEVICE;
        else responseType=RESPERROR;
        if(responseType!=RESPERROR) intResponse=[[stringArray objectAtIndex:1] integerValue];
        [delegate delegatePostLoginInfo:responseType response:intResponse];
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        [delegate delegatePostLoginInfo:RESPERROR response:-1];
    }
    
}

-(void)PostLoginInfoAsync:(NSString*)username password:(NSString*)password{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self PostLoginInfoSync:username password:password];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegatePostLoginInfo:RESPERROR response:-1];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(void)GetRegisteredStatusSync:(NSString*)username devicekey:(NSString*)devicekey{
    
    NSString* url=[NSString stringWithFormat:@"%@GetRegisteredStatus?username=%@&devicekey=%@",[self getHostLink],username,devicekey];
    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];

    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultString);
        NSArray *stringArray = [resultString componentsSeparatedByString: @":"];
        NSString* respType=[stringArray objectAtIndex:0];
        ResponseTypes responseType;
        int intResponse=-1;
        if([respType isEqualToString:@"DB"]) responseType=RESPDATABASE;
        else if([respType isEqualToString:@"DV"]) responseType=RESPDEVICE;
        else responseType=RESPERROR;
        if(responseType!=RESPERROR) intResponse=[[stringArray objectAtIndex:1] integerValue];
        [delegate delegateGetRegisteredStatus:responseType response:intResponse];
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        [delegate delegateGetRegisteredStatus:RESPERROR response:-1];
    }
    
}

-(void)GetRegisteredStatusAsync:(NSString*)username devicekey:(NSString*)devicekey{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self GetRegisteredStatusSync:username devicekey:devicekey];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegateGetRegisteredStatus:RESPERROR response:-1];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(bool)PostRemoveIRCodeSync:(NSString*)username irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand delegate:(bool)del{
    
    NSString* post=[NSString stringWithFormat:@"username=%@&irdevice=%@&ircommand=%@",username,irdevice,ircommand];
    post=[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSString* restAPI=[NSString stringWithFormat:@"%@PostRemoveIRCode",[self getHostLink]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:restAPI]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultString);
        NSArray *stringArray = [resultString componentsSeparatedByString: @":"];
        NSString* respType=[stringArray objectAtIndex:0];
        ResponseTypes responseType;
        int intResponse=-1;
        if([respType isEqualToString:@"DB"]) responseType=RESPDATABASE;
        else if([respType isEqualToString:@"DV"]) responseType=RESPDEVICE;
        else responseType=RESPERROR;
        if(responseType!=RESPERROR) intResponse=[[stringArray objectAtIndex:1] integerValue];
        if(del)[delegate delegatePostRemoveIRCode:responseType response:intResponse];
        else{
            if(intResponse==USER_IRCODEREMOVED)
                return true;
            else return false;
        }
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        if(del)[delegate delegatePostRemoveIRCode:RESPERROR response:-1];
        else return false;
    }
    return false;
}

-(void)PostRemoveIRCodeAsync:(NSString*)username irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self PostRemoveIRCodeSync:username irdevice:irdevice ircommand:ircommand delegate:YES];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegatePostRemoveIRCode:RESPERROR response:-1];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(bool)PostRemoveIRDeviceSync:(NSString*)username irdevice:(NSString*)irdevice delegate:(bool)del{
    
    NSString* post=[NSString stringWithFormat:@"username=%@&irdevice=%@",username,irdevice];
    post=[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSString* restAPI=[NSString stringWithFormat:@"%@PostRemoveIRDevice",[self getHostLink]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:restAPI]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultString);
        NSArray *stringArray = [resultString componentsSeparatedByString: @":"];
        NSString* respType=[stringArray objectAtIndex:0];
        ResponseTypes responseType;
        int intResponse=-1;
        if([respType isEqualToString:@"DB"]) responseType=RESPDATABASE;
        else if([respType isEqualToString:@"DV"]) responseType=RESPDEVICE;
        else responseType=RESPERROR;
        if(responseType!=RESPERROR) intResponse=[[stringArray objectAtIndex:1] integerValue];
        if(del)[delegate delegatePostRemoveIRDevice:responseType response:intResponse];
        else{
            if(intResponse!=USER_IRTABLEREMOVED)
                return false;
            else return true;
        }
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        if(del)[delegate delegatePostRemoveIRDevice:RESPERROR response:-1];
        else{
            return false;
        }
    }
    return false;
}

-(void)PostRemoveIRDeviceAsync:(NSString*)username irdevice:(NSString*)irdevice{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self PostRemoveIRDeviceSync:username irdevice:irdevice delegate:YES];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegatePostRemoveIRDevice:RESPERROR response:-1];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(bool)PostAddIRDeviceSync:(NSString*)username irdevice:(NSString*)irdevice desc:(NSString*)desc delegate:(bool)del{
    NSString* post=[NSString stringWithFormat:@"username=%@&irdevice=%@&desc=%@",username,irdevice,desc];
    post=[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSString* restAPI=[NSString stringWithFormat:@"%@PostAddIRDevice",[self getHostLink]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:restAPI]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultString);
        NSArray *stringArray = [resultString componentsSeparatedByString: @":"];
        NSString* respType=[stringArray objectAtIndex:0];
        ResponseTypes responseType;
        int intResponse=-1;
        if([respType isEqualToString:@"DB"]) responseType=RESPDATABASE;
        else if([respType isEqualToString:@"DV"]) responseType=RESPDEVICE;
        else responseType=RESPERROR;
        if(responseType!=RESPERROR) intResponse=[[stringArray objectAtIndex:1] integerValue];
        if(del)[delegate delegatePostAddIRDevice:responseType response:intResponse];
        else{
            if(intResponse==USER_IRTABLEADDED || intResponse==USER_IRTABLEUPDATED)
                return true;
            else return false;
        }
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        if(del)[delegate delegatePostAddIRDevice:RESPERROR response:-1];
        else return false;
    }
    return false;
}

-(void)PostAddIRDeviceAsync:(NSString*)username irdevice:(NSString*)irdevice desc:(NSString*)desc{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self PostAddIRDeviceSync:username irdevice:irdevice desc:desc delegate:YES];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegatePostAddIRDevice:RESPERROR response:-1];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(void)GetLocalIPInfoSync:(NSString*)username{
    NSString* url=[NSString stringWithFormat:@"%@GetLocalIPInfo?username=%@",[self getHostLink],username];
    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultString);
        NSArray *stringArray = [resultString componentsSeparatedByString: @":"];
        NSString* localIP=[stringArray objectAtIndex:1];
        
        if([localIP length]>2) [delegate delegateGetLocalIPInfo:localIP];
        else [delegate delegateGetLocalIPInfo:nil];
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        [delegate delegateGetLocalIPInfo:nil];
    }
}

-(void)GetLocalIPInfoAsync:(NSString*)username{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self GetLocalIPInfoSync:username];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegateGetLocalIPInfo:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(void)GetIRDeviceListSync:(NSString*)username{
    NSString* url=[NSString stringWithFormat:@"%@GetIRDeviceList?username=%@",[self getHostLink],username];
    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        //NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSMutableArray *jsonArray;
        jsonArray=[NSJSONSerialization JSONObjectWithData: result options: NSJSONReadingMutableContainers error: &e];
        if (!jsonArray) {
            NSLog(@"ERROR JSON: %@", e);
            [delegate delegateGetIRDeviceList:nil];
        } else {
            /*
            for(NSDictionary *item in jsonArray) {
                NSLog(@"Item: %@", item);
            }
             */
            [delegate delegateGetIRDeviceList:[UserDefaults convertJSONArray:jsonArray]];
        }
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        [delegate delegateGetIRDeviceList:nil];
    }
}

-(void)GetIRDeviceListAsync:(NSString*)username{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self GetIRDeviceListSync:username];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegateGetIRDeviceList:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(void)GetIRCodeListSync:(NSString*)username irdevice:(NSString*)irdevice{
    NSString* url=[NSString stringWithFormat:@"%@GetIRCodeList?username=%@&irdevice=%@",[self getHostLink],username,irdevice];
    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        //NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSMutableArray *jsonArray;
        jsonArray=[NSJSONSerialization JSONObjectWithData: result options: NSJSONReadingMutableContainers error: &e];
        if (!jsonArray) {
            NSLog(@"ERROR JSON: %@", e);
            [delegate delegateGetIRCodeList:nil];
        } else {
            /*
             for(NSDictionary *item in jsonArray) {
             NSLog(@"Item: %@", item);
             }
             */
            [delegate delegateGetIRCodeList:[UserDefaults convertJSONArray:jsonArray]];
        }
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        [delegate delegateGetIRCodeList:nil];
    }
}

-(void)GetIRCodeListAsync:(NSString*)username irdevice:(NSString*)irdevice{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self GetIRCodeListSync:username irdevice:irdevice];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegateGetIRCodeList:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(void)PostRunDateSync:(NSString*)username irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand rundate:(NSString*)rundate{
    NSString* post=[NSString stringWithFormat:@"username=%@&irdevice=%@&ircommand=%@&rundate=%@",username,irdevice,ircommand,rundate];
    post=[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSString* restAPI=[NSString stringWithFormat:@"%@PostRunDate",[self getHostLink]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:restAPI]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultString);
        NSArray *stringArray = [resultString componentsSeparatedByString: @":"];
        NSString* respType=[stringArray objectAtIndex:0];
        ResponseTypes responseType;
        int intResponse=-1;
        if([respType isEqualToString:@"DB"]) responseType=RESPDATABASE;
        else if([respType isEqualToString:@"DV"]) responseType=RESPDEVICE;
        else responseType=RESPERROR;
        if(responseType!=RESPERROR) intResponse=[[stringArray objectAtIndex:1] integerValue];
        [delegate delegatePostRunDate:responseType response:intResponse];
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        [delegate delegatePostRunDate:RESPERROR response:-1];
    }
}
-(void)PostRunDateAsync:(NSString*)username irdevice:(NSString*)irdevice ircommand:(NSString*)ircommand rundate:(NSString*)rundate{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self PostRunDateSync:username irdevice:irdevice ircommand:ircommand rundate:rundate];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegatePostRunDate:RESPERROR response:-1];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(void)PostRetreiveDeviceKeySync:(NSString*)username password:(NSString*)password{
    NSString* post=[NSString stringWithFormat:@"username=%@&password=%@",username,password];
    post=[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSString* restAPI=[NSString stringWithFormat:@"%@PostRetreiveDeviceKey",[self getHostLink]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:restAPI]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* result=nil;
    result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if(!error){
        NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        resultString = [resultString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if([resultString isEqualToString:@"null"]){
            [delegate delegatePostRetreiveDeviceKey:nil];
        }else{
            [delegate delegatePostRetreiveDeviceKey:resultString];
        }
    }else{
        NSLog(@"ERROR: %@",[error localizedDescription]);
        [delegate delegatePostRetreiveDeviceKey:nil];  
    }

}
-(void)PostRetreiveDeviceKeyAsync:(NSString*)username password:(NSString*)password{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        @try {
            [self PostRetreiveDeviceKeySync:username password:password];
        }
        @catch (NSException* exception) {
            NSLog(@"Exception = %@", exception);
            [delegate delegatePostRetreiveDeviceKey:nil];        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

@end
