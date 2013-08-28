//
//  IntroScrollViewController.h
//  WiRED
//
//  Created by Yaadhav Raaj on 4/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntroViewController.h"

@interface IntroScrollViewController : UIViewController

@property(nonatomic,strong)IBOutlet UIScrollView* scrollView;
@property(nonatomic,strong)IntroViewController* introViewController;

-(void)goToPage:(int)page;

@end
