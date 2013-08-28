//
//  IRCodeCellMain.m
//  WiRED
//
//  Created by Yaadhav Raaj on 6/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "IRCodeCellMain.h"

@implementation IRCodeCellMain

@synthesize title,sendButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(IBAction)sendButtonHit:(id)sender{
    NSLog(@"Send hit");
}

-(NSString *) reuseIdentifier {
    return @"IRCodeCellMainReuseIdentifier";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
