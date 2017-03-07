//
//  RequestDetailViewController.m
//  Sure
//
//  Created by Hema on 24/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "RequestDetailViewController.h"
#import "RequestSentCell.h"
#import "ASStarRatingView.h"
#import "ServiceProviderViewController.h"
#import "BookingDetailDataModel.h"
#import "SWRevealViewController.h"
#import <UIImageView+AFNetworking.h>
#import <EventKit/EventKit.h>
#import "JNKeychain.h"


@interface RequestDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIBarButtonItem *backMenuButton,*menuButton;
    NSString *serviceStartTime;
    NSString *serviceEndTime;
    NSString *dateString;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *innerTopView;
@property (weak, nonatomic) IBOutlet UILabel *acceptedBookingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *approvedRejectedCheckImage;
@property (weak, nonatomic) IBOutlet UIButton *tryOtherServices;
@property (weak, nonatomic) IBOutlet UILabel *acceptRejectLabel;
@property (weak, nonatomic) IBOutlet UITableView *requestDetailTableView;
@property (weak, nonatomic) IBOutlet UIButton *confirmService;
@property (weak, nonatomic) IBOutlet UIButton *cancelApprovedBooking;
@property (weak, nonatomic) IBOutlet UIView *approvedButtonView;
@property (weak, nonatomic) IBOutlet UIView *innerBottomView;
@property (weak, nonatomic) IBOutlet UIView *bookingDetailView;
@property (weak, nonatomic) IBOutlet UILabel *bookingServiceName;
@property (weak, nonatomic) IBOutlet UILabel *bookingServiceType;
@property (weak, nonatomic) IBOutlet UILabel *bookingServiceHour;
@property (weak, nonatomic) IBOutlet UIImageView *bookingTimeImage;
@property (weak, nonatomic) IBOutlet UIImageView *bookingServiceTypeImage;
@property (weak, nonatomic) IBOutlet UIView *bookingDateView;
@property (weak, nonatomic) IBOutlet UILabel *bookingDate;
@property (weak, nonatomic) IBOutlet UILabel *bookingTime;
@property (weak, nonatomic) IBOutlet UIButton *cancelBookingOutlet;
@property(strong, nonatomic) NSString *bookingID;

@end

@implementation RequestDetailViewController
@synthesize scrollView,mainView,innerBottomView,innerTopView,acceptedBookingLabel,approvedRejectedCheckImage,requestDetailTableView,bookingDate,bookingDateView,bookingDetailView,bookingServiceHour,bookingServiceName,bookingServiceType,bookingServiceTypeImage,bookingTime,bookingTimeImage,cancelBookingOutlet;
@synthesize sectionData,tableData,bookingID,selectedIndex;
@synthesize tryOtherServices,confirmService,cancelApprovedBooking,approvedButtonView;
@synthesize status,acceptRejectLabel,pushBookingID;


