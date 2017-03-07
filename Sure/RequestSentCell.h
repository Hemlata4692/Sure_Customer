//
//  RequestSentCell.h
//  Sure
//
//  Created by Hema on 23/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyButton.h"

@interface RequestSentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *checkImage;
@property (weak, nonatomic) IBOutlet UILabel *ServiceName;
@property (weak, nonatomic) IBOutlet UILabel *ServiceCharge;
@property (weak, nonatomic) IBOutlet UIView *innerView;

@property (weak, nonatomic) IBOutlet UILabel *separator;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet MyButton *cellButton;
@property (weak, nonatomic) IBOutlet UIImageView *detailArrow;
@property (weak, nonatomic) IBOutlet UILabel *seperatorLabel;

-(void)layoutView : (CGRect )rect;

@end
