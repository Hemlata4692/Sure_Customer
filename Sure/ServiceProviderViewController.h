//
//  ServiceProviderViewController.h
//  Sure
//
//  Created by Hema on 16/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BackViewController.h"

@interface ServiceProviderViewController : BackViewController
@property(strong,nonatomic) NSString * subCatServiceID;
@property(strong,nonatomic) NSString * searchKey;
@property(strong,nonatomic) NSString * customLocation;
//@property double latitude;
//@property double longitude;
@property(strong,nonatomic) NSString * latitude;
@property(strong,nonatomic) NSString * longitude;
@end
