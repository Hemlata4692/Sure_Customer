//
//  SubCategoryViewController.h
//  Sure
//
//  Created by Hema on 27/03/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackViewController.h"

@interface SubCategoryViewController : BackViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,retain)NSString * mainCategoryId;
@property(nonatomic,retain)NSString * mainCategoryName;
@end
