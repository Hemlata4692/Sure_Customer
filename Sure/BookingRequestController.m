//
//  BookingRequestController.m
//  CustomCalenderView
//
//  Created by Ranosys on 17/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "BookingRequestController.h"
#import "UITextField+Padding.h"
#import "UIPlaceHolderTextView.h"
#import "UIView+RoundedCorner.h"
#import "BSKeyboardControls.h"
#import "UITextField+Validations.h"
#import "UITextView+Validations.h"
#import "ProfileDataModel.h"

@interface BookingRequestController() <BSKeyboardControlsDelegate>
{
    BOOL checkSlots;
}
@property (weak, nonatomic) IBOutlet UILabel *serviceName;
@property (weak, nonatomic) IBOutlet UILabel *serviceType;
@property (weak, nonatomic) IBOutlet UILabel *chargesPerHour;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *addressView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *remarksView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNoField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIView *dateTimeView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property(nonatomic,retain)NSMutableArray * getMyProfileData;
@end

@implementation BookingRequestController
@synthesize serviceName,serviceType,chargesPerHour,description,timerLabel,dateLabel;
@synthesize phoneNoField,nameField,addressView,remarksView,dateTimeView,scrollView;
@synthesize serviceNameStr,serviceId,serviceCharges,serviceTypeStr,serviceDate;
@synthesize startTime,endTime,serviceSlotHrs,calenderData,getMyProfileData;
@synthesize serviceProviderID;

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Booking Request";
    checkSlots=true;
    [self addPaddingToFields];
    [self setCornerRadius];
    NSArray * fieldArray = @[nameField,phoneNoField,addressView,remarksView];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fieldArray]];
    [self.keyboardControls setDelegate:self];
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    if([[UIScreen mainScreen] bounds].size.height>480)
    {
        scrollView.scrollEnabled=NO;
    }
    serviceName.text=serviceNameStr;
    serviceType.text=serviceTypeStr;
    chargesPerHour.text=serviceCharges;
    dateLabel.text=[myDelegate formatDateToDisplay:serviceDate];
    if ([serviceType.text isEqualToString:@"In-Shop"])
    {
        [addressView setPlaceholder:@"Your address here"];
        
    }
    else
    {
        [addressView setPlaceholder:@"Your address here*"];
    }
    
    [self changeTimeAccSlot];
    timerLabel.text=[NSString stringWithFormat:@"%@ %@ %@",startTime,@"to",endTime];
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getProfileDataFromServer) withObject:nil afterDelay:.1];
}
//Method to add padding to textfields
-(void) addPaddingToFields
{
    [nameField addTextFieldPaddingWithoutImages:nameField];
    [phoneNoField addTextFieldPaddingWithoutImages:phoneNoField];
    
    [addressView setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
    [addressView setPlaceholder:@"Your address here"];
    
    [remarksView setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
    [remarksView setPlaceholder:@"Your remarks here"];
    
}
//Methos to set corner radius to objects
-(void) setCornerRadius
{
    [nameField setCornerRadius:1.0f];
    [phoneNoField setCornerRadius:1.0f];
    [addressView setCornerRadius:1.0f];
    [remarksView setCornerRadius:1.0f];
    [dateTimeView setCornerRadius:1.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void) dealloc
{
    getMyProfileData=nil;
}

#pragma mark - end

#pragma mark - Textfield methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
    if (textField == nameField) {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (textField == phoneNoField)
    {
        [scrollView setContentOffset:CGPointMake(0, phoneNoField.frame.origin.y-5) animated:YES];
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.keyboardControls setActiveField:textView];
    if (textView == addressView) {
        [scrollView setContentOffset:CGPointMake(0, addressView.frame.origin.y-5) animated:YES];
    }
    else if (textView == remarksView)
    {
        [scrollView setContentOffset:CGPointMake(0, remarksView.frame.origin.y-5) animated:YES];
    }
}
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *view;
    
    if ([[UIDevice currentDevice].systemVersion floatValue]< 7.0) {
        view = field.superview.superview;
    } else {
        view = field.superview.superview.superview;
    }
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [keyboardControls.activeField resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}
#pragma mark - end

#pragma mark - Send booking request to server
- (IBAction)sendBookingRequestButtonAction:(id)sender
{
    [self.keyboardControls.activeField resignFirstResponder];
    if([self performValidations])
    {
        [self checkAvailibilityOfSlots];
        if (checkSlots==true)
        {
            [myDelegate ShowIndicator];
            [self performSelector:@selector(sendBookingRequestToServer) withObject:nil afterDelay:.1];
     
        }
    }
}
#pragma mark - end

#pragma mark - Webservice Methods
//Method to get profile data from server
-(void)getProfileDataFromServer
{
    [[WebService sharedManager] getProfileData:^(id getProfileData)
     {
        getMyProfileData=[getProfileData mutableCopy];
         [self displayMyProfileData];
         
     } failure:^(NSError *error) {
         
     }] ;
    
}
//Method to display profile data
-(void) displayMyProfileData
{
    ProfileDataModel *data =[getMyProfileData objectAtIndex:0];
    nameField.text=data.Name;
    addressView.text=data.Address;
    phoneNoField.text=data.PhoneNo;
}
//Method to perform validations before submission of booking request
- (BOOL)performValidations
{
    UIAlertView *alert;
    if ([nameField isEmpty] || [phoneNoField isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please fill in all mandatory(*) fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if ([serviceType.text isEqualToString:@"On-Site"] && [addressView isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please fill in all mandatory(*) fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    return YES;
}
//Method to send booking request to server
-(void) sendBookingRequestToServer
{
    if ([endTime isEqualToString:@"24:00"]) {
        endTime=@"23:59";
    }
    [[WebService sharedManager] bookingRequest:serviceId customerName:nameField.text customerContact:phoneNoField.text bookingDate:dateLabel.text remarks:remarksView.text address:addressView.text startTime:startTime endTime:endTime spUserId:serviceProviderID success:^(id responseObject)
     {
         UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         alert.tag=1;
         [alert show];
         
     } failure:^(NSError *error)
     {
         
     }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - end

#pragma mark - Methods to check availability of slots and time
//Method to calculate time according to service slot hours
-(void) changeTimeAccSlot
{
    NSString *tempString=[NSString stringWithFormat:@"%.1f",serviceSlotHrs];
    NSArray *subStrings = [tempString componentsSeparatedByString:@"."];
    int firstIntHrs= [[subStrings objectAtIndex:0]intValue];
    int secondIntMin=[[subStrings objectAtIndex:1]intValue];
    if (secondIntMin ==5)
    {
        secondIntMin=30;
    }
    else
    {
        secondIntMin=00;
    }
    NSArray *subStrings1 = [startTime componentsSeparatedByString:@":"];
    NSString *firstString1 = [subStrings1 objectAtIndex:0];
    int firstInt1=[firstString1 intValue];
    NSString *lastString1 = [subStrings1 objectAtIndex:1];
    int secondInt2=[lastString1 intValue];
    NSString *finalBookingSlotHrs;
    NSString *endTimeHrs;
    NSString *finalBookingSlotMin=[NSString stringWithFormat:@"%d",secondInt2+secondIntMin];
    if ([finalBookingSlotMin isEqualToString:@"60"])
    {
        finalBookingSlotMin=@"1";
        finalBookingSlotHrs=[NSString stringWithFormat:@"%d",firstInt1+firstIntHrs+[finalBookingSlotMin intValue]];
        endTimeHrs=[NSString stringWithFormat:@"%@:%@",finalBookingSlotHrs,@"00"];
        
    }
    else
    {
        finalBookingSlotHrs=[NSString stringWithFormat:@"%d",firstInt1+firstIntHrs];
        endTimeHrs=[NSString stringWithFormat:@"%@:%@",finalBookingSlotHrs,finalBookingSlotMin];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    dateFormatter.dateFormat = @"HH:mm";
    NSDate *date = [dateFormatter dateFromString:endTimeHrs];
    
    endTimeHrs = [dateFormatter stringFromDate:date];
    
    if (endTimeHrs ==nil) {
        endTimeHrs=@"24:00";
    }
    endTime=endTimeHrs;
}
//Method to check availability of slots
-(void) checkAvailibilityOfSlots
{
    checkSlots=true;
    NSString *tempStartTime=startTime;
    int slotToBeBooked=serviceSlotHrs/0.5;
    for (int i=0; i<slotToBeBooked; i++)
    {
        if ([tempStartTime isEqualToString:calenderData.businessEndHours])
        {
            UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"This service provider is not available for the given slot." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            checkSlots=false;
            return;
        }
        else
        {
            for (int j=0; j<calenderData.bookingsList.count; j++)
            {
                NSMutableDictionary *dataDic=[calenderData.bookingsList objectAtIndex:j];
                
                if ([tempStartTime isEqualToString:[dataDic objectForKey:@"StartTime"]])
                {
                    UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"This service provider is not available for the given slot." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    checkSlots=false;
                    return;
                }
            }
        }
        NSArray *subStrings1 = [tempStartTime componentsSeparatedByString:@":"];
        NSString *firstString1 = [subStrings1 objectAtIndex:0];
        int firstInt1=[firstString1 intValue];
        NSString *lastString1 = [subStrings1 objectAtIndex:1];
        int secondInt2=[lastString1 intValue];
        NSString *finalAvailSlot;
        NSString *startTimeHrs;
        NSString *endTimeMin;
        NSString *endTimeHrs;
        NSString *chkTimeSlot;
        if (secondInt2==0)
        {
            endTimeMin=[NSString stringWithFormat:@"%d",secondInt2+30];
            startTimeHrs=[NSString stringWithFormat:@"%d",firstInt1];
            finalAvailSlot=[NSString stringWithFormat:@"%@:%@",startTimeHrs,endTimeMin];
            chkTimeSlot=[NSString stringWithFormat:@"%@.%@",startTimeHrs,endTimeMin];
        }
        else
        {
            endTimeMin=[NSString stringWithFormat:@"%d",secondInt2+30];
            
            if ([endTimeMin isEqualToString:@"60"])
            {
                endTimeMin=@"1";
                endTimeHrs=[NSString stringWithFormat:@"%d",firstInt1+[endTimeMin intValue]];
                finalAvailSlot=[NSString stringWithFormat:@"%@:%@",endTimeHrs,@"00"];
                chkTimeSlot=[NSString stringWithFormat:@"%@.%@",endTimeHrs,@"00"];
            }
        }
        if ([chkTimeSlot floatValue]>24.00)
        {
            UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"This service provider is not available for the given slot." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            checkSlots=false;
            return;
        }
        if ([finalAvailSlot isEqualToString:@"24:00"])
        {
            tempStartTime=finalAvailSlot;
        }
        else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc]
                                initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:locale];
            dateFormatter.dateFormat = @"HH:mm";
            NSDate *date = [dateFormatter dateFromString:finalAvailSlot];
            
            finalAvailSlot = [dateFormatter stringFromDate:date];
            
            tempStartTime=finalAvailSlot;
        }
    }
}
#pragma mark - end
@end