#pragma mark - left navigaton bar button
- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage secondImage:(UIImage *)menuImage {
    CGRect framing = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
    UIButton *menu = [[UIButton alloc] initWithFrame:framing];
    [menu setBackgroundImage:menuImage forState:UIControlStateNormal];
    menuButton =[[UIBarButtonItem alloc] initWithCustomView:menu];
    framing = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:framing];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    backMenuButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([myDelegate.superClassView isEqualToString:@"sureView"]) {
        self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:menuButton, nil];
        
    }
    else{
        self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:backMenuButton,menuButton, nil];
    }
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [menu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(void)backButtonAction :(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - end

#pragma mark - view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] secondImage:[UIImage imageNamed:@"menu.png"]];
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    requestDetailTableView.dataSource =self;
    requestDetailTableView.delegate =self;
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    [self removeAutolayout];
    self.scrollView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.requestDetailTableView.frame=CGRectMake(0, 75, self.scrollView.frame.size.width, 100+(sectionData.serviceList.count*30)+22);
    [self innerTopViewLayout];
    [self innerbottomViewLayout];
    [self addShadowOnButton];
    [self getServiceData];
    
    if ([status intValue]==1)
    {
        self.title = @"Pending Confirmation";
        approvedButtonView.hidden=NO;
        cancelBookingOutlet.hidden=YES;
        approvedRejectedCheckImage.hidden=NO;
        approvedRejectedCheckImage.image=[UIImage imageNamed:@"click"];
        acceptRejectLabel.text=@"The following booking has been accepted by the service provider.";
        acceptedBookingLabel.hidden=YES;
        
    }
    else
    {
        self.title = @"Request Detail";
        approvedButtonView.hidden=YES;
        tryOtherServices.hidden=YES;
        approvedRejectedCheckImage.hidden=YES;
        acceptRejectLabel.hidden=YES;
        cancelBookingOutlet.hidden=NO;
        
    }
}

-(void)getServiceData
{
    bookingServiceName.text=tableData.serviceName;
    bookingServiceHour.text=tableData.serviceCharge;
    bookingID=tableData.bookingId;
    if ([tableData.serviceType intValue]==1)
        bookingServiceType.text=@"On-Site Service";
    
    else
        bookingServiceType.text=@"In-Shop Service";
    
    bookingDate.text=[myDelegate formatDateToDisplay:tableData.bookingDate];
    dateString=tableData.bookingDate;
    if ([tableData.endTime isEqualToString:@"23:59"]) {
        tableData.endTime=@"24:00";
    }
    bookingTime.text=[NSString stringWithFormat:@"%@ - %@",tableData.startTime,tableData.endTime];
    serviceStartTime=tableData.startTime;
    serviceEndTime=tableData.endTime;
    //cancelBookingOutlet.hidden=YES;
}

-(void)clearData
{
    bookingServiceName.text=@"";
    bookingServiceHour.text=@"";
    bookingID=@"";
    bookingServiceType.text=@"";
    bookingDate.text=@"";
    bookingTime.text=@"";
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if (myDelegate.messageType==2 || myDelegate.messageType==3)
    {
        [self clearData];
        myDelegate.messageType=0;
        bookingID=myDelegate.bookingId;
        [myDelegate ShowIndicator];
        [self performSelector:@selector(bookingResponseFromServer) withObject:nil afterDelay:0.1];
    }
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        // iOS 6 and later
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
            
            } else {
                // code here for when the user does NOT allow your app to access the calendar
            }
        }];
    } else {
       
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - end

#pragma mark - Setframes of objects

-(void) removeAutolayout
{
    self.scrollView.translatesAutoresizingMaskIntoConstraints=YES;
    self.mainView.translatesAutoresizingMaskIntoConstraints=YES;
    self.innerTopView.translatesAutoresizingMaskIntoConstraints=YES;
    self.acceptedBookingLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.approvedRejectedCheckImage.translatesAutoresizingMaskIntoConstraints=YES;
    self.requestDetailTableView.translatesAutoresizingMaskIntoConstraints=YES;
    self.innerBottomView.translatesAutoresizingMaskIntoConstraints=YES;
    self.bookingDetailView.translatesAutoresizingMaskIntoConstraints=YES;
    self.bookingServiceName.translatesAutoresizingMaskIntoConstraints=YES;
    self.bookingServiceType.translatesAutoresizingMaskIntoConstraints=YES;
    self.bookingServiceHour.translatesAutoresizingMaskIntoConstraints=YES;
    self.bookingTimeImage.translatesAutoresizingMaskIntoConstraints=YES;
    self.bookingServiceTypeImage.translatesAutoresizingMaskIntoConstraints=YES;
    self.bookingDateView.translatesAutoresizingMaskIntoConstraints=YES;
    self.bookingDate.translatesAutoresizingMaskIntoConstraints=YES;
    self.bookingTime.translatesAutoresizingMaskIntoConstraints=YES;
    self.cancelBookingOutlet.translatesAutoresizingMaskIntoConstraints=YES;
    self.tryOtherServices.translatesAutoresizingMaskIntoConstraints=YES;
    self.cancelApprovedBooking.translatesAutoresizingMaskIntoConstraints=YES;
    self.confirmService.translatesAutoresizingMaskIntoConstraints=YES;
    self.approvedButtonView.translatesAutoresizingMaskIntoConstraints=YES;
    self.acceptRejectLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.approvedRejectedCheckImage.translatesAutoresizingMaskIntoConstraints=YES;
    
}
-(void)innerTopViewLayout
{
    self.innerTopView.frame=CGRectMake(0, 0, self.scrollView.frame.size.width, 75);
    self.acceptedBookingLabel.frame=CGRectMake(12, 6, self.scrollView.frame.size.width-24, 60);
    self.approvedRejectedCheckImage.frame=CGRectMake(approvedRejectedCheckImage.frame.origin.x, approvedRejectedCheckImage.frame.origin.y, approvedRejectedCheckImage.frame.size.width, approvedRejectedCheckImage.frame.size.height);
    self.acceptRejectLabel.frame=CGRectMake(approvedRejectedCheckImage.frame.origin.x+approvedRejectedCheckImage.frame.size.width+3, 6, self.scrollView.frame.size.width-46, 60);
}

-(void)innerbottomViewLayout
{
    self.innerBottomView.frame=CGRectMake(0, requestDetailTableView.frame.origin.y+requestDetailTableView.frame.size.height, self.scrollView.frame.size.width, innerBottomView.frame.size.height);
    self.bookingDetailView.frame=CGRectMake(10, 13, (self.innerBottomView.frame.size.width/2)-14, bookingDetailView.frame.size.height);
    self.bookingDateView.frame=CGRectMake((self.innerBottomView.frame.size.width/2)+4, 13, (self.innerBottomView.frame.size.width/2)-14, bookingDateView.frame.size.height);
    self.bookingServiceName.frame=CGRectMake(self.bookingServiceName.frame.origin.x, self.bookingServiceName.frame.origin.y, self.bookingDetailView.frame.size.width-10, self.bookingServiceName.frame.size.height);
    self.bookingServiceType.frame=CGRectMake(self.bookingServiceType.frame.origin.x, self.bookingServiceType.frame.origin.y, self.bookingDetailView.frame.size.width-self.bookingServiceType.frame.origin.x, self.bookingServiceType.frame.size.height);
    self.bookingDate.frame=CGRectMake(self.bookingDate.frame.origin.x, self.bookingDate.frame.origin.y, self.bookingDateView.frame.size.width, self.bookingDate.frame.size.height);
    self.bookingTime.frame=CGRectMake(self.bookingTime.frame.origin.x, self.bookingTime.frame.origin.y, self.bookingDateView.frame.size.width, self.bookingTime.frame.size.height);
    self.cancelBookingOutlet.frame=CGRectMake(self.bookingDateView.frame.origin.x, cancelBookingOutlet.frame.origin.y, self.bookingDateView.frame.size.width, cancelBookingOutlet.frame.size.height);
    self.tryOtherServices.frame=CGRectMake(36, tryOtherServices.frame.origin.y, self.view.frame.size.width-72, tryOtherServices.frame.size.height);
    self.approvedButtonView.frame=CGRectMake(approvedButtonView.frame.origin.x, approvedButtonView.frame.origin.y, self.view.frame.size.width, approvedButtonView.frame.size.height);
    self.cancelApprovedBooking.frame=CGRectMake(10, 0, (innerBottomView.frame.size.width/2)-14, cancelApprovedBooking.frame.size.height);
    self.confirmService.frame=CGRectMake(self.bookingDateView.frame.origin.x, 0, (innerBottomView.frame.size.width/2)-14, confirmService.frame.size.height);
    self.mainView.frame=CGRectMake(0, 0, self.scrollView.frame.size.width, self.innerBottomView.frame.origin.y+self.innerBottomView.frame.size.height);
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.mainView.frame.size.height, 0);
}

