//
//  WebService.m
//  Sure_sp
//
//  Created by Sumit on 30/03/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "WebService.h"
#import "NSData+Base64.h"
#import "SearchDataModel.h"
#import "ProfileDataModel.h"
#import "BusinessProfileDataModel.h"
#import "ServiceDataModel.h"
#import "NullValueChecker.h"
#import "ServiceListModel.h"
#import "RequestSentModel.h"
#import "BookingCalenderDataModel.h"
#import "MyCalenderDataModel.h"
#import "BookingDetailDataModel.h"


#define kUrlLogin                       @"Login"
#define kUrlSignup                      @"Register"
#define kUrlFbLogin                     @"FbLogin"

#define kUrlGetBannersList              @"GetBannersList"
#define kUrlGetCategoryList             @"GetCategoryList"
#define kUrlGetSubCategoryList          @"GetSubCategoryList"

#define kUrlGetMyProfile                @"GetMyProfile"
#define kUrlMyProfile                   @"MyProfile"

#define kUrlGetCities                   @"GetCities"

#define kUrlBusinessProfile             @"GetBusinessProfile"
#define kUrlComments                    @"GetComments"

#define kUrlGetSpListing                @"GetSPListingForCustomer"

#define kUrlSpCalender                  @"GetSPCalenderForCustomer"
#define kUrlBookingRequestSent          @"GetSPListPendingConfirmation"
#define kUrlCancelBooking               @"CancelBookingByCustomer"
#define kUrlConfirmBooking              @"ConfirmBookingByCustomer"

#define kUrlBookingRequest              @"AddBooking"
#define kUrlBookingResponse             @"BookingResponse"

#define kUrlPendingConfirmationList     @"PendingConfirmationListOfCustomer"
#define kUrlCustomerCalender            @"GetCustomerCalendar"

#define kUrlGetSPForRating              @"GetSPForRating"
#define kUrlGetCustomerFeedback         @"CustomerFeedback"

#define kUrlDeleteBooking               @"DeleteBooking"

#define kUrlRegisterDevice              @"RegisterDevice"



@implementation WebService
@synthesize manager;

#pragma mark - AFNetworking method
+ (id)sharedManager
{
    static WebService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
- (id)init
{
    if (self = [super init])
    {
        manager = [[AFHTTPRequestOperationManager manager] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    }
    return self;
}

- (void)post:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"parse-application-id-removed" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [manager.requestSerializer setValue:@"parse-rest-api-key-removed" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    [manager POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myDelegate StopIndicator];
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myDelegate StopIndicator];
        failure(error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }];
    
}

