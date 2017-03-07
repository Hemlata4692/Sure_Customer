//
//  MyCalenderViewController.m
//  Sure_sp
//
//  Created by Ranosys on 24/03/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "MyCalenderViewController.h"
#import "SWRevealViewController.h"
#import "MyCalenderDataModel.h"
#import "BookingDetailViewController.h"
#import <EventKit/EventKit.h>
#import "JNKeychain.h"

@interface MyCalenderViewController ()
{
    int start,last,startMin,lastMin,value;
    NSMutableArray *dateValue, *serviceListArray, *getWebserviceArray,*LastDataCheckerArray;
    NSMutableDictionary *webserviceDataDic, *internalWebserviceDataDic;
    NSMutableDictionary *frameDic;
    int tag;
    NSString *removeBooking;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *displayBookingView;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UIView *dayNavigatorView;
@property (weak, nonatomic) IBOutlet UIButton *previousDayBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextDayBtn;
@property (weak, nonatomic) IBOutlet UIButton *calendarDateBtn;
@property(strong,nonatomic) NSString *dateString;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@end

@implementation MyCalenderViewController
@synthesize scrollview,displayBookingView,dayNavigatorView;
@synthesize dayLabel,previousDayBtn,nextDayBtn,calendarDateBtn;
@synthesize datePicker,pickerToolbar,dateString;

#pragma mark  - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"My Calendar";
    [self removeAutolayouts];
    [self setFramesOfObject];
    dateValue=[NSMutableArray new];
    serviceListArray=[NSMutableArray new];
    frameDic=[NSMutableDictionary new];
    LastDataCheckerArray=[NSMutableArray new];
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateformate setLocale:locale];
    [dateformate setDateFormat:@"dd-MMMM-YYYY"];
    dateString=[dateformate stringFromDate:[NSDate date]];
    [calendarDateBtn setTitle:[myDelegate formatDateToDisplay:[NSDate date]] forState:UIControlStateNormal];
    [dateformate setDateFormat:@"EEEE"];
    dayLabel.text=[[dateformate stringFromDate:[NSDate date]]uppercaseString];
}
//Method to remove autolayouts
-(void)removeAutolayouts
{
    scrollview.translatesAutoresizingMaskIntoConstraints = YES;
    dayLabel.translatesAutoresizingMaskIntoConstraints = YES;
    displayBookingView.translatesAutoresizingMaskIntoConstraints = YES;
    dayNavigatorView.translatesAutoresizingMaskIntoConstraints = YES;
    previousDayBtn.translatesAutoresizingMaskIntoConstraints = YES;
    nextDayBtn.translatesAutoresizingMaskIntoConstraints = YES;
    calendarDateBtn.translatesAutoresizingMaskIntoConstraints = YES;
    datePicker.translatesAutoresizingMaskIntoConstraints=YES;
    pickerToolbar.translatesAutoresizingMaskIntoConstraints=YES;
}
//Method to set dynamic framing of objects
-(void) setFramesOfObject
{
    dayLabel.frame=CGRectMake(90, 0, self.view.frame.size.width-90, 40);
    scrollview.frame=CGRectMake(0, 40, self.view.frame.size.width,  self.view.frame.size.height-144);
    dayNavigatorView.frame=CGRectMake(0, self.scrollview.frame.origin.y+self.scrollview.frame.size.height, self.view.frame.size.width, 40);
    previousDayBtn.frame=CGRectMake(0, 0, previousDayBtn.frame.size.width, previousDayBtn.frame.size.height);
    nextDayBtn.frame=CGRectMake(self.view.frame.size.width-43, 0, nextDayBtn.frame.size.width, nextDayBtn.frame.size.height);
    calendarDateBtn.frame=CGRectMake((self.dayNavigatorView.frame.size.width/2)-86, 0, calendarDateBtn.frame.size.width, calendarDateBtn.frame.size.height);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getMyCalendarFromWebservice) withObject:nil afterDelay:.2];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark  - end