-(void)addShadowOnButton
{
    [cancelBookingOutlet.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [cancelBookingOutlet.layer setShadowOpacity:1.0];
    [cancelBookingOutlet.layer setShadowRadius:2.0];
    [cancelBookingOutlet.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [cancelBookingOutlet.layer setBorderWidth:1.0];
    [cancelBookingOutlet.layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0])];
    [cancelBookingOutlet.layer setCornerRadius:1.0];
    [confirmService.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [confirmService.layer setShadowOpacity:1.0];
    [confirmService.layer setShadowRadius:2.0];
    [confirmService.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [confirmService.layer setBorderWidth:1.0];
    [confirmService.layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0])];
    [confirmService.layer setCornerRadius:1.0];
    [cancelApprovedBooking.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [cancelApprovedBooking.layer setShadowOpacity:1.0];
    [cancelApprovedBooking.layer setShadowRadius:2.0];
    [cancelApprovedBooking.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [cancelApprovedBooking.layer setBorderWidth:1.0];
    [cancelApprovedBooking.layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0])];
    [cancelApprovedBooking.layer setCornerRadius:1.0];
    [tryOtherServices.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [tryOtherServices.layer setShadowOpacity:1.0];
    [tryOtherServices.layer setShadowRadius:2.0];
    [tryOtherServices.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [tryOtherServices.layer setBorderWidth:1.0];
    [tryOtherServices.layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0])];
    [tryOtherServices.layer setCornerRadius:1.0];
}
#pragma mark - end

