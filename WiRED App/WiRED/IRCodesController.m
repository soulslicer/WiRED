//
//  IRCodesController.m
//  WiRED
//
//  Created by Yaadhav Raaj on 6/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "IRCodesController.h"
#import "AppDelegate.h"
#import "UserDefaults.h"
#import "IRCodeCellMain.h"

@interface IRCodesController ()

@end

@implementation IRCodesController

@synthesize table,addView,irDeviceName,irView,dimmerView,subviewRemoteView,segmentControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Network Delegates
-(void)delegateGetIRCodeList:(NSMutableArray*)irArr{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(irArr!=nil){
            irCodeArray=irArr;
            [self.table reloadData];
            //[self.table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [remoteView updateUIButtonLabels];
    });
}
-(void)delegatePostRunDate:(ResponseTypes)responseType response:(int)response{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserDefaults printData:responseType response:response];
        if(response==USER_RUNDATESET){
            [SVProgressHUD showSuccessWithStatus:@"Set"];
            [networkLayer GetIRCodeListAsync:[UserDefaults getUsername] irdevice:irDeviceName];
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error occurred"];
        }
    });
}
-(void)delegatePostRawLoopCount:(ResponseTypes)responseType response:(int)response{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserDefaults printData:responseType response:response];
        if(response==USER_LOOPUPDATED){
            [SVProgressHUD showSuccessWithStatus:@"Set"];
            [networkLayer GetIRCodeListAsync:[UserDefaults getUsername] irdevice:irDeviceName];
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error occurred"];
        }
    });
}
-(void)delegateSendIRData:(ResponseTypes)responseType response:(int)response ircommand:(NSString*)ircommand{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserDefaults printData:responseType response:response];
        if(response==PHONERET_VERIFYSUCCESS){

        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Error occurred for %@",ircommand]];
        }
        for (NSInteger i = 0; i < [self.table numberOfRowsInSection:0]; ++i){
            UITableViewCell* cell=[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if([cell.textLabel.text isEqualToString:ircommand]){
                [[cell.contentView viewWithTag:10]removeFromSuperview];
            }
        }
        
        for (id object in [remoteView.view subviews]) {
            if ([object isKindOfClass:[UIButton class]]) {
                UIButton* myButton = (UIButton*)object;
                if([myButton.currentTitle isEqualToString:ircommand]){
                    [[myButton viewWithTag:10]removeFromSuperview];
                }
            }
        }
    });
}
-(void)reloadTable{
    [networkLayer GetIRCodeListAsync:[UserDefaults getUsername] irdevice:irDeviceName];
}
-(void)delegateIRCodeFromDevice:(ResponseTypes)responseType response:(int)response{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [UserDefaults printData:responseType response:response];
        if(response==USER_IRCODEADDED){
            [SVProgressHUD showSuccessWithStatus:@"IR Added"];
            [self performSelector:@selector(reloadTable) withObject:Nil afterDelay:2];
        }else if(response==PHONERET_IRTIMEOUT){
            [SVProgressHUD showErrorWithStatus:@"No IR was captured"];
        }else if(response==ERROR_IRCODEEXISTS){
            [SVProgressHUD showErrorWithStatus:@"This IR Code already exists"];
        }else{
            [SVProgressHUD showErrorWithStatus:@"An error occurred"];
        }
    });
}

