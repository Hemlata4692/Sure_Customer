//
//  ServiceDataModel.h
//  Sure_sp
//
//  Created by Sumit on 27/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceDataModel : NSObject
@property(nonatomic,retain)NSString * name;
@property(nonatomic,retain)NSString * serviceCharges;
@property(nonatomic,retain)NSString * serviceDescription;
@property(nonatomic,retain)NSString * serviceType;
@property(nonatomic,retain)NSString * serviceId;
@property(nonatomic,retain)NSString *  serviceSlotHrs;
@property(nonatomic,retain)NSArray *  serviceImages;
@property(nonatomic,retain)NSString * advanceBookingDays;
@property(nonatomic,retain)NSString * advanceBookingHours;

@end