#pragma mark  - Get calendar methods
//Get customer calender from server
-(void)getMyCalendarFromWebservice
{
    [[WebService sharedManager] getCustomerCalnder:dateString success:^(id customerCalender)
     {
         MyCalenderDataModel *customerCalenderObj =[[MyCalenderDataModel alloc]init];
         customerCalenderObj=customerCalender;
         serviceListArray=[customerCalenderObj.serviceList mutableCopy];
         [self customerCustomCalander];
         
     } failure:^(NSError *error)
     {
         
     }];
}
//Method to draw custom calender of customer
-(void) customerCustomCalander
{
    NSString *startingTime=[NSString stringWithFormat:@"00:00"];
    NSString *endingTime=@"24:00";
    NSString *startTime=startingTime;
    NSArray *startdate=[self stringColonSeparation:startTime];
    start=[[startdate objectAtIndex:0] intValue];
    startMin=[[startdate objectAtIndex:1] intValue];
    NSString *endTime=endingTime;
    NSArray *enddate=[self stringColonSeparation:endTime];
    last=[[enddate objectAtIndex:0] intValue];
    lastMin=[[enddate objectAtIndex:1] intValue];
    value=0;
    value=(last-start-1)*2;
    if (startMin!=0) {
        value=value+1;
    }
    else{
        value=value+2;
    }
    if (lastMin!=0) {
        value=value+1;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    dateFormatter.dateFormat = @"HH:mm";
    NSDate *date = [dateFormatter dateFromString:startTime];
    for (int i=0; i<value; i++) {
        [dateValue addObject:[[dateFormatter stringFromDate:date] lowercaseString]];
        date=[date dateByAddingTimeInterval:60*30];
    }
    if (value*40>self.scrollview.frame.size.height)
        displayBookingView.frame=CGRectMake(0, 0,self.scrollview.frame.size.width, value*40);
    else
        displayBookingView.frame=CGRectMake(0, 0,self.scrollview.frame.size.width, self.scrollview.frame.size.height);
    scrollview.contentInset = UIEdgeInsetsMake(0, 0, self.displayBookingView.frame.size.height, 0);
    for (int i=0; i<value; i++) {
        [self customLabelMethod:i];
    }
    NSMutableDictionary *setbuttons=[NSMutableDictionary new];
    NSMutableDictionary *internalSetbuttons=[NSMutableDictionary new];
    int count=0;
    for (int i=0;i<serviceListArray.count;i++) {
        [self clashingSlotMethod:i count:count lastButtonPosition:setbuttons lastInternalButtonPosition:internalSetbuttons];
    }
    for (int i=0;i<serviceListArray.count;i++) {
        NSMutableDictionary *dataDic=[serviceListArray objectAtIndex:i];
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [dateFormatter1 setLocale:locale];
        dateFormatter1.dateFormat = @"HH:mm";
        NSString *serviceEndTime=[dataDic objectForKey:@"EndTime"];
        NSDate *now = [dateFormatter1 dateFromString:[dataDic objectForKey:@"StartTime"]];
        NSDate *then;
        NSTimeInterval timeInterval;
        if ([[dataDic objectForKey:@"EndTime"] isEqualToString:@"23:59"]) {
            then  = [dateFormatter1 dateFromString:@"23:30"];
            timeInterval=[then timeIntervalSinceDate:now]+ 60*30;
        } else {
            then = [dateFormatter1 dateFromString:[dataDic objectForKey:@"EndTime"]];
            timeInterval=[then timeIntervalSinceDate:now] ;
        }
        int timeIntervalInt=timeInterval/1800;
        
        NSDate *date1 = [dateFormatter1 dateFromString:[dataDic objectForKey:@"StartTime"]];
        NSDate *datetwo = [dateFormatter1 dateFromString:serviceEndTime];
        NSString *dateChecker=[[dateFormatter1 stringFromDate:date1] lowercaseString];
        NSString *enddateChecker=[[dateFormatter1 stringFromDate:datetwo] lowercaseString];
        
        if ([frameDic objectForKey:dateChecker]!=nil) {
            
            NSMutableDictionary *checkerdic=[setbuttons objectForKey:dateChecker];
            if ([[checkerdic objectForKey:@"count"] intValue]==0) {
                NSMutableDictionary *updation=[NSMutableDictionary new];
                int count1=[[checkerdic objectForKey:@"count"] intValue];
                count1=count1+1;
                
                NSString *buttonFrams=[frameDic objectForKey:dateChecker];
                CGRect rect = CGRectFromString(buttonFrams);
                UIButton *but= [[UIButton alloc]initWithFrame:CGRectMake(90, rect.origin.y, self.view.frame.size.width-90, 40*timeIntervalInt)];
                [but addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                but.backgroundColor=[UIColor colorWithRed:255.0/255.0 green:63.0/255.0 blue:64.0/255.0 alpha:1.0];
                [[but layer] setBorderWidth:0.3f];
                [[but layer] setBorderColor:[UIColor whiteColor].CGColor];
                but.tag=i;
                UILabel* titleLabel = [[UILabel alloc]
                                       initWithFrame:CGRectMake(10, 0,
                                                                but.frame.size.width-40,but.frame.size.height)] ;
                titleLabel.text = [dataDic objectForKey:@"ServiceName"];
                titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size: 15.0];
                titleLabel.numberOfLines=2;
                titleLabel.textColor = [UIColor whiteColor];
                titleLabel.backgroundColor = [UIColor clearColor];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                [but addSubview:titleLabel];
                [self.displayBookingView addSubview:but];
                UIButton *cancel= [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, but.frame.origin.y+ (but.frame.size.height/2)-20, 40, 40)];
                [cancel addTarget:self action:@selector(removeServiceFromCalendar:) forControlEvents:UIControlEventTouchUpInside];
                [cancel setImage:[UIImage imageNamed:[NSString stringWithFormat:@"close_icon1"]] forState:UIControlStateNormal];
                NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
                NSLocale *locale = [[NSLocale alloc]
                                    initWithLocaleIdentifier:@"en_US"];
                [dateFormatter1 setLocale:locale];
                [dateFormatter1 setDateFormat:@"dd-MMMM-yyyy"];
                NSString *tempCurrentDate=[dateFormatter1 stringFromDate:[NSDate date]];
                NSDate *currentDate = [dateFormatter1 dateFromString:tempCurrentDate];
                NSDate *serverDate = [dateFormatter1 dateFromString:dateString];
                [dateFormatter1 setDateFormat:@"HH:mm"];
                NSString *currentTime=[dateFormatter1 stringFromDate:[NSDate date]];
                if ([serverDate compare:currentDate] == NSOrderedAscending)
                {
                    cancel.enabled=NO;
                }
                else if (([serverDate compare:currentDate] != NSOrderedDescending) && [[dateFormatter1 dateFromString:dateChecker] compare:[dateFormatter1 dateFromString:currentTime]] == NSOrderedAscending)
                {
                    cancel.enabled=NO;
                }
                cancel.tag=i;
                [self.displayBookingView addSubview:cancel];
                [updation setObject:but forKey:@"button"];
                [updation setObject:cancel forKey:@"cancel"];
                [updation setObject:titleLabel.text forKey:@"titleText"];
                [updation setObject:[NSNumber numberWithInt:count1] forKey:@"count"];
                [setbuttons setObject:updation forKey:dateChecker];
            }
            else
            {
                NSMutableDictionary *updation=[setbuttons objectForKey:dateChecker];
                UIButton *leftbutton=[updation objectForKey:@"button"];
                UIButton *cancelleftbutton=[updation objectForKey:@"cancel"];
                if (leftbutton.frame.size.width==((self.view.frame.size.width-90)/2))
                {
                    leftbutton.frame=CGRectMake(leftbutton.frame.origin.x, leftbutton.frame.origin.y, leftbutton.frame.size.width, leftbutton.frame.size.height);
                    cancelleftbutton.frame=CGRectMake(cancelleftbutton.frame.origin.x, cancelleftbutton.frame.origin.y, cancelleftbutton.frame.size.width, cancelleftbutton.frame.size.height);
                    NSArray *viewsToRemove = [leftbutton subviews];
                    for (UIView *v in viewsToRemove) {
                        [v removeFromSuperview];
                    }
                    UILabel* titleLabel = [[UILabel alloc]
                                           initWithFrame:CGRectMake(10, 0,
                                                                    leftbutton.frame.size.width-40,leftbutton.frame.size.height)] ;
                    titleLabel.text = [updation objectForKey:@"titleText"];
                    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size: 15.0];
                    titleLabel.numberOfLines=2;
                    titleLabel.textColor = [UIColor whiteColor];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    [leftbutton addSubview:titleLabel];
                }
                else
                {
                    leftbutton.frame=CGRectMake(leftbutton.frame.origin.x, leftbutton.frame.origin.y, leftbutton.frame.size.width/2, leftbutton.frame.size.height);
                    cancelleftbutton.frame=CGRectMake((cancelleftbutton.frame.origin.x/2)+30, cancelleftbutton.frame.origin.y, cancelleftbutton.frame.size.width, cancelleftbutton.frame.size.height);
                    NSArray *viewsToRemove = [leftbutton subviews];
                    for (UIView *v in viewsToRemove) {
                        [v removeFromSuperview];
                    }
                    UILabel* titleLabel = [[UILabel alloc]
                                           initWithFrame:CGRectMake(10, 0,
                                                                    leftbutton.frame.size.width-40,leftbutton.frame.size.height)] ;
                    titleLabel.text = [updation objectForKey:@"titleText"];
                    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size: 15.0];
                    titleLabel.numberOfLines=2;
                    titleLabel.textColor = [UIColor whiteColor];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    [leftbutton addSubview:titleLabel];
                }
                NSString *buttonFrams=[frameDic objectForKey:dateChecker];
                CGRect rect = CGRectFromString(buttonFrams);
                UIButton *but;
                if (leftbutton.frame.origin.x==90) {
                    but= [[UIButton alloc]initWithFrame:CGRectMake(90+(rect.size.width/2), rect.origin.y, (self.view.frame.size.width-90)/2, 40*timeIntervalInt)];
                }
                else{
                    but= [[UIButton alloc]initWithFrame:CGRectMake(90, rect.origin.y, (self.view.frame.size.width-90)/2, 40*timeIntervalInt)];
                }
                UILabel* titleLabel = [[UILabel alloc]
                                       initWithFrame:CGRectMake(10, 0,
                                                                but.frame.size.width-40,but.frame.size.height)] ;
                titleLabel.text = [dataDic objectForKey:@"ServiceName"];
                titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size: 15.0];
                titleLabel.numberOfLines=2;
                titleLabel.textColor = [UIColor whiteColor];
                titleLabel.backgroundColor = [UIColor clearColor];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                [but addSubview:titleLabel];
                [but addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                but.backgroundColor=[UIColor colorWithRed:255.0/255.0 green:63.0/255.0 blue:64.0/255.0 alpha:1.0];
                [[but layer] setBorderWidth:0.3f];
                [[but layer] setBorderColor:[UIColor whiteColor].CGColor];
                but.tag=i;
                [self.displayBookingView addSubview:but];
                UIButton *cancel;
                
                if (leftbutton.frame.origin.x==90)
                {
                    cancel= [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, but.frame.origin.y+ (but.frame.size.height/2)-20, 40, 40)];
                }
                else
                {
                    cancel= [[UIButton alloc]initWithFrame:CGRectMake((cancelleftbutton.frame.origin.x/2)+30, but.frame.origin.y+ (but.frame.size.height/2)-20, cancelleftbutton.frame.size.width, cancelleftbutton.frame.size.height)];
                }
                [cancel addTarget:self action:@selector(removeServiceFromCalendar:) forControlEvents:UIControlEventTouchUpInside];
                
                [cancel setImage:[UIImage imageNamed:[NSString stringWithFormat:@"close_icon1"]] forState:UIControlStateNormal];
                NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
                NSLocale *locale = [[NSLocale alloc]
                                    initWithLocaleIdentifier:@"en_US"];
                [dateFormatter1 setLocale:locale];
                [dateFormatter1 setDateFormat:@"dd-MMMM-yyyy"];
                NSString *tempCurrentDate=[dateFormatter1 stringFromDate:[NSDate date]];
                NSDate *currentDate = [dateFormatter1 dateFromString:tempCurrentDate];
                NSDate *serverDate = [dateFormatter1 dateFromString:dateString];
                [dateFormatter1 setDateFormat:@"HH:mm"];
                NSString *currentTime=[dateFormatter1 stringFromDate:[NSDate date]];
                if ([serverDate compare:currentDate] == NSOrderedAscending)
                {
                    cancel.enabled=NO;
                }
                else if (([serverDate compare:currentDate] != NSOrderedDescending) && [[dateFormatter1 dateFromString:dateChecker] compare:[dateFormatter1 dateFromString:currentTime]] == NSOrderedAscending)
                {
                    cancel.enabled=NO;
                }
                cancel.tag=i;
                [self.displayBookingView addSubview:cancel];
                [updation setObject:but forKey:@"button"];
                [updation setObject:cancel forKey:@"cancel"];
                [updation setObject:[NSNumber numberWithInt:1] forKey:@"count"];
                [setbuttons setObject:updation forKey:dateChecker];
            }
            
        }
        for (int k=0; k<LastDataCheckerArray.count; k++) {
            [self updateClashingSlotMethod:k dateChecker:dateChecker enddateChecker:enddateChecker lastButtonPosition:setbuttons];
        }
    }
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)updateClashingSlotMethod:(int)kValue dateChecker:(NSString *)dateChecker enddateChecker:(NSString *)enddateChecker lastButtonPosition:(NSMutableDictionary *)setbuttons{
    NSArray *getArray=[self stringCommaSeparation:[LastDataCheckerArray objectAtIndex:kValue]];
    NSString *str=[getArray objectAtIndex:0];
    NSString *strOne=[getArray objectAtIndex:1];
    if ([str isEqualToString:dateChecker] && [strOne isEqualToString:enddateChecker]) {
        NSString *dateone=[getArray objectAtIndex:2];
        NSMutableDictionary *checkerdic=[setbuttons objectForKey:dateone];
        NSMutableDictionary *dictionary=[setbuttons objectForKey:dateChecker];
        NSMutableDictionary *updation=[NSMutableDictionary new];
        int count1=[[checkerdic objectForKey:@"count"] intValue];
        count1=count1+1;
        [updation setObject:[NSNumber numberWithInt:count1] forKey:@"count"];
        [updation setObject:[dictionary objectForKey:@"button"] forKey:@"button"];
        [updation setObject:[dictionary objectForKey:@"cancel"] forKey:@"cancel"];
        [updation setObject:[dictionary objectForKey:@"titleText"] forKey:@"titleText"];
        [setbuttons setObject:updation forKey:dateone];
    }
}
-(void)clashingSlotMethod:(int)iValue count:(int)count lastButtonPosition:(NSMutableDictionary *)setbuttons lastInternalButtonPosition:(NSMutableDictionary *)internalSetbuttons{
    NSMutableDictionary *dataDic=[serviceListArray objectAtIndex:iValue];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter1 setLocale:locale];
    dateFormatter1.dateFormat = @"HH:mm";
    NSDate *startdate1 = [dateFormatter1 dateFromString:[dataDic objectForKey:@"StartTime"]];
    NSDate *enddate1 = [dateFormatter1 dateFromString:[dataDic objectForKey:@"EndTime"]];
    NSString *a=[[dateFormatter1 stringFromDate:startdate1] lowercaseString];
    NSString *c=[[dateFormatter1 stringFromDate:enddate1] lowercaseString];
    [internalSetbuttons setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    [setbuttons setObject:internalSetbuttons forKey:a];
    for (int j=0;j<serviceListArray.count;j++) {
        if (iValue!=j) {
            NSMutableDictionary *intdataDic=[serviceListArray objectAtIndex:j];
            NSDateFormatter *intdateFormatter1 = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc]
                                initWithLocaleIdentifier:@"en_US"];
            [intdateFormatter1 setLocale:locale];
            intdateFormatter1.dateFormat = @"HH:mm";
            NSDate *intstartdate1 = [intdateFormatter1 dateFromString:[intdataDic objectForKey:@"StartTime"]];
            NSDate *intenddate1 = [intdateFormatter1 dateFromString:[intdataDic objectForKey:@"EndTime"]];
            NSString *b=[[dateFormatter1 stringFromDate:intstartdate1] lowercaseString];
            if ([startdate1 timeIntervalSinceDate:intstartdate1]!=0 && [enddate1 timeIntervalSinceDate:intstartdate1]!=0 && [startdate1 timeIntervalSinceDate:intenddate1]!=0) {
                BOOL betweenChecker=[self inputDate:intstartdate1 start:startdate1 end:enddate1];
                if (betweenChecker==true) {
                    [LastDataCheckerArray addObject:[NSString stringWithFormat:@"%@,%@,%@",a,c,b]];
                }
            }
        }
    }
}

