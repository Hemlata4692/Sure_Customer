//
//  CityCell.h
//  Sure
//
//  Created by Sumit on 24/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyButton.h"
@class CityCell;
@protocol RadioCellDelegate <NSObject>
-(void) myRadioCellDelegateDidCheckRadioButton:(CityCell *)checkedCell;
@end

@interface CityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIButton *myradio;
-(void) unCheckRadio;
-(void) radioButtonTouched :(NSDictionary *)cityDict;
@property (nonatomic, weak) id <RadioCellDelegate> delegate;
@end
