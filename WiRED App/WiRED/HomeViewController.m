//
//  FirstViewController.m
//  WiRED
//
//  Created by Yaadhav Raaj on 3/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "UserDefaults.h"
#import "SVProgressHUD.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize table,logoView;


-(void)delegateSendVerifyDeviceStatus:(ResponseTypes)responseType response:(int)response{
    
    NSString* respString=[UserDefaults printData:responseType response:response];
    if([UserDefaults hasNoError:respString]) NSLog(@"Success!");
    else NSLog(@"Fail");
    
}

-(void)loadIntroViewIntroller{
    NSLog(@"Checking");
    if(![UserDefaults getState]){
        NSLog(@"Not logged in,presenting window");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"IntroScrollView"];
        loginVC.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:loginVC animated:YES completion:NULL];
    }
}


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
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    switch ([indexPath row]) {
        case 0:{
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            imgView.image = [UIImage imageNamed:@"lightbulb.png"];
            cell.imageView.image = imgView.image;
            cell.textLabel.text=@"IR Devices";
            cell.detailTextLabel.text=@"Add and remove your IR Devices here";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 1:{
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            imgView.image = [UIImage imageNamed:@"cog_01.png"];
            cell.imageView.image = imgView.image;
            cell.textLabel.text=@"Settings";
            cell.detailTextLabel.text=@"Configure your hardware settings here";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 2:{
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            imgView.image = [UIImage imageNamed:@"lock.png"];
            cell.imageView.image = imgView.image;
            cell.textLabel.text=@"Account";
            cell.detailTextLabel.text=@"Configure your account settings here";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            break;
        }
            
        default:
            break;
    }

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch ([indexPath row]) {
        case 0:{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"IRDeviceTable"];
            [self.navigationController pushViewController:loginVC animated:YES];
            [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
            break;
        }
        case 1:{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"SettingsController"];
            [self.navigationController pushViewController:loginVC animated:YES];
            [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
            break;
        }
        case 2:{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"AccountController"];
            [self.navigationController pushViewController:loginVC animated:YES];
            [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
            break;
        }

        default:
            break;
    }
}

-(void)animateImage{
    [UIView animateWithDuration:1
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [logoView setAlpha:1];
                     }
                     completion:^(BOOL finished){//this block starts only when
                     }];
}

- (void)viewDidLoad
{
    logoView.alpha=0;
    [self performSelector:@selector(animateImage) withObject:nil afterDelay:1];
    [self setNetworkLayer];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)setNetworkLayer{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    networkLayer = appDelegate.networkLayer;
    [networkLayer setDelegate:(id)self];
}

-(void)viewDidAppear:(BOOL)animated{
    [networkLayer setDelegate:(id)self];
    [UserDefaults setServerIP:[networkLayer getHostName]];
    [self performSelector:@selector(loadIntroViewIntroller) withObject:nil afterDelay:0.5];
    NSLog(@"%@",[UserDefaults getServerIP]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
