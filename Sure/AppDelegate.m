//
//  AppDelegate.m
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LoginViewController.h"
#import "GAI.h"
#import "HHAlertView.h"
#import "RequestDetailViewController.h"
#import "RatingViewController.h"
#import "SWRevealViewController.h"


@interface AppDelegate ()<HHAlertViewDelegate>

@end

@implementation AppDelegate
id<GAITracker> tracker;
@synthesize navigationController,locationManager;
@synthesize latitude,longitude;
@synthesize deviceToken;
@synthesize messageType,superClassView,pushCount,bookingId;

#pragma mark - Activity indicator
- (void) ShowIndicator
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.dimBackground=YES;
    hud.labelText=@"Loading...";
}

//Method for stop indicator
- (void)StopIndicator
{
    [MBProgressHUD hideHUDForView:self.window animated:YES];
}
#pragma mark - end

#pragma mark - Appdelegate methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 5;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-62313121-1"];
    [self getLatLong];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"header1.png"] forBarMetrics:UIBarMetricsDefault];
      //set navigation bar button color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Regular" size:18.0], NSFontAttributeName, nil]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.navigationController = (UINavigationController *)[self.window rootViewController];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]!=nil)
    {
        
        [self getCityFromServer];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.window setRootViewController:objReveal];
        [self.window setBackgroundColor:[UIColor whiteColor]];
        [self.window makeKeyAndVisible];
    }
    else
    {
        LoginViewController * objbusiness = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objbusiness]
                                             animated: YES];
    }
    
    //permission for local notification in iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    application.applicationIconBadgeNumber = 0;
    NSDictionary *remoteNotifiInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    //Accept push notification when app is not open
    if (remoteNotifiInfo)
    {
        [self application:application didReceiveRemoteNotification:remoteNotifiInfo];
    }
    
    UILocalNotification *localNotiInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey];
    
    //Accept local notification when app is not open
    if (localNotiInfo)
    {
        [self application:application didReceiveLocalNotification:localNotiInfo];
    }
    
    
    
    return YES;
}
-(void)getLatLong
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0 )
    {
        [locationManager requestAlwaysAuthorization];
        [locationManager requestWhenInUseAuthorization];
        
    }
    [locationManager startUpdatingLocation];
    CLLocation *location = [myDelegate.locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%f", coordinate.longitude] ;
    if ([latitude floatValue]==0.0 && [longitude floatValue]==0.0)
    {
        latitude=@"";
        longitude=@"";
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [self openActiveSessionWithPermissions:nil allowLoginUI:NO];
    }
    
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - end

#pragma mark - Push notification methods

-(void)registerDeviceForNotification
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}


-(NSString *)getNotificationMessage : (NSDictionary *)userInfo
{
    messageType =[[userInfo objectForKey:@"MessageType"]intValue];
    [[NSUserDefaults standardUserDefaults]setInteger:[[userInfo objectForKey:@"PendingConfirmation"]intValue] forKey:@"PendingConfirmation"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    bookingId =[userInfo objectForKey:@"BookingId"];
    NSDictionary *tempDict=[userInfo objectForKey:@"aps"];
    return [tempDict objectForKey:@"alert"];
}


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken1
{
    NSString *token = [[deviceToken1 description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.deviceToken = token;
    
    [[WebService sharedManager] registerDeviceForPushNotification:^(id responseObject) {
        
    } failure:^(NSError *error) {
        
    }] ;
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]!=nil)
    {
        [UIApplication sharedApplication].applicationIconBadgeNumber=0;
        [self getNotificationMessage:userInfo];
        if (application.applicationState == UIApplicationStateActive)
        {
            [[HHAlertView shared] setDelegate:self];
            [HHAlertView shared].tag = messageType;
            [HHAlertView showAlertWithStyle:HHAlertStyleWraning inView:self.window Title:@"Booking Response" detail:[self getNotificationMessage:userInfo] cancelButton:@"Cancel" Okbutton:@"Open"];
        }
        else
        {
        
            if(messageType==2)
            {
                superClassView = @"sureView";
            }
            else if( messageType==3)
            {
                superClassView = @"sureView";
            }
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SWRevealViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [self.window setRootViewController:objReveal];
            [self.window setBackgroundColor:[UIColor whiteColor]];
            [self.window makeKeyAndVisible];
        }
        
    }
    else
    {
        return;
    }
}


-(void)unregisterDeviceForNotification
{
    [[UIApplication sharedApplication]  unregisterForRemoteNotifications];
}
#pragma mark - end

#pragma mark - Get city method

-(void)getCityFromServer
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"City"]==nil||[[NSUserDefaults standardUserDefaults]objectForKey:@"City"]==NULL) {
        
        [[WebService sharedManager]getCitiesFromServer:^(id responseObject) {
            
            
            NSArray * cityArray = [responseObject objectForKey:@"CityList"];
            for (int i =0; i<cityArray.count; i++)
            {
                NSDictionary * tempDict =[cityArray objectAtIndex:i];
                if ([[[tempDict objectForKey:@"Name"] lowercaseString] isEqualToString:[NSString stringWithFormat:@"%@",[@"Singapore" lowercaseString]]])
                {
                    [[NSUserDefaults standardUserDefaults] setObject:tempDict forKey:@"City"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    break;
                }
            }
            
        } failure:^(NSError *error) {
            
        }] ;
    }
    
}
#pragma mark - end