- (BOOL)isStatusOK:(id)responseObject {
    NSNumber *number = responseObject[@"IsSuccess"];
    
    switch (number.integerValue) {
        case 1:
            return YES;
            break;
        case 0: {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:responseObject[@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }
            return NO;
            break;
        default: {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:responseObject[@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }
            return NO;
            break;
    }
}
#pragma mark - end
#pragma mark - AES encryption
-(NSString *)encryptionField:(NSString *)string
{
    
    StringEncryption *EncObj=[[StringEncryption alloc]init];
    
    NSString * encryptionKey= @"my secret key";    // key = [[StringEncryption alloc] sha256:key length:32];
    NSString* key1=[EncObj sha256:encryptionKey length:32];
    NSString * iv1 = @"263a2e31f23bbaaa";
    NSData* plainText = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData* encData= [EncObj encrypt:plainText key:key1 iv:iv1];
    NSString * encryptedString= [NSString stringWithFormat:@"%@",[encData  base64EncodingWithLineLength:0] ];
    return encryptedString;
    
}
#pragma mark - end
#pragma mark - AES decryption
-(NSString *)decryptionField:(NSString *)string
{
    StringEncryption *decObj=[[StringEncryption alloc]init];
    
    NSString * decryptionKey= @"my secret key";    // key = [[StringEncryption alloc] sha256:key length:32];
    NSString* key1=[decObj sha256:decryptionKey length:32];
    NSString * iv1 = @"263a2e31f23bbaaa";
    NSData* encryptedText = [[NSData alloc] initWithBase64EncodedString:string options:0];
    encryptedText= [decObj decrypt:encryptedText key:key1 iv:iv1];
    NSString * decryptedString= [[NSString alloc] initWithData:encryptedText encoding:NSUTF8StringEncoding];
    return decryptedString;
    
}

#pragma mark - end

#pragma mark- Login module methods
//Login
- (void)userLogin:(NSString *)email andPassword:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    password= [self encryptionField:password];
    NSDictionary *requestDict = @{ @"Username" : email,@"Password" : password,@"Role":@"Customer"};
    
    [self post:kUrlLogin parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         
         if([self isStatusOK:responseObject])
         {
             
             
             success(responseObject);
         } else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

//Register
-(void)registerUser:(NSString *)mailId password:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    password= [self encryptionField:password];
    
    NSDictionary *requestDict = @{ @"Email" : mailId,@"Password" : password,@"Role":@"Customer"};
    
    [self post:kUrlSignup parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject])
        {
            
            
            success(responseObject);
        } else
        {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

//Facebook login
-(void)userLoginFb:(NSString *)mailId success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    NSDictionary *requestDict = @{ @"Email" : mailId,@"Role":@"Customer"};
    [self post:kUrlFbLogin parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject])
        {
            
            success(responseObject);
        } else {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
    
}

#pragma mark - end

#pragma mark - Home Search screen
-(void)getBannerImages:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    [self post:kUrlGetBannersList parameters:requestDict success:^(id responseObject) {
        
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            success(responseObject);
        } else
        {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];;
    
}

-(void)getCategoryList:(NSString *)offset success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"OffSet":offset};
    [self post:kUrlGetCategoryList parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             
             NSMutableArray *CategoryListingArray=[[NSMutableArray alloc]init];
             NSArray * tempAry = [responseObject objectForKey:@"CategoryList"];
             
             for (int i =0; i<tempAry.count; i++)
             {
                 SearchDataModel *searchModel=[[SearchDataModel alloc]init];
                 
                 NSDictionary * tempDict = [tempAry objectAtIndex:i];
                 searchModel.categoryId=[tempDict objectForKey:@"Id"];
                 searchModel.categoryImage=[tempDict objectForKey:@"CategoryImage"];
                 searchModel.categoryName=[tempDict objectForKey:@"Name"];
                 
                 [CategoryListingArray addObject:searchModel];
             }
             [CategoryListingArray addObject:[responseObject objectForKey:@"TotalRecords"]];
             success(CategoryListingArray);
         } else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];;
    
}

#pragma mark - end

#pragma mark - Subcategory List
-(void)getSubCategoryList:(NSString *)categoryId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"ParentId":categoryId};
    [self post:kUrlGetSubCategoryList parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             
             
             NSMutableArray *subCategoryArray=[[NSMutableArray alloc]init];
             NSArray * tempAry = [responseObject objectForKey:@"CategoryList"];
             for (int i =0; i<tempAry.count; i++)
             {
                 SearchDataModel *subCategoryData=[[SearchDataModel alloc]init];
                 NSDictionary * tempDict = [tempAry objectAtIndex:i];
                 subCategoryData.categoryId=[tempDict objectForKey:@"Id"];
                 subCategoryData.categoryName=[tempDict objectForKey:@"Name"];
                 [subCategoryArray addObject:subCategoryData];
             }
             success(subCategoryArray);
         }
         else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];;
    
}

#pragma mark - end

#pragma mark - My Profile
-(void)getProfileData:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    [self post:kUrlGetMyProfile parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             
             NSMutableArray *getProfileData=[[NSMutableArray alloc]init];
             
             ProfileDataModel *myProfileModel=[[ProfileDataModel alloc]init];
             
             myProfileModel.Name=[responseObject objectForKey:@"Name"];
             myProfileModel.Address=[self decryptionField:[responseObject objectForKey:@"Address"]];
             myProfileModel.PhoneNo=[self decryptionField:[responseObject objectForKey:@"ContactNo"]];
             myProfileModel.Email=[responseObject objectForKey:@"Email"];
             [getProfileData addObject:myProfileModel];
             
             
             success(getProfileData);
         } else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];;
    
}


-(void)myProfile:(NSString *)name contactNo:(NSString *)contactNo address:(NSString *)address success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"Name":name, @"ContactNo":[self encryptionField:contactNo], @"Address":[self encryptionField:address]};
    [self post:kUrlMyProfile parameters:requestDict success:^(id responseObject) {
        
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            
            success(responseObject);
        } else {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];;
    
}
#pragma mark - end

