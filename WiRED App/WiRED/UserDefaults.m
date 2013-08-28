//
//  UserDefaults.m
//  WiRED
//
//  Created by Yaadhav Raaj on 3/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "UserDefaults.h"

@implementation UserDefaults

+(void)setAccount:(NSString*)username password:(NSString*)password{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:DEFAULTS_USERNAME];
    [defaults setObject:password forKey:DEFAULTS_PASSWORD];
    [defaults setBool:YES forKey:DEFAULTS_STATE];
    [defaults setObject:NULL forKey:DEFAULTS_DEVICEKEY];
    [defaults setObject:NULL forKey:DEFAULTS_SERVERIP];
    [defaults setInteger:0 forKey:DEFAULTS_PAGENUM];
    [defaults synchronize];
    NSLog(@"Data saved");
}

+(void)setDeviceKey:(NSString*)deviceKey{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceKey forKey:DEFAULTS_DEVICEKEY];
    [defaults synchronize];
    NSLog(@"DeviceKey saved");
}

+(void)setServerIP:(NSString*)serverIP{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:serverIP forKey:DEFAULTS_SERVERIP];
    [defaults synchronize];
    NSLog(@"SERVER IP SET TO %@",[UserDefaults getServerIP]);
    NSLog(@"IP saved");
}

+(void)setPage:(int)page{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:page forKey:DEFAULTS_PAGENUM];
    [defaults synchronize];
    NSLog(@"Page saved");
}

+(void)setState:(bool)state{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:state forKey:DEFAULTS_STATE];
    [defaults synchronize];
    NSLog(@"State saved");
}

+(void)clearAllInfo{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:NULL forKey:DEFAULTS_USERNAME];
    [defaults setObject:NULL forKey:DEFAULTS_PASSWORD];
    [defaults setBool:NO forKey:DEFAULTS_STATE];
    [defaults setObject:NULL forKey:DEFAULTS_DEVICEKEY];
    [defaults setInteger:0 forKey:DEFAULTS_PAGENUM];
    [defaults setObject:NULL forKey:DEFAULTS_SERVERIP];
    [defaults synchronize];
    NSLog(@"Data cleared");
}

+(NSString*)getUsername{
    return [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_USERNAME];
}
+(NSString*)getPassword{
    return [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_PASSWORD];
}
+(NSString*)getDeviceKey{
    return [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_DEVICEKEY];
}
+(NSString*)getServerIP{
    return [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_SERVERIP];
}
+(int)getPage{
    return [[NSUserDefaults standardUserDefaults] integerForKey:DEFAULTS_PAGENUM];
}
+(bool)getState{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_STATE];
}

+(NSString*)clearErrorData:(NSString*)string{
    NSArray *stringArray = [string componentsSeparatedByString: @":"];
    return [stringArray objectAtIndex:1];
}

+(bool)hasNoError:(NSString*)string{
    NSArray *stringArray = [string componentsSeparatedByString: @":"];
    int errType=[[stringArray objectAtIndex:0] integerValue];
    if(errType==1) return true;
    else if(errType==0) return false;
    return false;
}


