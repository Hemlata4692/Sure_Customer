//
//  BookingCalendarViewController.m
//  Sure
//
//  Created by Hema on 23/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "BookingCalendarViewController.h"
#import "BookingRequestController.h"
#import "BookingCalenderDataModel.h"

@interface BookingCalendarViewController ()
{
    int start,last,startMin,lastMin,value;
    NSMutableArray *dateValue, *bookingListArray;
    NSMutableDictionary *frameDic;
    BookingCalenderDataModel *spCalenderData;
    NSString *slotStartTime;
    NSString *slotEndTime;
    NSString *maximumDate;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *bookingDisplayView;
@property (weak, nonatomic) IBOutlet UILabel *chargesPerHour;
@property (weak, nonatomic) IBOutlet UILabel *serviceNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *previousDayBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextDayBtn;
@property (weak, nonatomic) IBOutlet UIButton *calenderDateOutlet;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolBar;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIImageView *currencyImage;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *noSPAvailLbl;
@end

@implementation BookingCalendarViewController
@synthesize bookingDisplayView,scrollview,serviceProviderID,currencyImage,serviceType;
@synthesize pickerToolBar,datePicker,dateString,serviceName,serviceCharges,serviceId;
@synthesize dayLabel,previousDayBtn,nextDayBtn,calenderDateOutlet,serviceNameLbl,chargesPerHour,bottomView;
@synthesize serviceSlotHour,noSPAvailLbl,advanceBookingHrs,advanceBookingDays,timeLbl;

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Booking";
    noSPAvailLbl.hidden=YES;
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
    [calenderDateOutlet setTitle:[myDelegate formatDateToDisplay:[NSDate date]] forState:UIControlStateNormal];
    [dateformate setDateFormat:@"EEEE"];
    dayLabel.text=[[dateformate stringFromDate:[NSDate date]]uppercaseString];
    serviceNameLbl.text=serviceName;
    chargesPerHour.text=serviceCharges;
    timeLbl.text=@"TIME";
    previousDayBtn.enabled=NO;
    [self removeAutolayouts];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getBookingCalenderFromWebservice) withObject:nil afterDelay:.2];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Method to remove autolayouts and set dynamic framing to objects
-(void)removeAutolayouts
{
    scrollview.translatesAutoresizingMaskIntoConstraints = YES;
    dayLabel.translatesAutoresizingMaskIntoConstraints = YES;
    bookingDisplayView.translatesAutoresizingMaskIntoConstraints = YES;
    bottomView.translatesAutoresizingMaskIntoConstraints = YES;
    previousDayBtn.translatesAutoresizingMaskIntoConstraints = YES;
    nextDayBtn.translatesAutoresizingMaskIntoConstraints = YES;
    calenderDateOutlet.translatesAutoresizingMaskIntoConstraints = YES;
    serviceNameLbl.translatesAutoresizingMaskIntoConstraints=YES;
    chargesPerHour.translatesAutoresizingMaskIntoConstraints=YES;
    currencyImage.translatesAutoresizingMaskIntoConstraints=YES;
    [self setFramesOfObjects];
}

-(void) setFramesOfObjects
{
    serviceNameLbl.frame=CGRectMake(5, 0, self.view.frame.size.width-(chargesPerHour.frame.size.width+currencyImage.frame.size.width+8) ,serviceNameLbl.frame.size.height);
    chargesPerHour.frame=CGRectMake(self.view.frame.size.width-chargesPerHour.frame.size.width, 0, chargesPerHour.frame.size.width, chargesPerHour.frame.size.height);
    currencyImage.frame=CGRectMake(self.view.frame.size.width-(chargesPerHour.frame.size.width+currencyImage.frame.size.width+3), 14, currencyImage.frame.size.width ,currencyImage.frame.size.height);
    dayLabel.frame=CGRectMake(90, 0+chargesPerHour.frame.size.height, self.view.frame.size.width-90, self.dayLabel.frame.size.height);
    timeLbl.frame=CGRectMake(timeLbl.frame.origin.x, 0+chargesPerHour.frame.size.height, self.view.frame.size.width-90, self.timeLbl.frame.size.height);
    scrollview.frame=CGRectMake(0, 0+chargesPerHour.frame.size.height+dayLabel.frame.size.height, self.view.frame.size.width,  self.view.frame.size.height-179);
    bottomView.frame=CGRectMake(0, self.scrollview.frame.origin.y+self.scrollview.frame.size.height, self.view.frame.size.width, self.bottomView.frame.size.height);
    previousDayBtn.frame=CGRectMake(0, 0, previousDayBtn.frame.size.width, previousDayBtn.frame.size.height);
    nextDayBtn.frame=CGRectMake(self.view.frame.size.width-43, 0, nextDayBtn.frame.size.width, nextDayBtn.frame.size.height);
    calenderDateOutlet.frame=CGRectMake((self.bottomView.frame.size.width/2)-86, 0, calenderDateOutlet.frame.size.width, calenderDateOutlet.frame.size.height);
    
}

