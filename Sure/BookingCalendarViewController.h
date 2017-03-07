//
//  BookingCalendarViewController.h
//  Sure
//
//  Created by Hema on 23/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackViewController.h"

@interface BookingCalendarViewController :BackViewController
@property(strong,nonatomic) NSString *dateString;
@property(strong, nonatomic) NSString *serviceProviderID;
@property(strong, nonatomic) NSString *serviceName;
@property(strong, nonatomic) NSString *serviceCharges;
@property(strong, nonatomic) NSString *serviceType;
@property(strong, nonatomic) NSString *serviceId;
@property(strong, nonatomic) NSString *serviceSlotHour;
@property(strong, nonatomic) NSString *advanceBookingHrs;
@property(strong, nonatomic) NSString *advanceBookingDays;
@end