#pragma mark - Table view delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return sectionData.serviceList.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"requestCell";
    
    RequestSentCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[RequestSentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    [cell layoutView:self.view.frame];
    if (selectedIndex==indexPath.row)
    {
        cell.ServiceName.font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        cell.ServiceCharge.font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    }
    else
    {
        cell.ServiceName.font=[UIFont fontWithName:@"HelveticaNeue" size:13];
        cell.ServiceCharge.font=[UIFont fontWithName:@"HelveticaNeue" size:13];
    }
    if (sectionData.serviceList.count==(indexPath.row))
    {
        cell.ServiceName.text=@"";
        cell.ServiceCharge.text=@"";
        cell.innerView.hidden=YES;
        cell.separator.hidden=NO;
        cell.bottomView.hidden=NO;
    }
    else
    {
        NSMutableArray *tempArray=[NSMutableArray new];
        tempArray=[sectionData.serviceList mutableCopy];
        tableData=[ServiceListModel new];
        tableData=[tempArray objectAtIndex:indexPath.row];
        cell.ServiceName.text=tableData.serviceName;
        cell.ServiceCharge.text=tableData.serviceCharge;
        cell.innerView.hidden=NO;
        cell.separator.hidden=YES;
        cell.bottomView.hidden=YES;
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    //    return 110;
    return 110;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    if (sectionData.serviceList.count==(indexPath.row))
    {
        return 22;
    }
    else
    {
        return 30;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView;
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 110.0)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIImageView * serviceProviderimage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 70, 70)];
    serviceProviderimage.backgroundColor = [UIColor clearColor];
    serviceProviderimage.layer.cornerRadius=35.0f;
    serviceProviderimage.clipsToBounds=YES;
    NSString *tempUrl=sectionData.profileImage;
    
    __weak UIImageView *weakRef = serviceProviderimage;
    
    [serviceProviderimage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tempUrl]] placeholderImage:[UIImage imageNamed:@"profile_placehoder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakRef.contentMode = UIViewContentModeScaleAspectFill;
         weakRef.image = image;
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];
    
    [headerView addSubview:serviceProviderimage];
    
    
    UILabel * booking = [[UILabel alloc] initWithFrame:CGRectMake(headerView.frame.size.width-105, serviceProviderimage.frame.origin.y+10+30, 110, 30)];
    booking.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    booking.textAlignment=NSTextAlignmentCenter;
    booking.textColor=[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
    booking.layer.cornerRadius=6.0;
    booking.clipsToBounds=YES;
    if ([sectionData.bookingCount intValue]>1)
    {
        booking.text = [NSString stringWithFormat:@"%@ Bookings",sectionData.bookingCount];
    }
    else
    {
        booking.text = [NSString stringWithFormat:@"%@ Booking",sectionData.bookingCount];
    }
    
    booking.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    [headerView addSubview:booking];
    
    ASStarRatingView * staticStarRatingView;
    staticStarRatingView = [[ASStarRatingView alloc] initWithFrame:CGRectMake(headerView.frame.size.width-105, booking.frame.origin.y-30, 104, 30)];
    staticStarRatingView.backgroundColor = [UIColor clearColor];
    staticStarRatingView.backgroundColor = [UIColor clearColor];
    staticStarRatingView.canEdit=NO;
    staticStarRatingView.leftMargin=2.5;
    staticStarRatingView.midMargin=2;
    staticStarRatingView.maxRating = 5;
    staticStarRatingView.rating = [sectionData.rating floatValue];
    staticStarRatingView.minAllowedRating = .5;
    staticStarRatingView.maxAllowedRating = 5;
    
    [headerView addSubview:staticStarRatingView];
    
    
    UILabel * serviceProviderName = [[UILabel alloc] initWithFrame:CGRectMake( serviceProviderimage.frame.origin.x+serviceProviderimage.frame.size.width+13, staticStarRatingView.frame.origin.y-20, 111, 40)];
    serviceProviderName.translatesAutoresizingMaskIntoConstraints=YES;
    serviceProviderName.font=[UIFont fontWithName:@"HelveticaNeue" size:15];
    serviceProviderName.numberOfLines = 3;
    
    CGSize size = CGSizeMake(111,999);
    CGRect textRect = [sectionData.name
                       boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:16]}
                       context:nil];
    
    textRect.origin.x = serviceProviderName.frame.origin.x-5;
    textRect.origin.y = serviceProviderName.frame.origin.y+10;
    serviceProviderName.frame = textRect;
    serviceProviderName.text=sectionData.name;
    serviceProviderName.textColor=[UIColor colorWithRed:255.0/255.0 green:63.0/255.0 blue:64.0/255.0 alpha:1.0];
    [headerView addSubview:serviceProviderName];
    
    
    UILabel * businessName = [[UILabel alloc] initWithFrame:CGRectMake( serviceProviderName.frame.origin.x, serviceProviderName.frame.size.height+15, headerView.frame.size.width-(serviceProviderimage.frame.origin.x+serviceProviderimage.frame.size.width+10)-staticStarRatingView.frame.size.width-5, 40)];
    businessName.translatesAutoresizingMaskIntoConstraints=YES;
    businessName.backgroundColor = [UIColor clearColor];
    businessName.textAlignment=NSTextAlignmentLeft;
    businessName.numberOfLines=2;
    businessName.textColor=[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
    businessName.text=sectionData.businessName;
    businessName.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    [headerView addSubview:businessName];
     return headerView;

}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (sectionData.serviceList.count!=(indexPath.row))
    {
        selectedIndex=(int)indexPath.row;
        
        NSMutableArray *tempArray=[sectionData.serviceList mutableCopy];
        if (indexPath.row<tempArray.count)
        {
            tableData=[tempArray objectAtIndex:indexPath.row];
            bookingServiceName.text=tableData.serviceName;
            bookingServiceHour.text=tableData.serviceCharge;
            bookingID=tableData.bookingId;
            if ([tableData.serviceType intValue]==1)
                bookingServiceType.text=@"On-Site Service";
            
            else
                bookingServiceType.text=@"In-Shop Service";
            
            bookingDate.text=[myDelegate formatDateToDisplay:tableData.bookingDate];
            dateString=tableData.bookingDate;
            if ([tableData.endTime isEqualToString:@"23:59"]) {
                tableData.endTime=@"24:00";
            }
            bookingTime.text=[NSString stringWithFormat:@"%@ - %@",tableData.startTime,tableData.endTime];
            serviceStartTime=tableData.startTime;
            serviceEndTime=tableData.endTime;
        }
        
        [tableView reloadData];
    }
}