#pragma mark - Get city method
-(void)getCitiesFromServer:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    [self post:kUrlGetCities parameters:requestDict success:^(id responseObject) {
        
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            
            success(responseObject);
        } else {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        [myDelegate StopIndicator];
        failure(error);
    }];
    
    
}
#pragma mark - end


#pragma mark - Business Profile Methods
-(void)getBusinessProfile:(NSString *)serviceProviderId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"ServiceProviderId":serviceProviderId};
    [self post:kUrlBusinessProfile parameters:requestDict success:^(id responseObject) {
        
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject])
        {
            NSMutableDictionary * dataDict = [NSMutableDictionary new];
            BusinessProfileDataModel *profileModel = [[BusinessProfileDataModel alloc]init];
            profileModel.serviceDataArray = [[NSMutableArray alloc]init];
            profileModel.address = [responseObject objectForKey:@"Address"];
            profileModel.bookings = [responseObject objectForKey:@"Bookings"];
            profileModel.businessDescription = [responseObject objectForKey:@"BusinessDescription"];
            profileModel.businessName = [responseObject objectForKey:@"BusinessName"];
            profileModel.contact = [responseObject objectForKey:@"Contact"];
            profileModel.latitude = [responseObject objectForKey:@"Latitude"];
            profileModel.longitude = [responseObject objectForKey:@"Longitude"];
            profileModel.name = [responseObject objectForKey:@"Name"];
            profileModel.overallRating = [responseObject objectForKey:@"OverallRating"];
            profileModel.pinCode = [responseObject objectForKey:@"PinCode"];
            profileModel.profileImage = [responseObject objectForKey:@"ProfileImage"];
            profileModel.comments = [responseObject objectForKey:@"Comments"];
            profileModel.inShop =[responseObject objectForKey:@"InShop"];
            profileModel.userId=[responseObject objectForKey:@"UserId"];
            
            [dataDict setObject:profileModel forKey:@"BusinessData"];
            NSArray * tmpAry = [responseObject objectForKey:@"ServiceResponse"];
            for (int i = 0; i<tmpAry.count; i++)
            {
                NSDictionary * tmpServiceDict = [tmpAry objectAtIndex:i];
                ServiceDataModel * serviceModel = [[ServiceDataModel alloc]init];
                serviceModel.name = [tmpServiceDict objectForKey:@"Name"];
                serviceModel.serviceCharges = [tmpServiceDict objectForKey:@"ServiceCharges"];
                serviceModel.serviceDescription = [tmpServiceDict objectForKey:@"ServiceDescription"];
                serviceModel.serviceType = [tmpServiceDict objectForKey:@"ServiceType"];
                serviceModel.serviceImages = [tmpServiceDict objectForKey:@"ServiceImages"];
                serviceModel.serviceId=[tmpServiceDict objectForKey:@"ServiceId"];
                serviceModel.serviceSlotHrs=[tmpServiceDict objectForKey:@"SlotDurationHrs"];
                serviceModel.advanceBookingHours  =[tmpServiceDict objectForKey:@"BookBeforeHrs"];
                serviceModel.advanceBookingDays =[tmpServiceDict objectForKey:@"DaysAdvanceBooking"];
                [profileModel.serviceDataArray addObject:serviceModel];
            }
            [dataDict setObject:profileModel forKey:@"BusinessProfileData"];
            
            success(dataDict);
        } else {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        [myDelegate StopIndicator];
        failure(error);
    }];
    
}

#pragma mark - end

#pragma mark - Comments List
-(void)getCommentData:(NSString *)serviceProviderId offset:(NSString *)offset success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"ServiceProviderId":serviceProviderId, @"Offset":offset};
    [self post:kUrlComments parameters:requestDict success:^(id responseObject)
     {
         
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             
             success(responseObject);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
         failure(error);
     }];;
    
}

#pragma mark - end

#pragma mark - Service provider listing

