//
//  IRDeviceController.m
//  WiRED
//
//  Created by Yaadhav Raaj on 6/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "IRDeviceController.h"
#import "AppDelegate.h"
#import "UserDefaults.h"

@interface IRDeviceController ()

@end

@implementation IRDeviceController

@synthesize table,addView,dimmerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Network Delegates
-(void)delegateGetIRDeviceList:(NSMutableArray*)irArr{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(irArr!=nil){
            irDevArray=irArr;
            //[self.table reloadData];
            [self.table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    });
}
-(void)delegatePostAddIRDevice:(ResponseTypes)responseType response:(int)response{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserDefaults printData:responseType response:response];
        if(response==USER_IRTABLEUPDATED){
            //[SVProgressHUD showSuccessWithStatus:@"Device updated"];
            [networkLayer GetIRDeviceListAsync:[UserDefaults getUsername]];
        }else if(response==USER_IRTABLEADDED){
            //[SVProgressHUD showSuccessWithStatus:@"Device added"];
            [networkLayer GetIRDeviceListAsync:[UserDefaults getUsername]];
        }else{
            [SVProgressHUD showErrorWithStatus:@"Unable to add"];
        }
    });
}
/*
-(void)delegatePostRemoveIRDevice:(ResponseTypes)responseType response:(int)response{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserDefaults printData:responseType response:response];
        if(response==USER_IRTABLEREMOVED){
            [SVProgressHUD showSuccessWithStatus:@"Device deleted"];
            [networkLayer GetIRDeviceListAsync:[UserDefaults getUsername]];
        }else {
            [SVProgressHUD showErrorWithStatus:@"Unable to delete"];
        }
    });
}
*/

//TableView Delegates


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
    if(irDevArray!=nil)
        return [irDevArray count];
    else return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    IRObject* irDevice=[irDevArray objectAtIndex:[indexPath row]];
    cell.textLabel.text=irDevice.IRDevice;
    cell.detailTextLabel.text=irDevice.DescIRDevice;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __block bool success=false;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });
            IRObject* toDelete=[irDevArray objectAtIndex:[indexPath row]];
            success=[networkLayer PostRemoveIRDeviceSync:[UserDefaults getUsername] irdevice:toDelete.IRDevice delegate:NO];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                if(success){
                    IRObject* toDelete=[irDevArray objectAtIndex:[indexPath row]];
                    [irDevArray removeObject:toDelete];
                    NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
                    [tableView beginUpdates];
                    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];
                }else{
                    [SVProgressHUD showErrorWithStatus:@"Unable to delete"];
                }
            });
        });
    }
}
-(void)pushController:(NSIndexPath*)indexPath{
    IRObject* irDevice=[irDevArray objectAtIndex:[indexPath row]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    codesController = [storyboard instantiateViewControllerWithIdentifier:@"IRCodesController"];
    codesController.irDeviceName=irDevice.IRDevice;
    [self.navigationController pushViewController:codesController animated:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [SVProgressHUD showWithStatus:@"Loading"];
    [self performSelector:@selector(pushController:) withObject:indexPath afterDelay:1];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
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
                                action:@selector(loadAddNewIRDeviceWindow)];
    self.navigationItem.rightBarButtonItem = btnSave;
}

-(void)loadIRCodesController{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    irDeviceView=appDelegate.irDeviceView;
    irDeviceView.deviceController=self;
    [self.addView addSubview:irDeviceView.view];
    addView.alpha=0;
    addView.hidden=NO;
    
    dimmerView.alpha=0;
    dimmerView.hidden=YES;
}

- (void)viewDidLoad
{
    irDevArray=nil;
    [self loadIRCodesController];
    [self setNetworkLayer];
    [self addBarButton];
    [networkLayer GetIRDeviceListAsync:[UserDefaults getUsername]];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

//Load the add new IR Device Window
-(void)loadAddNewIRDeviceWindow{
    NSLog(@"Load Add Device");
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
-(void)closeIRDeviceWindow{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [addView setAlpha:0];
                         [dimmerView setAlpha:0];
                     }
                     completion:^(BOOL finished){//this block starts only when
                         addView.hidden=YES;
                         dimmerView.hidden=YES;
                     }];
}
-(void)addNewIRDevice:(NSString*)deviceName desc:(NSString*)desc{
    [networkLayer PostAddIRDeviceAsync:[UserDefaults getUsername] irdevice:deviceName desc:desc];

}

-(void)viewDidDisappear:(BOOL)animated{
    /*
    for (UIView *viewb in [self.addView subviews]) {
        [viewb removeFromSuperview];
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