-(void)customLabelMethod:(int)iValue{
    UILabel *time=[[UILabel alloc]initWithFrame:CGRectMake(0, iValue*40, 90, 40)];
    time.backgroundColor=[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    time.textAlignment=NSTextAlignmentCenter;
    time.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    time.textColor=[UIColor darkGrayColor];
    time.text=[dateValue objectAtIndex:iValue];
    [self.displayBookingView addSubview:time];
    UILabel *jobs=[[UILabel alloc]initWithFrame:CGRectMake(90, iValue*40, self.view.frame.size.width-90, 40)];
    if (iValue%2==0)
        jobs.backgroundColor=[UIColor whiteColor];
    else
        jobs.backgroundColor=[UIColor colorWithRed:244.0/255.0 green:243.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    jobs.textAlignment=NSTextAlignmentCenter;
    CGRect frame=jobs.frame;
    [frameDic setObject:NSStringFromCGRect(frame) forKey:time.text];
    
    [self.displayBookingView addSubview:jobs];
}

- (BOOL)inputDate:(NSDate*)date start:(NSDate*)beginDate end:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

-(NSArray *)stringColonSeparation:(NSString *)date{
    NSArray *strings = [date componentsSeparatedByString:@":"];
    return strings;
}

-(NSArray *)stringCommaSeparation:(NSString *)date{
    NSArray *arrayStrings = [date componentsSeparatedByString:@","];
    return arrayStrings;
}

-(NSString *)stringSpaceSeparation:(NSString *)date{
    NSArray *strings = [date componentsSeparatedByString:@" "];
    
    return [strings objectAtIndex:0];
}

#pragma mark  - end

#pragma mark  - IBAction

- (IBAction) buttonClicked: (id)sender
{
    tag=(int)[sender tag];
    NSDictionary *tempDict = [serviceListArray objectAtIndex:tag];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BookingDetailViewController *bookingDetail =[storyboard instantiateViewControllerWithIdentifier:@"BookingDetailViewController"];
    bookingDetail.bookingId=[tempDict objectForKey:@"BookingId"];
    [self.navigationController pushViewController:bookingDetail animated:YES];
}

- (IBAction) removeServiceFromCalendar: (id)sender
{
    tag = (int)[sender tag];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure you want to cancel this booking?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [alert show];
    alert.tag =5;
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==5 && buttonIndex==0)
    {
        NSDictionary *tempDict = [serviceListArray objectAtIndex:tag];
        [myDelegate ShowIndicator];
        [self performSelector:@selector(cancelBookingFromServer:) withObject:[tempDict objectForKey:@"BookingId"] afterDelay:.1];
    }
}

-(void)deleteLocalNotification
{
    NSArray *notificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for(UILocalNotification *notification in notificationArray){
        if ([notification.userInfo isEqualToDictionary:[NSDictionary dictionaryWithObject:removeBooking forKey:@"Calender"]] ) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification] ;
            
            NSString *eventIdentifier=[JNKeychain loadValueForKey:removeBooking];
            if ([JNKeychain deleteValueForKey:removeBooking])
            {
                EKEventStore* store = [[EKEventStore alloc] init];
                EKEvent* event = [store eventWithIdentifier:eventIdentifier];
                if (event != nil) {
                    NSError* error = nil;
                    [store removeEvent:event span:EKSpanThisEvent error:&error];
                }
            }
            
        }
        if ([notification.userInfo isEqualToDictionary:[NSDictionary dictionaryWithObject:removeBooking forKey:@"BookingID"]]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}
#pragma mark  - end

#pragma mark  - Cancel booking method

-(void)cancelBookingFromServer:(NSString *)bookingId
{
    [[WebService sharedManager] cancelBooking:bookingId success:^(id responseObject)
     {
         removeBooking=bookingId;
         [myDelegate StopIndicator];
         [self deleteLocalNotification];
         
         UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [alert show];
         [myDelegate ShowIndicator];
         [self performSelector:@selector(getMyCalendarFromWebservice) withObject:nil afterDelay:.2];
         
     } failure:^(NSError *error) {
         
     }] ;
}

#pragma mark  - end

#pragma mark  - Change date actions

- (IBAction)previousDayAction:(UIButton *)sender
{
    NSArray *viewsToRemove = [self.displayBookingView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // [self setMaximumDate];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter1 setLocale:locale];
    [dateFormatter1 setDateFormat:@"dd-MMMM-yyyy"];
    
    NSDate *date =[dateFormatter1 dateFromString:dateString]; // your date from the server will go here.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = -1;
    NSDate *newDate = [calendar dateByAddingComponents:components toDate:date options:0];
    dateString=[dateFormatter1 stringFromDate:newDate];
    [calendarDateBtn setTitle:[myDelegate formatDateToDisplay:newDate] forState:UIControlStateNormal];
    // [self checkPreviousDate];
    [dateFormatter1 setDateFormat:@"EEEE"];
    dayLabel.text=[[dateFormatter1 stringFromDate:newDate] uppercaseString];
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getMyCalendarFromWebservice) withObject:nil afterDelay:.2];
}
- (IBAction)nextDayAction:(UIButton *)sender
{
    NSArray *viewsToRemove = [self.displayBookingView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //  [self setMaximumDate];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter1 setLocale:locale];
    [dateFormatter1 setDateFormat:@"dd-MMMM-yyyy"];
    
    NSDate *date =[dateFormatter1 dateFromString:dateString]; // your date from the server will go here.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    NSDate *newDate = [calendar dateByAddingComponents:components toDate:date options:0];
    dateString=[dateFormatter1 stringFromDate:newDate];
    [calendarDateBtn setTitle:[myDelegate formatDateToDisplay:newDate] forState:UIControlStateNormal];
    // [self checkPreviousDate];
    [dateFormatter1 setDateFormat:@"EEEE"];
    dayLabel.text=[[dateFormatter1 stringFromDate:newDate] uppercaseString];
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getMyCalendarFromWebservice) withObject:nil afterDelay:.2];
}
#pragma mark  - end

