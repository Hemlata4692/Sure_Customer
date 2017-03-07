//
//  UIButton+ButtonBorder.m
//  Sure
//
//  Created by Hema on 16/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "UIButton+ButtonBorder.h"

@implementation UIButton (ButtonBorder)

-(void)addBorder: (UIButton *)button
{
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height - 1.0f, button.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0f];
    
    UIView *rightBorder = [[UIView alloc] initWithFrame:CGRectMake(button.frame.size.width-1.0f, 0, 1, button.frame.size.height)];
    rightBorder.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0f];
    
    [button addSubview:bottomBorder];
    [button addSubview:rightBorder];
}

-(void) addBottomBorder: (UIButton *)button
{
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height - 1.0f, button.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0f];
    [button addSubview:bottomBorder];
}

-(void)changeBorderColor: (UIButton *)button
{
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height - 1.0f, button.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0f];
    
    [button addSubview:bottomBorder];

}

@end