#pragma mark - end

#pragma mark - Button actions

- (IBAction)cancelBookingButtonAction:(id)sender
{
    [myDelegate ShowIndicator];
    [self performSelector:@selector(cancelBookingFromServer) withObject:nil afterDelay:0.1];
}
#pragma mark - end

#pragma mark - Webservice Methods

-(void)bookingResponseFromServer
{
    [[WebService sharedManager] bookingResponse:bookingID success:^(id bookingDetailDataModel)
     {
         NSMutableArray *dataArray = [NSMutableArray new];
         
         NSMutableArray *detailArray=[bookingDetailDataModel mutableCopy];
         BookingDetailDataModel *data = [detailArray objectAtIndex:0];
         RequestSentModel * reqSent = [[RequestSentModel alloc]init];
         reqSent.bookingCount =data.bookingCount;
         reqSent.businessName =data.businessName;
         reqSent.name =data.name;
         reqSent.profileImage=data.profileImage;
         reqSent.rating =data.rating;
         reqSent.serviceProviderId=data.serviceProviderId;
         reqSent.serviceList = [[NSMutableArray alloc]init];
         ServiceListModel * objServiceList = [[ServiceListModel alloc]init];
         objServiceList.serviceName =data.serviceName;
         objServiceList.serviceCharge=data.serviceCharges;
         objServiceList.serviceType =data.serviceType;
         objServiceList.startTime =data.startTime;
         objServiceList.endTime =data.endTime;
         objServiceList.bookingDate = data.bookingDate;
         [reqSent.serviceList addObject:objServiceList];
         status=data.status;
         [dataArray addObject:reqSent];
         sectionData=[dataArray objectAtIndex:0];
         tableData=[sectionData.serviceList objectAtIndex:0];
         [self parseData];
         [myDelegate StopIndicator];
         
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
     }] ;
    
}

