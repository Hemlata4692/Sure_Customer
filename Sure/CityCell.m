//
//  CityCell.m
//  Sure
//
//  Created by Hema on 24/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "CityCell.h"

@implementation CityCell
@synthesize myradio;
@synthesize cityLabel;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
      
    }
    return self;
}

#pragma mark - Radiobutton action

-(void) checkRadio
{
    [myradio setSelected:YES];
}

-(void) unCheckRadio
{
    [myradio setSelected:NO];
}

-(void) radioButtonTouched :(NSDictionary *)cityDict
{
    if(myradio.isSelected == YES)
    {
        
        return;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:cityDict forKey:@"City"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self checkRadio];
        [_delegate myRadioCellDelegateDidCheckRadioButton:self];
    }
}

#pragma mark - end
@end