+(NSString*)printData:(ResponseTypes)responseType response:(int)response{

    NSString* respXType;
    if(responseType==RESPDATABASE) respXType=@"RESPDATABASE";
    else if(responseType==RESPDEVICE) respXType=@"RESPDEVICE";
    else if(responseType==RESPERROR) respXType=@"RESPERROR";
    
    NSString* respType;
    NSString* errorType;
    NSString* userDisplay;
    if(responseType==RESPDEVICE){
        if(response==PHONERET_WRONGUSERPASS){
            respType=@"PHONERET_WRONGUSERPASS";
            errorType=@"0";
            userDisplay=@"Wrong username or password entered";
        }else if(response==PHONERET_IPNOTFOUND){
            respType=@"PHONERET_IPNOTFOUND";
            errorType=@"0";
            userDisplay=@"The correct public IP was not found";
        }else if(response==PHONERET_TIMEOUT){
            respType=@"PHONERET_TIMEOUT";
            errorType=@"0";
            userDisplay=@"Connection timed out";
        }else if(response==PHONERET_DATAERROR){
            respType=@"PHONERET_DATAERROR";
            errorType=@"0";
            userDisplay=@"Data format was not correct";
        }else if(response==PHONERET_VERIFYSUCCESS){
            respType=@"PHONERET_VERIFYSUCCESS";
            errorType=@"1";
            userDisplay=@"Device was verified successfully!";
        }else if(response==PHONERET_IRTIMEOUT){
            respType=@"PHONERET_IRTIMEOUT";
            errorType=@"0";
            userDisplay=@"No IR Command was sent!";
        }
    }else if(responseType==RESPDATABASE){
        if(response==ERROR_NODEVICE){
            respType=@"ERROR_NODEVICE";
            errorType=@"0";
            userDisplay=@"No such device key was found!";
        }else if(response==ERROR_DEVICETIED){
            respType=@"ERROR_DEVICETIED";
            errorType=@"0";
            userDisplay=@"This device key has already been tied!";
        }else if(response==ERROR_USEREXISTS){
            respType=@"ERROR_USEREXISTS";
            errorType=@"0";
            userDisplay=@"This username already exists!";
        }else if(response==ERROR_USERPASSWRONG){
            respType=@"ERROR_USERPASSWRONG";
            errorType=@"0";
            userDisplay=@"Wrong username or password!";
        }else if(response==ERROR_INVALID){
            respType=@"ERROR_INVALID";
            errorType=@"0";
            userDisplay=@"An error has occurred!";
        }else if(response==ERROR_IRCODEEXISTS){
            respType=@"ERROR_IRCODEEXISTS";
            errorType=@"0";
            userDisplay=@"This IR Code already exists!";
        }
        
        else if(response==USER_ADDED){
            respType=@"USER_ADDED";
            errorType=@"1";
            userDisplay=@"User added successfully!";
        }else if(response==USER_UPDATED){
            respType=@"USER_UPDATED";
            errorType=@"1";
            userDisplay=@"User info has been updated!";
        }else if(response==USER_IRTABLEUPDATED){
            respType=@"USER_IRTABLEUPDATED";
            errorType=@"1";
            userDisplay=@"Your IR device details have been changed!";
        }else if(response==USER_IRTABLEADDED){
            respType=@"USER_IRTABLEADDED";
            errorType=@"1";
            userDisplay=@"IR Device added!";
        }else if(response==USER_IRTABLEREMOVED){
            respType=@"USER_IRTABLEREMOVED";
            errorType=@"1";
            userDisplay=@"This IR Device has been removed";
        }else if(response==USER_IRCODEADDED){
            respType=@"USER_IRCODEADDED";
            errorType=@"1";
            userDisplay=@"A new IR Code has been added!";
        }else if(response==USER_IRCODEREMOVED){
            respType=@"USER_IRCODEREMOVED";
            errorType=@"1";
            userDisplay=@"IR Code has been removed!";
        }else if(response==USER_LOOPUPDATED){
            respType=@"USER_LOOPUPDATED";
            errorType=@"1";
            userDisplay=@"The loop count has been updated!";
        }else if(response==USER_LOGINCORRECT){
            respType=@"USER_LOGINCORRECT";
            errorType=@"1";
            userDisplay=@"Login Info Correct!";
        }else if(response==USER_DEVICEREGISTERED){
            respType=@"USER_DEVICEREGISTERED";
            errorType=@"1";
            userDisplay=@"Device Registered!";
        }else if(response==USER_RUNDATESET){
            respType=@"USER_RUNDATESET";
            errorType=@"1";
            userDisplay=@"Running date set!";
        }
    }else if(responseType==RESPERROR){
        respType=@"ERROR";
        errorType=@"0";
        userDisplay=@"An error has occured!";
    }

    
    NSLog(@"(%@:%@)",respXType,respType);
    NSString* finalString=[NSString stringWithFormat:@"%@:%@",errorType,userDisplay];
    return finalString;

}

+(int)processLoopAmount:(NSString*)dataString{
    char typeChar=[dataString characterAtIndex:0];
    int type=[[NSString stringWithFormat:@"%c", typeChar] intValue];
    if(type==0){
        int countChar=(int)[dataString characterAtIndex:1];
        if(countChar==45) return 3;
        countChar-=33;
        return countChar;
    }else return -1;

    return -1;
}