-(void)parseData
{
    tableData=[sectionData.serviceList objectAtIndex:0];
    bookingServiceName.text=tableData.serviceName;
    bookingServiceHour.text=tableData.serviceCharge;
    if ([tableData.serviceType intValue]==1)
        bookingServiceType.text=@"On-Site Service";
    else
        bookingServiceType.text=@"In-Shop Service";
    
    bookingDate.text=[myDelegate formatDateToDisplay:tableData.bookingDate];
    dateString=tableData.bookingDate;
    if ([tableData.endTime isEqualToString:@"23:59"]) {
        tableData.endTime=@"24:00";
    }
    bookingTime.text=[NSString stringWithFormat:@"%@ - %@",tableData.startTime,tableData.endTime];
    serviceStartTime=tableData.startTime;
    serviceEndTime=tableData.endTime;
    if ([status intValue]==4)
    {
        self.title = @"Request Detail";
        approvedButtonView.hidden=NO;
        tryOtherServices.hidden=YES;
        approvedRejectedCheckImage.hidden=NO;
        approvedRejectedCheckImage.image=[UIImage imageNamed:@"click"];
        acceptRejectLabel.hidden=NO;
        acceptRejectLabel.text=@"The following booking has been accepted by the service provider.";
        cancelBookingOutlet.hidden=YES;
        acceptedBookingLabel.hidden=YES;
    }
    else if ([status intValue]==5)
    {
        self.title = @"Request Detail";
        approvedButtonView.hidden=YES;
        tryOtherServices.hidden=NO;
        approvedRejectedCheckImage.hidden=NO;
        approvedRejectedCheckImage.image=[UIImage imageNamed:@"close_rej"];
        acceptRejectLabel.hidden=NO;
        acceptRejectLabel.textColor=[UIColor colorWithRed:253.0/255.0 green:68.0/255.0 blue:63.0/255.0 alpha:1.0];
        acceptRejectLabel.text=@"The following booking has been rejected by the service provider.";
        cancelBookingOutlet.hidden=YES;
        acceptedBookingLabel.hidden=YES;
    }
    self.requestDetailTableView.frame=CGRectMake(0, 75, self.scrollView.frame.size.width, 110+(sectionData.serviceList.count*30)+22);
    
    self.innerBottomView.frame=CGRectMake(0, requestDetailTableView.frame.origin.y+requestDetailTableView.frame.size.height, self.scrollView.frame.size.width, innerBottomView.frame.size.height);
    [requestDetailTableView reloadData];
}

-(void)cancelBookingFromServer
{
    [[WebService sharedManager] cancelBooking:bookingID success:^(id responseObject)
     {
         [myDelegate StopIndicator];
         UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         alert.tag=1;
         [alert show];
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
     }] ;
}

-(void) confirmBookingFromServer
{
    [[WebService sharedManager] conFirmBooking:bookingID success:^(id responseObject)
     {
         [myDelegate StopIndicator];
         [self reminderAlert];
         [self notifyForRating];
         UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         alert.tag=1;
         [alert show];
      } failure:^(NSError *error) {
         [myDelegate StopIndicator];
     }] ;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - end

#pragma mark - Button action
- (IBAction)tryOtherBookingServiceAction:(id)sender
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ServiceProviderViewController *spList =[storyboard instantiateViewControllerWithIdentifier:@"ServiceProviderViewController"];
    spList.latitude=myDelegate.latitude;
    spList.longitude=myDelegate.longitude;
    spList.searchKey=@"";
    spList.subCatServiceID=@"";
    [self.navigationController pushViewController:spList animated:YES];
}

- (IBAction)confirmBooking:(id)sender
{
    [self performConfirmBookingValidations];
}
#pragma mark - end