-(void)getSpList:(NSString *)subCatId searchKey:(NSString *)searchKey highestRating:(NSString *)highestRating mostBooking:(NSString *)mostBooking date:(NSString *)date startTime:(NSString *)startTime endTime:(NSString *)endTime latitude:(NSString *)latitude longitude:(NSString *)longitude city:(NSString *)city success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{@"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"SubCatId":subCatId, @"SearchKey":searchKey, @"Date":date, @"HighestRating":highestRating, @"MostBooking":mostBooking, @"StartTime":startTime, @"EndTime":endTime, @"Latitude":latitude, @"Longitude":longitude, @"City":city};
    [self post:kUrlGetSpListing parameters:requestDict success:^(id responseObject)
     {
         
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             id array =[responseObject objectForKey:@"SPList"];
             if (([array isKindOfClass:[NSArray class]]))
             {
                 NSArray * SpListArray = [responseObject objectForKey:@"SPList"];
                 NSMutableArray *dataArray = [NSMutableArray new];
                 
                 
                 for (int i =0; i<SpListArray.count; i++)
                 {
                     RequestSentModel *objSpList = [[RequestSentModel alloc]init];
                     NSDictionary * spListDict =[SpListArray objectAtIndex:i];
                     objSpList.serviceList = [[NSMutableArray alloc]init];
                     objSpList.bookingCount =[spListDict objectForKey:@"BookingCount"];
                     objSpList.businessName =[spListDict objectForKey:@"BusinessName"];
                     objSpList.name =[spListDict objectForKey:@"Name"];
                     objSpList.profileImage=[spListDict objectForKey:@"ProfileImage"];
                     objSpList.rating =[spListDict objectForKey:@"Rating"];
                     objSpList.serviceProviderId=[spListDict objectForKey:@"SpUserId"];
                     objSpList.inShop = [spListDict objectForKey:@"InShop"];
                     objSpList.onSite = [spListDict objectForKey:@"OnSite"];
                     objSpList.latitude = [spListDict objectForKey:@"Latitude"];
                     objSpList.longitude = [spListDict objectForKey:@"Longitude"];
                     
                     NSArray *serviceArray=[spListDict objectForKey:@"ServiceList"];
                     for (int j =0; j<serviceArray.count; j++)
                     {
                         NSDictionary * serviceDict =[serviceArray objectAtIndex:j];
                         ServiceListModel * objServiceList = [[ServiceListModel alloc]init];
                         objServiceList.bookingId = [serviceDict objectForKey:@"BookingId"];
                         objServiceList.serviceName =[serviceDict objectForKey:@"Name"];
                         objServiceList.serviceCharge=[serviceDict objectForKey:@"ServiceCharges"];
                         
                         [objSpList.serviceList addObject:objServiceList];
                         
                     }
                     [dataArray addObject:objSpList];
                 }
                 success(dataArray);
             }
             else
             {
                 RequestSentModel *objSpList = [[RequestSentModel alloc]init];
                 objSpList.message =[responseObject objectForKey:@"Message"];
                 success(objSpList);
             }
             
             
             
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

#pragma mark - end

#pragma mark - Request sent
-(void)requestSentList:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    [self post:kUrlBookingRequestSent parameters:requestDict success:^(id responseObject) {
        
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        
        if([self isStatusOK:responseObject])
        {
            id array =[responseObject objectForKey:@"SPList"];
            if (([array isKindOfClass:[NSArray class]]))
            {
                NSArray * SpArray = [responseObject objectForKey:@"SPList"];
                NSMutableArray *dataArray = [NSMutableArray new];
                
                
                for (int i =0; i<SpArray.count; i++)
                {
                    RequestSentModel *objReqSent = [[RequestSentModel alloc]init];
                    NSDictionary * ReqSent =[SpArray objectAtIndex:i];
                    objReqSent.serviceList = [[NSMutableArray alloc]init];
                    objReqSent.bookingCount =[ReqSent objectForKey:@"BookingCount"];
                    objReqSent.businessName =[ReqSent objectForKey:@"BusinessName"];
                    objReqSent.name =[ReqSent objectForKey:@"Name"];
                    objReqSent.profileImage=[ReqSent objectForKey:@"ProfileImage"];
                    objReqSent.rating =[ReqSent objectForKey:@"Rating"];
                    objReqSent.serviceProviderId=[ReqSent objectForKey:@"SpUserId"];
                    
                    NSArray *serviceArray=[ReqSent objectForKey:@"ServiceList"];
                    for (int j =0; j<serviceArray.count; j++)
                    {
                        NSDictionary * serviceDict =[serviceArray objectAtIndex:j];
                        ServiceListModel * objServiceList = [[ServiceListModel alloc]init];
                        objServiceList.bookingId = [serviceDict objectForKey:@"BookingId"];
                        objServiceList.serviceName =[serviceDict objectForKey:@"Name"];
                        objServiceList.serviceCharge=[serviceDict objectForKey:@"ServiceCharges"];
                        objServiceList.serviceType =[serviceDict objectForKey:@"ServiceType"];
                        objServiceList.startTime =[serviceDict objectForKey:@"StartTime"];
                        objServiceList.endTime =[serviceDict objectForKey:@"EndTime"];
                        objServiceList.bookingDate = [serviceDict objectForKey:@"BookingDate"];
                        [objReqSent.serviceList addObject:objServiceList];
                        
                    }
                    [dataArray addObject:objReqSent];
                }
                success(dataArray);
            }
            else
            {
                RequestSentModel *objSpList = [[RequestSentModel alloc]init];
                objSpList.message =[responseObject objectForKey:@"Message"];
                success(objSpList);
            }
            
            
        } else {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        [myDelegate StopIndicator];
        failure(error);
    }];
}

//Cancel Booking
-(void)cancelBooking:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"BookingId":bookingId};
    
    [self post:kUrlCancelBooking parameters:requestDict success:^(id responseObject)
     {
         
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             
             success(responseObject);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

-(void)conFirmBooking:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"BookingId":bookingId};
    
    [self post:kUrlConfirmBooking parameters:requestDict success:^(id responseObject)
     {
         
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             
             success(responseObject);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}
#pragma mark - end

#pragma mark - SpCalender
-(void)getSpCalender:(NSString *)serviceProviderId date:(NSString *)date success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"SPUserId":serviceProviderId, @"Date":date};
    
    [self post:kUrlSpCalender parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             BookingCalenderDataModel *spCalenderModel = [[BookingCalenderDataModel alloc]init];
             spCalenderModel.bookingsList = [responseObject objectForKey:@"BookingsList"];
             spCalenderModel.businessStartHours = [responseObject objectForKey:@"BusinessStartHours"];
             spCalenderModel.businessEndHours = [responseObject objectForKey:@"BusinessEndHours"];
             
             success(spCalenderModel);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}
#pragma mark - end

#pragma mark - Booking Request

-(void)bookingRequest:(NSString *)serviceID customerName:(NSString *)customerName customerContact:(NSString *)customerContact bookingDate:(NSString *)bookingDate remarks:(NSString *)remarks address:(NSString *)address startTime:(NSString *)startTime endTime:(NSString *)endTime spUserId:(NSString *)spUserId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{@"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"ServiceId":serviceID, @"CustomerName":customerName, @"CustomerContact":customerContact, @"BookingDate":bookingDate, @"CustomerAddress":address, @"Remarks":remarks, @"StartTime":startTime, @"EndTime":endTime, @"SPUserId":spUserId };
    [self post:kUrlBookingRequest parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             
             success(responseObject);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

#pragma mark - end

#pragma mark - Pending confirmation list
-(void)pendingConfirmation:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    [self post:kUrlPendingConfirmationList parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         
         if([self isStatusOK:responseObject])
         {
             id array =[responseObject objectForKey:@"SPList"];
             if (([array isKindOfClass:[NSArray class]]))
             {
                 NSArray * SpArray = [responseObject objectForKey:@"SPList"];
                 NSMutableArray *dataArray = [NSMutableArray new];
                 
                 
                 for (int i =0; i<SpArray.count; i++)
                 {
                     RequestSentModel *objReqSent = [[RequestSentModel alloc]init];
                     NSDictionary * ReqSent =[SpArray objectAtIndex:i];
                     objReqSent.serviceList = [[NSMutableArray alloc]init];
                     objReqSent.bookingCount =[ReqSent objectForKey:@"BookingCount"];
                     objReqSent.businessName =[ReqSent objectForKey:@"BusinessName"];
                     objReqSent.name =[ReqSent objectForKey:@"Name"];
                     objReqSent.profileImage=[ReqSent objectForKey:@"ProfileImage"];
                     objReqSent.rating =[ReqSent objectForKey:@"Rating"];
                     objReqSent.serviceProviderId=[ReqSent objectForKey:@"SpUserId"];
                     
                     NSArray *serviceArray=[ReqSent objectForKey:@"ServiceList"];
                     for (int j =0; j<serviceArray.count; j++)
                     {
                         NSDictionary * serviceDict =[serviceArray objectAtIndex:j];
                         ServiceListModel * objServiceList = [[ServiceListModel alloc]init];
                         objServiceList.bookingId = [serviceDict objectForKey:@"BookingId"];
                         objServiceList.serviceName =[serviceDict objectForKey:@"Name"];
                         objServiceList.serviceCharge=[serviceDict objectForKey:@"ServiceCharges"];
                         objServiceList.serviceType =[serviceDict objectForKey:@"ServiceType"];
                         objServiceList.startTime =[serviceDict objectForKey:@"StartTime"];
                         objServiceList.endTime =[serviceDict objectForKey:@"EndTime"];
                         objServiceList.bookingDate = [serviceDict objectForKey:@"BookingDate"];
                         [objReqSent.serviceList addObject:objServiceList];
                         
                     }
                     [dataArray addObject:objReqSent];
                 }
                 success(dataArray);
             }
             else
             {
                 RequestSentModel *objSpList = [[RequestSentModel alloc]init];
                 objSpList.message =[responseObject objectForKey:@"Message"];
                 success(objSpList);
             }
             
             
         } else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
         
     }
       failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
    
}
#pragma mark - end

#pragma mark - Customer calender
-(void)getCustomerCalnder:(NSString *)date success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"Date":date};
    
    [self post:kUrlCustomerCalender parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             MyCalenderDataModel *customerCalender = [[MyCalenderDataModel alloc]init];
             customerCalender.serviceList = [responseObject objectForKey:@"ServiceList"];
             
             success(customerCalender);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}
#pragma mark - end

#pragma mark - Comments and Rating

-(void)getSpForRating:(NSString *)serviceProviderId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"SPUserId":serviceProviderId};
    
    [self post:kUrlGetSPForRating parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             
             success(responseObject);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

-(void)getCustomerFeedback:(NSString *)serviceProviderId rating:(NSString *)rating comment:(NSString *)comment bookingId:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"SpId":serviceProviderId , @"Rating":rating, @"Comments":comment, @"BookingId":bookingId};
    
    [self post:kUrlGetCustomerFeedback parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             
             success(responseObject);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}
#pragma mark - end

#pragma mark - Device register for push notification
-(void)registerDeviceForPushNotification:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    NSDictionary *requestDict = @{ @"UserId":[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"DeviceId":myDelegate.deviceToken,@"DeviceType":[NSNumber numberWithInt:1] ,@"UserType":[NSNumber numberWithInt:2]};
    [self post:kUrlRegisterDevice parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             [myDelegate StopIndicator];
             success(responseObject);
         }
         else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     }
       failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Booking Response
-(void)bookingResponse:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"BookingId":bookingId};
    
    [self post:kUrlBookingResponse parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             NSMutableArray *bookingDetailDataModel=[[NSMutableArray alloc]init];
             BookingDetailDataModel *bookingDetailModel=[[BookingDetailDataModel alloc]init];
             bookingDetailModel.name=[responseObject objectForKey:@"Name"];
             bookingDetailModel.businessName=[responseObject objectForKey:@"BusinessName"];
             bookingDetailModel.bookingDate=[responseObject objectForKey:@"BookingDate"];
             bookingDetailModel.bookingCount=[responseObject objectForKey:@"BookingCount"];
             bookingDetailModel.serviceName=[responseObject objectForKey:@"ServiceName"];
             bookingDetailModel.serviceCharges=[responseObject objectForKey:@"ServiceCharges"];
             bookingDetailModel.profileImage=[responseObject objectForKey:@"ProfileImage"];
             bookingDetailModel.serviceType=[responseObject objectForKey:@"ServiceType"];
             bookingDetailModel.rating=[responseObject objectForKey:@"Rating"];
             bookingDetailModel.startTime=[responseObject objectForKey:@"StartTime"];
             bookingDetailModel.endTime=[responseObject objectForKey:@"EndTime"];
             bookingDetailModel.status=[responseObject objectForKey:@"Status"];
             bookingDetailModel.serviceProviderId=[responseObject objectForKey:@"ServiceProviderId"];
             [bookingDetailDataModel addObject:bookingDetailModel];
             
             success(bookingDetailDataModel);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
    
}
#pragma mark - end
@end