#pragma mark - Change the date format
-(id)formatDateToDisplay : (id)dateString
{
    if ([dateString isKindOfClass:[NSDate class]])
    {
        NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [dateformate setLocale:locale];
        
        [dateformate setDateFormat:@"dd MMM YYYY"];
        
        NSString *dateStr=[dateformate stringFromDate:dateString];
        return dateStr;
        
    }
    else
    {
        NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [dateformate setLocale:locale];
        [dateformate setDateFormat:@"dd-MMMM-yyyy"];
        NSDate *date =[dateformate dateFromString:dateString];
        
        [dateformate setDateFormat:@"dd MMM YYYY"];
        
        NSString *dateStr=[dateformate stringFromDate:date];
        return dateStr;
    }
}
#pragma mark - end


#pragma mark - Facebbok delegates
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI
{
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      // Create a NSDictionary object and set the parameter values.
                                      NSDictionary *sessionStateInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                        session, @"session",
                                                                        [NSNumber numberWithInteger:status], @"state",
                                                                        error, @"error",
                                                                        nil];
                                      
                                      // Create a new notification, add the sessionStateInfo dictionary to it and post it.
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"SessionStateChangeNotification"
                                                                                          object:nil
                                                                                        userInfo:sessionStateInfo];
                                      
                                  }];
    
}
#pragma mark - end

#pragma mark - Custom notification alert methods

- (void)didClickButtonAnIndex:(HHAlertButton)button
{
    if (button == HHAlertButtonOk &&([HHAlertView shared].tag==2 || [HHAlertView shared].tag==3))
    {
        superClassView = @"backView";
        
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RequestDetailViewController *view1=[sb instantiateViewControllerWithIdentifier:@"RequestDetailViewController"];
        [self.currentNavigationController pushViewController:view1 animated:YES];
    }
   
}
#pragma mark - end

#pragma mark - Local notification
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([notification.userInfo valueForKey:@"BookingID"])
    {
        UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Did you enjoy the service? Come and rate the service provider!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open", nil];
        bookingId=[notification.userInfo valueForKey:@"BookingID"];
        notificationAlert.tag=1;
        [self dismiss:notificationAlert];
        
        [notificationAlert show];
    }
    
    [self cancelLocalNotification:notification];
    
}
-(void)dismiss:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1 && buttonIndex==1)
    {
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RatingViewController *view1=[sb instantiateViewControllerWithIdentifier:@"RatingViewController"];
        view1.bookingId=bookingId;
        [self.currentNavigationController pushViewController:view1 animated:YES];
    }
}

- (void)cancelLocalNotification:(UILocalNotification *)notification

{
    if ([notification.userInfo valueForKey:@"BookingID"] )
    {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}
#pragma mark - end

@end
