//
//  ServiceListModel.h
//  Sure
//
//  Created by Sumit on 01/05/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceListModel : NSObject
@property(nonatomic,retain)NSString * bookingId;
@property(nonatomic,retain)NSString * serviceName;
@property(nonatomic,retain)NSString * serviceCharge;
@property(nonatomic,retain)NSString * serviceType;
@property(nonatomic,retain)NSString * startTime;
@property(nonatomic,retain)NSString * endTime;
@property(nonatomic,retain)NSString * bookingDate;
@end