#pragma mark - Validations
-(void) performConfirmBookingValidations
{
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
        UIAlertView*  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You cannot confirm this booking as service time has passed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if (([serverDate compare:currentDate] != NSOrderedDescending) && [[dateFormatter1 dateFromString:serviceStartTime] compare:[dateFormatter1 dateFromString:currentTime]] == NSOrderedAscending)
    {
        
        UIAlertView*  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You cannot confirm this booking as service time has passed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(confirmBookingFromServer) withObject:nil afterDelay:0.1];
    }
    
}
#pragma mark - end

#pragma mark - Local notification

-(void)reminderAlert
{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"dd MMM yyyy"];
    NSDate *date =[dateFormat dateFromString:bookingDate.text];
    [dateFormat setDateFormat:@"MMM d,yyyy"];
    NSString *fireDate=[dateFormat stringFromDate:date];
    [dateFormat setDateFormat:@"HH:mm"];
    NSDate *fireToTime=[dateFormat dateFromString:serviceStartTime];
    NSDate *fireFromTime;
    NSDate *startDate;
    NSDate *endDate;
    if ([serviceEndTime isEqualToString:@"24:00"]) {
        serviceEndTime=@"23:59";
    }
    fireFromTime = [dateFormat dateFromString:serviceEndTime];
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString *CheckTOTime = [dateFormat stringFromDate:fireToTime];
    NSString *CheckFromTime = [dateFormat stringFromDate:fireFromTime];
    NSString *startdate1= [NSString stringWithFormat:@"%@ %@",fireDate,CheckTOTime];
    NSString *enddate1= [NSString stringWithFormat:@"%@ %@",fireDate,CheckFromTime];
    [dateFormat setDateFormat:@"MMM d,yyyy hh:mm a"];
    startDate = [dateFormat dateFromString:startdate1];
    endDate = [dateFormat dateFromString:enddate1];
    NSTimeInterval interval = 60* -30;
    EKEventStore *eventDB = [[EKEventStore alloc] init];
    EKEvent *myEvent  = [EKEvent eventWithEventStore:eventDB];
    myEvent.title     = @"Booking Appointment";
    myEvent.startDate = startDate;
    myEvent.endDate   = endDate;
    myEvent.allDay = NO;
    myEvent.notes = [NSString stringWithFormat:@"%@ %@ %@ %@",@"You have booking appointment for",bookingServiceName.text,@"at",serviceStartTime];
    [myEvent setCalendar:[eventDB defaultCalendarForNewEvents]];
    EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:interval];
    [myEvent addAlarm:alarm];
    NSError *err;
    NSTimeInterval notiInterval =[startDate timeIntervalSinceDate:[NSDate date]] -30*60;
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:notiInterval];
    notification.alertBody = [NSString stringWithFormat:@"%@ %@ %@ %@",@"You have booking appointment for",bookingServiceName.text,@"at",serviceStartTime];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 0;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:bookingID forKey:@"Calender"];
    notification.userInfo = infoDict;
    NSMutableArray *notifications = [[NSMutableArray alloc] init];
    [notifications addObject:notification];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    [eventDB saveEvent:myEvent span:EKSpanThisEvent error:&err];
    [JNKeychain saveValue:myEvent.eventIdentifier forKey:bookingID];
}


-(void)notifyForRating
{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"dd MMM yyyy"];
    NSDate *date =[dateFormat dateFromString:bookingDate.text];
    [dateFormat setDateFormat:@"MMM d,yyyy"];
    NSString *fireDate=[dateFormat stringFromDate:date];
    [dateFormat setDateFormat:@"HH:mm"];
    NSDate *fireFromTime;
    NSTimeInterval notiInterval;
    if ([serviceEndTime isEqualToString:@"24:00"]) {
        serviceEndTime=@"23:59";
    }
    fireFromTime=[dateFormat dateFromString:serviceEndTime];
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString *CheckTOTime = [dateFormat stringFromDate:fireFromTime];
    NSString *startdate1= [NSString stringWithFormat:@"%@ %@",fireDate,CheckTOTime];
    [dateFormat setDateFormat:@"MMM d,yyyy hh:mm a"];
    NSDate *startDate = [dateFormat dateFromString:startdate1];
    notiInterval =[startDate timeIntervalSinceDate:[NSDate date]];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:notiInterval];
    notification.alertBody = @"Did you enjoy the service? Come and rate the service provider!";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 0;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:bookingID forKey:@"BookingID"];
    notification.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
#pragma mark - end
@end