//Table Delegates
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Select an option";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(irCodeArray!=nil)
        return [irCodeArray count];
    else return 0;
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77;
}
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    IRObject* irCode=[irCodeArray objectAtIndex:[indexPath row]];
    cell.textLabel.text=irCode.IRCommand;
    cell.detailTextLabel.text=irCode.DescIRCommand;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    return cell;
    /*
    static NSString *CellIdentifier = @"IRCodeCellMainReuseIdentifier";
    IRCodeCellMain *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (IRCodeCellMain *)[IRCodeCellMain cellFromNibNamed:@"IRCodeCellXIB"];
    }
    
    IRObject* irCode=[irCodeArray objectAtIndex:[indexPath row]];
    cell.title.text=irCode.IRCommand;
    
    return cell;
     */
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    IRObject* irCode=[irCodeArray objectAtIndex:[indexPath row]];
    NSLog(@"%@",irCode.RunDate);
    NSLog(@"%d",irCode.loopCount);
    
    [modIRCode updateUI:irCode.RunDate loop:irCode.loopCount];
    [modIRCode setData:irCode.IRCommand desc:irCode.DescIRCommand];
    [self loadModIRCodeView];
    //[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __block bool success=false;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });
            IRObject* toDelete=[irCodeArray objectAtIndex:[indexPath row]];
            success=[networkLayer PostRemoveIRCodeSync:[UserDefaults getUsername] irdevice:irDeviceName ircommand:toDelete.IRCommand delegate:NO];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                if(success){
                    IRObject* toDelete=[irCodeArray objectAtIndex:[indexPath row]];
                    [irCodeArray removeObject:toDelete];
                    NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
                    [tableView beginUpdates];
                    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];
                    [remoteView updateUIButtonLabels];
                }else{
                    [SVProgressHUD showErrorWithStatus:@"Unable to delete"];
                }
            });
        });
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IRObject* selectedObject=[irCodeArray objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner setFrame:CGRectMake(250,10, 20, 20)];
    
    spinner.tag=10;
    [[cell contentView] addSubview:spinner];
    [spinner startAnimating];

    [networkLayer SendIRDataAsync:[UserDefaults getUsername] password:[UserDefaults getPassword] irdevice:irDeviceName ircommand:selectedObject.IRCommand];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    /*
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"Send?" message:@"Would you like to send this IR data" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
     */
}
/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){
        NSLog(@"Cancel");
    }else if(buttonIndex==1){
        NSLog(@"Confirm");
        [SVProgressHUD showWithStatus:@"Sending"];
        [networkLayer SendIRDataAsync:[UserDefaults getUsername] password:[UserDefaults getPassword] irdevice:irDeviceName ircommand:selectedObject.IRCommand];
    }
}
 */

-(void)sendIRData:(NSString*)ircommand{
    IRObject* selectedObject=nil;
    for(IRObject* irObj in irCodeArray){
        if([irObj.IRCommand isEqualToString:ircommand])
            selectedObject=irObj;
    }
    
    //Add a spinner to button
    for (id object in [remoteView.view subviews]) {
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton* myButton = (UIButton*)object;
            if([myButton.currentTitle isEqualToString:ircommand]){
                NSLog(@"Button found %@",ircommand);
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [spinner setFrame:CGRectMake((myButton.frame.size.width/2)-10,(myButton.frame.size.height/2)-10, 20, 20)];
                spinner.tag=10;
                [myButton addSubview:spinner];
                [spinner startAnimating];
            }
        }
    }
    
    if(selectedObject!=nil){
        [networkLayer SendIRDataAsync:[UserDefaults getUsername] password:[UserDefaults getPassword] irdevice:irDeviceName ircommand:selectedObject.IRCommand];
    }
}

-(void)openModIRWindowWith:(NSString*)ircommand{
    
    IRObject* irCode=nil;
    for(IRObject* irObj in irCodeArray){
        if([irObj.IRCommand isEqualToString:ircommand])
            irCode=irObj;
    }
    
    if(irCode!=nil){
        NSLog(@"%@",irCode.RunDate);
        NSLog(@"%d",irCode.loopCount);
        
        [modIRCode updateUI:irCode.RunDate loop:irCode.loopCount];
        [modIRCode setData:irCode.IRCommand desc:irCode.DescIRCommand];
        [self loadModIRCodeView];
    }else{
        NSLog(@"No such command");
    }
}

-(void)openAddIRCodeWindowWith:(NSString*)ircommand desc:(NSString*)desc{
    irCodeView.irCommandNameLabel.text=ircommand;
    irCodeView.irCommandDescLabel.text=desc;
    [self loadAddNewIRCodeWindow];
}

-(void)saveAndSendData:(NSString*)date ircommand:(NSString*)ircommand loop:(int)loop{
    if(loop!=-1){
        NSLog(@"Setting loop to %d",loop);
        [networkLayer PostRawLoopCountAsync:[UserDefaults getUsername] irdevice:irDeviceName ircommand:ircommand loopcount:loop];
    }
    if(date!=nil){
        NSLog(@"%@ %@",irDeviceName,ircommand);
        NSLog(@"Setting date to %@",date);
        [networkLayer PostRunDateAsync:[UserDefaults getUsername] irdevice:irDeviceName ircommand:ircommand rundate:date];
    }
}

