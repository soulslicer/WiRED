//
//  IRCodeCellMain.h
//  WiRED
//
//  Created by Yaadhav Raaj on 6/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "IRCodeCell.h"

@interface IRCodeCellMain : IRCodeCell

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;

-(IBAction)sendButtonHit:(id)sender;
-(NSString *) reuseIdentifier;

@end
