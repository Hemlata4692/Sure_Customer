//
//  BookingRequestController.h
//  CustomCalenderView
//
//  Created by Ranosys on 17/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackViewController.h"
#import "BookingCalenderDataModel.h"

@interface BookingRequestController : BackViewController
@property(strong, nonatomic) NSString *serviceNameStr;
@property(strong, nonatomic) NSString *serviceCharges;
@property(strong, nonatomic) NSString *serviceTypeStr;
@property(strong, nonatomic) NSString *serviceId;
@property(strong, nonatomic) NSString *serviceDate;
@property(strong, nonatomic) NSString *startTime;
@property(strong, nonatomic) NSString *endTime;
@property(strong, nonatomic) NSString *serviceProviderID;
@property (strong, nonatomic) BookingCalenderDataModel *calenderData;
@property double serviceSlotHrs;
@end
