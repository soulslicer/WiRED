//
//  FirstViewController.h
//  WiRED
//
//  Created by Yaadhav Raaj on 3/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkLayer.h"

@interface HomeViewController : UIViewController{
    NetworkLayer* networkLayer;
}

@property(nonatomic,strong)IBOutlet UITableView* table;
@property(nonatomic,strong)IBOutlet UIImageView* logoView;

@end
