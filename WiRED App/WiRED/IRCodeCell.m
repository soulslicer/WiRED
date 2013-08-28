//
//  IRCodeCell.m
//  WiRED
//
//  Created by Yaadhav Raaj on 6/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "IRCodeCell.h"

@implementation IRCodeCell

+ (IRCodeCell *)cellFromNibNamed:(NSString *)nibName {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    IRCodeCell *irCodeCell = nil;
    NSObject* nibItem = nil;
    
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[IRCodeCell class]]) {
            irCodeCell = (IRCodeCell *)nibItem;
            break;
        }
    }
    return irCodeCell;
}

@end
