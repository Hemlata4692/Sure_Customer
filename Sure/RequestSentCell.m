//
//  RequestSentCell.m
//  Sure
//
//  Created by Hema on 23/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "RequestSentCell.h"

@implementation RequestSentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Setframes of objects
-(void)layoutView : (CGRect )rect
{
    self.checkImage.translatesAutoresizingMaskIntoConstraints=YES;
    self.ServiceName.translatesAutoresizingMaskIntoConstraints=YES;
    self.ServiceCharge.translatesAutoresizingMaskIntoConstraints=YES;
    self.innerView.translatesAutoresizingMaskIntoConstraints=YES;
    self.separator.translatesAutoresizingMaskIntoConstraints=YES;
    self.bottomView.translatesAutoresizingMaskIntoConstraints=YES;
    self.cellButton.translatesAutoresizingMaskIntoConstraints=YES;
    self.detailArrow.translatesAutoresizingMaskIntoConstraints=YES;
    self.seperatorLabel.translatesAutoresizingMaskIntoConstraints=YES;
    
    self.innerView.frame =CGRectMake(5, 0, rect.size.width-10, self.innerView.frame.size.height);
    self.seperatorLabel.frame =CGRectMake(0, 4, rect.size.width-10, 1);
    self.checkImage.frame =CGRectMake(7, 12, 13, 13);
    self.detailArrow.frame =CGRectMake(self.innerView.frame.size.width-20, 12, 13, 13);
    self.ServiceCharge.frame =CGRectMake(self.innerView.frame.size.width-125, 8, self.ServiceCharge.frame.size.width, self.ServiceCharge.frame.size.height);
    self.ServiceName.frame =CGRectMake(25, 8, self.ServiceName.frame.size.width, 21);
    self.separator.frame =CGRectMake(0, 13, rect.size.width, 1);
    self.bottomView.frame =CGRectMake(5, 0, rect.size.width-10, 7);
    self.cellButton.frame =CGRectMake(0, 0, rect.size.width-26, 30);
    
}
#pragma mark - end

@end