-(void) dealloc
{
    dateValue=nil;
    bookingListArray=nil;
    frameDic=nil;
}

#pragma mark - end

#pragma mark - Customcalendar method
//Method to make service provider calendar
-(void)customCalanderMethod
{
    dateValue=[NSMutableArray new];
    frameDic=[NSMutableDictionary new];
    value=0;
    bookingListArray=[spCalenderData.bookingsList mutableCopy];
    slotStartTime=spCalenderData.businessStartHours;
    NSArray *startdate=[self stringColonSeparation:slotStartTime];
    start=[[startdate objectAtIndex:0] intValue];
    startMin=[[startdate objectAtIndex:1] intValue];
    if ([spCalenderData.businessEndHours isEqualToString:@"23:59"]) {
        slotEndTime=@"24:00";
    }
    else
    {
        slotEndTime=spCalenderData.businessEndHours;
    }
    NSArray *enddate=[self stringColonSeparation:slotEndTime];
    last=[[enddate objectAtIndex:0] intValue];
    lastMin=[[enddate objectAtIndex:1] intValue];
    if (last==0 && start!=0)
    {
        last=24;
    }
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
    NSDate *date = [dateFormatter dateFromString:slotStartTime];
    for (int i=0; i<value; i++) {
        [dateValue addObject:[[dateFormatter stringFromDate:date] lowercaseString]];
        date=[date dateByAddingTimeInterval:60*30];
    }
    if (dateValue.count<1)
    {
        noSPAvailLbl.hidden = NO;
    }
    else
    {
        noSPAvailLbl.hidden = YES;
        
    }
    if (value*40>self.scrollview.frame.size.height)
        bookingDisplayView.frame=CGRectMake(0, 0,self.scrollview.frame.size.width, value*40);
    else
        bookingDisplayView.frame=CGRectMake(0, 0,self.scrollview.frame.size.width, self.scrollview.frame.size.height);
        scrollview.contentInset = UIEdgeInsetsMake(0, 0, self.bookingDisplayView.frame.size.height, 0);
        for (int i=0; i<value; i++) {
        [self customLabelMethod:i];
    }
    for (int i=0;i<bookingListArray.count;i++)
    {
        NSMutableDictionary *dataDic=[bookingListArray objectAtIndex:i];
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [dateFormatter1 setLocale:locale];
        dateFormatter1.dateFormat = @"HH:mm";
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
        NSString *dateChecker=[[dateFormatter1 stringFromDate:date1] lowercaseString];
        if ([frameDic objectForKey:dateChecker]!=nil) {
            NSString *buttonFrams=[frameDic objectForKey:dateChecker];
            CGRect rect = CGRectFromString(buttonFrams);
            UIButton *but= [[UIButton alloc]initWithFrame:CGRectMake(90, rect.origin.y, self.view.frame.size.width-90, 40*timeIntervalInt)];
            [but setTitle:@"Unavailable" forState:UIControlStateNormal];
            [but.titleLabel setNumberOfLines:2];
            but.titleLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:16];
            [but setTitleColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            but.backgroundColor=[UIColor colorWithRed:150.0/255.0 green:150/255.0 blue:150.0/255.0 alpha:1.0];
            [[but layer] setBorderWidth:0.3f];
            [[but layer] setBorderColor:[UIColor colorWithRed:168.0/255.0 green:167.0/255.0 blue:166.0/255.0 alpha:1.0].CGColor];
            but.tag=i;
            [self.bookingDisplayView addSubview:but];
        }
    }
}
//Method to create labels to display time and booking status
-(void)customLabelMethod:(int)iValue
{
    UILabel *time=[[UILabel alloc]initWithFrame:CGRectMake(0, iValue*40, 90, 40)];
    time.backgroundColor=[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    time.textAlignment=NSTextAlignmentCenter;
    time.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    time.textColor=[UIColor darkGrayColor];
    time.text=[dateValue objectAtIndex:iValue];
    [self.bookingDisplayView addSubview:time];
    UILabel *jobs=[[UILabel alloc]initWithFrame:CGRectMake(90, iValue*40, self.view.frame.size.width-90, 40)];
    if (iValue%2==0)
        jobs.backgroundColor=[UIColor whiteColor];
    else
        jobs.backgroundColor=[UIColor colorWithRed:244.0/255.0 green:243.0/255.0 blue:242.0/255.0 alpha:1.0];
    jobs.textAlignment=NSTextAlignmentCenter;
    jobs.textColor=[UIColor colorWithRed:110.0/255.0 green:110.0/255.0 blue:110.0/255.0 alpha:1.0];
    jobs.font= [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    jobs.text=@"+";
    CGRect frame=jobs.frame;
    [frameDic setObject:NSStringFromCGRect(frame) forKey:time.text];
    [self.bookingDisplayView addSubview:jobs];
    UIButton *but= [[UIButton alloc]initWithFrame:CGRectMake(90, iValue*40, self.view.frame.size.width-90, 40)];
    [but addTarget:self action:@selector(bookingRequest:) forControlEvents:UIControlEventTouchUpInside];
    but.backgroundColor=[UIColor clearColor];
    but.tag=iValue;
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
    double tempdate=[advanceBookingHrs doubleValue];
    NSString * strNewDate=[NSString stringWithFormat:@"%.1f",tempdate];
    NSArray *startdate=[strNewDate componentsSeparatedByString:@"."];
    int hours  =[[startdate objectAtIndex:0] intValue];
    int min   =[[startdate objectAtIndex:1] intValue];
    if (min==5)
    {
        min=30;
    }
    else
    {
        min=0;
    }
    int hoursToAdd = hours;
    int minsToAdd=min;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:hoursToAdd];
    [components setMinute:minsToAdd];
    NSDate *newDate= [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    strNewDate = [dateFormatter1 stringFromDate:newDate];
    currentTime=strNewDate;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned unitFlagsDate = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *dateComponents = [gregorian components:unitFlagsDate fromDate:serverDate];
    unsigned unitFlagsTime = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;
    NSDateComponents *timeComponents = [gregorian components:unitFlagsTime fromDate:[dateFormatter1 dateFromString:[dateValue objectAtIndex:iValue]]];
    [dateComponents setSecond:[timeComponents second]];
    [dateComponents setHour:[timeComponents hour]];
    [dateComponents setMinute:[timeComponents minute]];
    NSDate *combDate = [gregorian dateFromComponents:dateComponents];
    if (([serverDate compare:currentDate] == NSOrderedAscending) )
    {
        but.enabled=NO;
        jobs.text=@"Unavailable";
        jobs.font=[UIFont fontWithName:@"HelveticaNeue" size:14.0];
        jobs.alpha = 0.4;
    }
    else if (([combDate compare:newDate] == NSOrderedAscending))
    {
        but.enabled=NO;
        jobs.text=@"Unavailable";
        jobs.font=[UIFont fontWithName:@"HelveticaNeue" size:14.0];
    }
    [self.bookingDisplayView addSubview:but];
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
#pragma mark - end

#pragma mark - Webservice Methods
//Method to get service provider calender from server
-(void) getBookingCalenderFromWebservice
{
    if (dateString!=nil)
    {
        [[WebService sharedManager] getSpCalender:serviceProviderID date:dateString success:^(id spCalenderModel)
         {
             spCalenderData=[[BookingCalenderDataModel alloc]init];
             spCalenderData=spCalenderModel;
             
             [scrollview addSubview:bookingDisplayView];
             [self customCalanderMethod];
             
         } failure:^(NSError *error)
         {
         }];
    }
}
#pragma mark - end

#pragma mark - Button action
//Method to go to booking request screen
- (IBAction) bookingRequest: (id)sender
{
    slotStartTime=[dateValue objectAtIndex:[sender tag]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    dateFormatter.dateFormat = @"HH:mm";
    NSDate *date = [dateFormatter dateFromString:slotStartTime];
    slotStartTime = [dateFormatter stringFromDate:date];
    date=[date dateByAddingTimeInterval:60*30];
    slotEndTime=[dateFormatter stringFromDate:date];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BookingRequestController *objBookingRequest =[storyboard instantiateViewControllerWithIdentifier:@"BookingRequestController"];
    objBookingRequest.serviceNameStr=serviceName;
    objBookingRequest.serviceCharges=serviceCharges;
    objBookingRequest.serviceId=serviceId;
    objBookingRequest.serviceTypeStr=serviceType;
    objBookingRequest.serviceDate=dateString;
    objBookingRequest.startTime=slotStartTime;
    objBookingRequest.endTime=slotEndTime;
    objBookingRequest.serviceSlotHrs=[serviceSlotHour doubleValue];
    objBookingRequest.calenderData=spCalenderData;
    objBookingRequest.serviceProviderID=serviceProviderID;
    [self.navigationController pushViewController:objBookingRequest animated:YES];
}
//Method to get previous day calendar of sp
- (IBAction)previousDayAction:(UIButton *)sender
{
    NSArray *viewsToRemove = [self.bookingDisplayView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self setMaximumDate];
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
    [calenderDateOutlet setTitle:[myDelegate formatDateToDisplay:newDate] forState:UIControlStateNormal];
    [self checkPreviousDate];
    [dateFormatter1 setDateFormat:@"EEEE"];
    dayLabel.text=[[dateFormatter1 stringFromDate:newDate] uppercaseString];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getBookingCalenderFromWebservice) withObject:nil afterDelay:.2];
}

//Method to get next day calendar of sp
- (IBAction)nextDayAction:(UIButton *)sender
{
    previousDayBtn.enabled=YES;
    NSArray *viewsToRemove = [self.bookingDisplayView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self setMaximumDate];
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
    [calenderDateOutlet setTitle:[myDelegate formatDateToDisplay:newDate] forState:UIControlStateNormal];
    [self checkPreviousDate];
    [dateFormatter1 setDateFormat:@"EEEE"];
    dayLabel.text=[[dateFormatter1 stringFromDate:newDate] uppercaseString];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getBookingCalenderFromWebservice) withObject:nil afterDelay:.2];
}
//Method to check if previous date is smaller then current date
-(void)checkPreviousDate
{
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter1 setLocale:locale];
    [dateFormatter1 setDateFormat:@"dd MMM yyyy"];
    NSString *currentDate=[dateFormatter1 stringFromDate:[NSDate date]];
    NSString *calenderDate=[calenderDateOutlet titleForState:UIControlStateNormal];
    if ([calenderDate isEqualToString:currentDate])
    {
        previousDayBtn.enabled=NO;
        nextDayBtn.enabled=YES;
    }
    else if([calenderDate isEqualToString:maximumDate])
    {
        nextDayBtn.enabled=NO;
    }
    else
    {
        nextDayBtn.enabled=YES;
    }
}
//Method to set the window date for booking
-(void) setMaximumDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = [advanceBookingDays integerValue];
    NSDate *newDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    datePicker.minimumDate=[NSDate date];
    datePicker.maximumDate=newDate;
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter1 setLocale:locale];
    [dateFormatter1 setDateFormat:@"dd MMM yyyy"];
    maximumDate=[dateFormatter1 stringFromDate:newDate];
}