#pragma mark  - Picker and toolbar methods

- (IBAction)calanderDatePicker:(UIButton *)sender
{
    previousDayBtn.enabled=YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    datePicker.backgroundColor=[UIColor whiteColor];
    datePicker.minimumDate=[NSDate date];
    // [self setMaximumDate];
    datePicker.frame = CGRectMake(datePicker.frame.origin.x, self.view.frame.size.height-datePicker.frame.size.height , self.view.frame.size.width, datePicker.frame.size.height);
    pickerToolbar.backgroundColor=[UIColor whiteColor];
    pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, datePicker.frame.origin.y-44, self.view.frame.size.width, pickerToolbar.frame.size.height);
    [UIView commitAnimations];
}


-(void)hidePickerWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    datePicker.frame = CGRectMake(datePicker.frame.origin.x, 1000, self.view.frame.size.width, datePicker.frame.size.height);
    pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, 1000, self.view.frame.size.width, pickerToolbar.frame.size.height);
    [UIView commitAnimations];
}

- (IBAction)toolBarCancelAction:(id)sender
{
    [self hidePickerWithAnimation];
    // [self checkPreviousDate];
}

- (IBAction)toolBarDoneAction:(id)sender
{
    NSArray *viewsToRemove = [self.displayBookingView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //[self setMaximumDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"dd-MMMM-YYYY"];
    dateString = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:datePicker.date]];
    [calendarDateBtn setTitle:[myDelegate formatDateToDisplay:datePicker.date] forState:UIControlStateNormal];
    //[self checkPreviousDate];
    [dateFormatter setDateFormat:@"EEEE"];
    dayLabel.text=[[dateFormatter stringFromDate:datePicker.date]uppercaseString];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getMyCalendarFromWebservice) withObject:nil afterDelay:.2];
    [self hidePickerWithAnimation];
    
}
#pragma mark  - end
@end