+(NSMutableArray*)convertJSONArray:(NSMutableArray*)array{
    NSMutableArray* irObjectArray=[[NSMutableArray alloc]initWithCapacity:500];
    for(NSDictionary *item in array) {
        IRObject* irObject=[[IRObject alloc]init];
        bool boolIRDevice=false;
        bool boolIRCommand=false;
        
        @try{
            NSString* irDevice=NULL;
            irDevice=[item objectForKey:@"IRDevice"];
            if(irDevice!=NULL){
                boolIRDevice=true;
                irObject.IRDevice=irDevice;
            }
        }@catch (NSException* e) {}
        
        @try{
            NSString* irCommand=NULL;
            irCommand=[item objectForKey:@"IRCommand"];
            if(irCommand!=NULL){
                boolIRCommand=true;
                irObject.IRCommand=irCommand;
            }
        }@catch (NSException* e) {}
        
        if(boolIRDevice){
            
            @try{
                NSString* image=NULL;
                image=[item objectForKey:@"Image"];
                if(image!=NULL)
                    irObject.Image=image;
            }@catch (NSException* e) {}
            
            @try{
                NSString* desc=NULL;
                desc=[item objectForKey:@"Description"];
                if(desc!=NULL)
                    irObject.DescIRDevice=desc;
            }@catch (NSException* e) {}
            
            irObject.IRCommand=nil;
            irObject.DescIRCommand=nil;
            irObject.DataString=nil;
            irObject.RunDate=nil;
            irObject.loopCount=0;

            
        }else if(boolIRCommand){
            
            @try{
                NSString* data=NULL;
                data=[item objectForKey:@"Datastring"];
                if(data!=NULL){
                    irObject.loopCount=[self processLoopAmount:data];
                    irObject.DataString=data;
                }
            }@catch (NSException* e) {}
            
            @try{
                NSString* desc=NULL;
                desc=[item objectForKey:@"Description"];
                if(desc!=NULL)
                    irObject.DescIRCommand=desc;
            }@catch (NSException* e) {}
            
            @try{
                NSString* rundate=NULL;
                rundate=[item objectForKey:@"Rundate"];
                if([rundate isKindOfClass:[NSNull class]]){
                    irObject.RunDate=nil;
                }else{
                    irObject.RunDate=rundate;
                }
            }@catch (NSException* e) {}
            
            irObject.DescIRDevice=nil;
            irObject.IRDevice=nil;
            irObject.Image=nil;
            
        }

        [irObjectArray addObject:irObject];
    }
    
    return irObjectArray;
}

+(NSInteger)getAsciiCount:(NSString*)string{
    int totalCount=0;
    for(int i=0;i<[string length];i++){
        totalCount+=[string characterAtIndex:i];
    }
    return totalCount;
}

+(bool)checkRemoteWord:(NSString*)compare{
    
    if([compare isEqualToString:@"AV"]      ||
       [compare isEqualToString:@"TV"]      ||
       [compare isEqualToString:@"POWER"]   ||
       [compare isEqualToString:@"A"]       ||
       [compare isEqualToString:@"B"]       ||
       [compare isEqualToString:@"M"]       ||
       [compare isEqualToString:@"N"]       ||
       [compare isEqualToString:@"U"]       ||
       [compare isEqualToString:@"D"]       ||
       [compare isEqualToString:@"L"]       ||
       [compare isEqualToString:@"R"]       ||
       [compare isEqualToString:@"OK"]      ||
       [compare isEqualToString:@"1"]       ||
       [compare isEqualToString:@"2"]       ||
       [compare isEqualToString:@"3"]       ||
       [compare isEqualToString:@"4"]       ||
       [compare isEqualToString:@"5"]       ||
       [compare isEqualToString:@"6"]       ||
       [compare isEqualToString:@"7"]       ||
       [compare isEqualToString:@"8"]       ||
       [compare isEqualToString:@"9"]       ||
       [compare isEqualToString:@"0"]       ||
       [compare isEqualToString:@"X"]       ||
       [compare isEqualToString:@"Y"])
        return YES;

    return NO;
}


@end
