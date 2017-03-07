//
//  RequestSentModel.h
//  Sure
//
//  Created by Sumit on 01/05/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestSentModel : NSObject

@property(nonatomic,retain)NSString * bookingCount;
@property(nonatomic,retain)NSString * rating;
@property(nonatomic,retain)NSString * name;
@property(nonatomic,retain)NSString * businessName;
@property(nonatomic,retain)NSString * profileImage;
@property(nonatomic,retain)NSString * serviceProviderId;
@property(nonatomic,retain)NSString * inShop;
@property(nonatomic,retain)NSString * onSite;
@property(nonatomic,retain)NSString * latitude;
@property(nonatomic,retain)NSString * longitude;
@property(nonatomic,retain)NSMutableArray * serviceList;
@property(nonatomic,retain)NSString * message;

@end