-(void)saveAndSendIRReceiver:(NSString*)ircommand desc:(NSString*)desc{
    [SVProgressHUD showWithStatus:@"Fire your IR towards WiRED when the LEDS flash. You have 10s to fire or you can try again!"];
    [networkLayer SendIRCodeFromDeviceAsync:[UserDefaults getUsername] password:[UserDefaults getPassword] irdevice:irDeviceName ircommand:ircommand desc:desc];
}

- (IBAction)SegmentSelectAction {
    switch (segmentControl.selectedSegmentIndex) {
        case 0:{
            table.hidden=NO;
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 [table setAlpha:1.0];
                                 [subviewRemoteView setAlpha:0.0];
                             }
                             completion:^(BOOL finished){//this block starts only when
                                subviewRemoteView.hidden=YES;
                             }];
            break;
        }
            
        case 1:{
            subviewRemoteView.hidden=NO;
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 [table setAlpha:0.0];
                                 [subviewRemoteView setAlpha:1.0];
                             }
                             completion:^(BOOL finished){//this block starts only when
                                 table.hidden=YES;
                             }];
            break;
        }
            
        default:
            break;
    }
}



-(void)loadModIRCodeView{
    NSLog(@"Load Mod IR Code");
    addView.hidden=NO;
    dimmerView.hidden=NO;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [addView setAlpha:1.0];
                         [dimmerView setAlpha:0.2];
                     }
                     completion:^(BOOL finished){//this block starts only when
                     }];
}
-(void)closeModIRCodeView{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [addView setAlpha:0];
                         [dimmerView setAlpha:0];
                     }
                     completion:^(BOOL finished){//this block starts only when
                         addView.hidden=YES;
                         
                     }];
}
 
-(void)loadAddNewIRCodeWindow{
    NSLog(@"Load Add");
    //if(segmentControl.selectedSegmentIndex==0){
    irView.hidden=NO;
    dimmerView.hidden=NO;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [irView setAlpha:1.0];
                         [dimmerView setAlpha:0.2];
                     }
                     completion:^(BOOL finished){//this block starts only when
                     }];
    //}
}
-(void)closeAddIRCodeWindow{
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [irView setAlpha:0];
                         [dimmerView setAlpha:0];
                     }
                     completion:^(BOOL finished){//this block starts only when
                         irView.hidden=YES;
                         dimmerView.hidden=YES;
                     }];
}

-(void)setNetworkLayer{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    networkLayer = appDelegate.networkLayer;
    [networkLayer setDelegate:(id)self];
}

-(void)viewDidAppear:(BOOL)animated{
    [networkLayer setDelegate:(id)self];
}

-(void)addBarButton{
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc]
                                initWithTitle:@"Add"
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(loadAddNewIRCodeWindow)];
    self.navigationItem.rightBarButtonItem = btnSave;
}

-(void)initiateModIRView{
    //modIRCode=[[ModifyIRCode alloc]init];
    //modIRCode.codeController=self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    modIRCode=appDelegate.modIRCode;
    modIRCode.codeController=self;
    [self.addView addSubview:modIRCode.view];
    addView.alpha=0;
    addView.hidden=YES;
    
    irCodeView=appDelegate.irCodeView;
    irCodeView.codeController=self;
    [self.irView addSubview:irCodeView.view];
    irView.alpha=0;
    irView.hidden=YES;
    
    dimmerView.alpha=0;
    dimmerView.hidden=YES;
    
    //remote
    remoteView=appDelegate.remoteView;
    remoteView.codeController=self;
    [self.subviewRemoteView addSubview:remoteView.view];
    subviewRemoteView.hidden=YES;
    subviewRemoteView.alpha=0;
}

- (void)viewDidLoad
{
    self.title=irDeviceName;
    irCodeArray=nil;

    [self setNetworkLayer];
    [self addBarButton];
    [self initiateModIRView];
    [networkLayer GetIRCodeListAsync:[UserDefaults getUsername] irdevice:irDeviceName];
    [SVProgressHUD dismiss];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidDisappear:(BOOL)animated{
    [remoteView clearOutButtons];
    /*
    for (UIView *viewb in [self.addView subviews]) {
        [viewb removeFromSuperview];
    }*/
}

-(NSMutableArray*)getCodeArray{
    return irCodeArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
