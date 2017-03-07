//
//  RequestDetailViewController.h
//  Sure
//
//  Created by Hema on 24/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackViewController.h"
#import "RequestSentModel.h"
#import "ServiceListModel.h"

@interface RequestDetailViewController : BackViewController
@property(strong, nonatomic) RequestSentModel *sectionData;
@property(strong, nonatomic) ServiceListModel *tableData;
@property int selectedIndex;
@property(strong, nonatomic) NSString *status;
@property(strong, nonatomic) NSString *pushBookingID;
@end