#pragma mark - end

#pragma mark - Picker methods
//Method to show date picker
- (IBAction)calanderPicker:(UIButton *)sender
{
    previousDayBtn.enabled=YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    datePicker.backgroundColor=[UIColor whiteColor];
    datePicker.minimumDate=[NSDate date];
    [self setMaximumDate];
    datePicker.frame = CGRectMake(datePicker.frame.origin.x, self.view.frame.size.height-datePicker.frame.size.height , self.view.frame.size.width, datePicker.frame.size.height);
    pickerToolBar.backgroundColor=[UIColor whiteColor];
    pickerToolBar.frame = CGRectMake(pickerToolBar.frame.origin.x, datePicker.frame.origin.y-44, self.view.frame.size.width, pickerToolBar.frame.size.height);
    [UIView commitAnimations];
}
//Method to hide date picker
-(void)hidePickerWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    datePicker.frame = CGRectMake(datePicker.frame.origin.x, 1000, self.view.frame.size.width, datePicker.frame.size.height);
    pickerToolBar.frame = CGRectMake(pickerToolBar.frame.origin.x, 1000, self.view.frame.size.width, pickerToolBar.frame.size.height);
    [UIView commitAnimations];
}
//Method for toolbar cancel action
- (IBAction)toolBarCancelAction:(id)sender
{
    [self hidePickerWithAnimation];
    [self checkPreviousDate];
}
//Method for toolbar done action
- (IBAction)toolBarDoneAction:(id)sender
{
    NSArray *viewsToRemove = [self.bookingDisplayView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self setMaximumDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"dd-MMMM-YYYY"];
    dateString = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:datePicker.date]];
    [calenderDateOutlet setTitle:[myDelegate formatDateToDisplay:datePicker.date] forState:UIControlStateNormal];
    [self checkPreviousDate];
    [dateFormatter setDateFormat:@"EEEE"];
    dayLabel.text=[[dateFormatter stringFromDate:datePicker.date]uppercaseString];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getBookingCalenderFromWebservice) withObject:nil afterDelay:.2];
    [self hidePickerWithAnimation];
}
#pragma mark - end

@end
