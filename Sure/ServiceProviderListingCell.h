//
//  ServiceProviderListingCell.h
//  Sure
//
//  Created by Hema on 16/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASStarRatingView.h"
#import "RequestSentModel.h"
#import "ServiceListModel.h"

@interface ServiceProviderListingCell : UITableViewCell
{
    ServiceListModel *serviceListData;
}

@property (weak, nonatomic) IBOutlet UIImageView *serviceProviderImage;
@property (weak, nonatomic) IBOutlet UILabel *serviceProviderName;
@property (weak, nonatomic) IBOutlet UILabel *businessName;
@property (weak, nonatomic) IBOutlet UILabel *bookingLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstServiceName;
@property (weak, nonatomic) IBOutlet UILabel *secondServiceName;
@property (weak, nonatomic) IBOutlet UILabel *thirdServiceName;
@property (weak, nonatomic) IBOutlet UILabel *firstServiceCharge;
@property (weak, nonatomic) IBOutlet UILabel *secondServiceCharge;
@property (weak, nonatomic) IBOutlet UILabel *thirdServiceCharge;
@property (weak, nonatomic) IBOutlet UIView *serviceBackView;
@property (weak, nonatomic) IBOutlet ASStarRatingView *staticStarRatingView;
@property (weak, nonatomic) IBOutlet UIImageView *secondTick;
@property (weak, nonatomic) IBOutlet UIImageView *thirdTick;
@property (weak, nonatomic) IBOutlet UILabel *separator;
@property (weak, nonatomic) IBOutlet UIImageView *firstTick;
-(void)displaySpListData :(RequestSentModel *)spListData :(int)indexPath viewSize:(CGRect)viewSize;
@end
