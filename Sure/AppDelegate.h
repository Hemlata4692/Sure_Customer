//
//  AppDelegate.h
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,retain) UINavigationController *navigationController;
@property(nonatomic,retain) UINavigationController *currentNavigationController;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property(nonatomic,strong) NSString *latitude;
@property(nonatomic,strong) NSString *longitude;
@property(nonatomic,retain)NSString * deviceToken;

@property(nonatomic,assign)int messageType;
@property(nonatomic,strong) NSString *superClassView;
@property(nonatomic,strong) NSString *bookingId;
@property(nonatomic,assign)int pushCount;

-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI;


// Methos for show indicator
- (void) ShowIndicator;
-(void)getLatLong;
//Method for stop indicator
- (void)StopIndicator;
-(void)getCityFromServer;
-(id)formatDateToDisplay : (id)dateString;
-(void)unregisterDeviceForNotification;
-(void)registerDeviceForNotification;
@end

