//
//  WebService.h
//  Sure_sp
//
//  Created by Sumit on 30/03/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "CryptLib.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

//testing link
//#define BASE_URL                              @"http://52.74.144.192/sureappsvc/Sure.svc"

//client delivery link
#define BASE_URL                                @"http://52.74.126.34/sureappsvcbeta/Sure.svc"

//QA testing link
//#define BASE_URL                              @"http://52.74.144.192/sureappsvcqa/Sure.svc"

//Live app link
//#define BASE_URL                                @"http://54.169.111.150/suresvc/Sure.svc"

@class ProfileDataModel;
@class SearchDataModel;
@class BusinessProfileDataModel;
@class ServiceDataModel;

@interface WebService : NSObject

@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
+ (id)sharedManager;

//Login screen methods
-(void)registerUser:(NSString *)mailId password:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSError *))failure;
-(void)userLoginFb:(NSString *)mailId success:(void (^)(id))success failure:(void (^)(NSError *))failure;
- (void)userLogin:(NSString *)email andPassword:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//data encryption/decryption method
-(NSString *)encryptionField:(NSString *)string;

-(NSString *)decryptionField:(NSString *)string;
//end


//home screen
-(void)getBannerImages:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

-(void)getCategoryList:(NSString *)offset success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//sub category method
-(void)getSubCategoryList:(NSString *)categoryId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

// my profile methods
-(void)getProfileData:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
-(void)myProfile:(NSString *)name contactNo:(NSString *)contactNo address:(NSString *)address success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Get city
-(void)getCitiesFromServer:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Get Business Profile
-(void)getBusinessProfile:(NSString *)serviceProviderId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Get Comments
-(void)getCommentData:(NSString *)serviceProviderId offset:(NSString *)offset success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Request sent list method
-(void)requestSentList:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

-(void)cancelBooking:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

-(void)conFirmBooking:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end


//Get SpList
-(void)getSpList:(NSString *)subCatId searchKey:(NSString *)searchKey highestRating:(NSString *)highestRating mostBooking:(NSString *)mostBooking date:(NSString *)date startTime:(NSString *)startTime endTime:(NSString *)endTime latitude:(NSString *)latitude longitude:(NSString *)longitude city:(NSString *)city success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Get Calender
-(void)getSpCalender:(NSString *)serviceProviderId date:(NSString *)date success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end


//Booking Request
-(void)bookingRequest:(NSString *)serviceID customerName:(NSString *)customerName customerContact:(NSString *)customerContact bookingDate:(NSString *)bookingDate remarks:(NSString *)remarks address:(NSString *)address startTime:(NSString *)startTime endTime:(NSString *)endTime spUserId:(NSString *)spUserId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Pending confirmation
-(void)pendingConfirmation:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//My Calander
-(void)getCustomerCalnder:(NSString *)date success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Customer rating and feedback
-(void)getCustomerFeedback:(NSString *)serviceProviderId rating:(NSString *)rating comment:(NSString *)comment bookingId:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

-(void)getSpForRating:(NSString *)serviceProviderId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Device registration method for push notification
-(void)registerDeviceForPushNotification:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Booking Response
-(void)bookingResponse:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end
@end
