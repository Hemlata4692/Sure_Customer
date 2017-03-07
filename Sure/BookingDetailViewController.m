//
//  BookingDetailViewController.m
//  Sure
//
//  Created by Hema on 29/05/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "BookingDetailViewController.h"
#import "ASStarRatingView.h"
#import "BookingDetailDataModel.h"
#import "BusinessProfileViewController.h"
#import <UIImageView+AFNetworking.h>

@interface BookingDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *spName;
@property (weak, nonatomic) IBOutlet UILabel *businessName;
@property (weak, nonatomic) IBOutlet ASStarRatingView *starRatingView;
@property (weak, nonatomic) IBOutlet UILabel *bookingLabel;
@property (weak, nonatomic) IBOutlet UIView *seviceDetailView;
@property (weak, nonatomic) IBOutlet UIView *serviceDateView;
@property (weak, nonatomic) IBOutlet UILabel *serviceName;
@property (weak, nonatomic) IBOutlet UILabel *serviceType;
@property (weak, nonatomic) IBOutlet UILabel *serviceCharges;
@property (weak, nonatomic) IBOutlet UILabel *bookingDate;
@property (weak, nonatomic) IBOutlet UILabel *bookingTime;
@property(strong, nonatomic)NSMutableArray *bookingDetails;
@property(strong,nonatomic)NSString *serviceProviderID;
@end

@implementation BookingDetailViewController
@synthesize profileImage,spName,businessName,starRatingView,bookingDate,bookingLabel,bookingTime;
@synthesize serviceCharges,serviceName,serviceType,serviceDateView,seviceDetailView;
@synthesize bookingId,bookingDetails,serviceProviderID;

#pragma mark  - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Booking Detail";
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    bookingDetails=[[NSMutableArray alloc]init];
    bookingLabel.layer.cornerRadius=6.0;
    bookingLabel.clipsToBounds=YES;
    profileImage.layer.cornerRadius=profileImage.frame.size.width/2;
    profileImage.clipsToBounds=YES;
    [myDelegate ShowIndicator];
    [self performSelector:@selector(bookingResponseFromServer) withObject:nil afterDelay:0.1];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark  - end

#pragma mark  - Get booking detail from server
//Method to get booking details from server
-(void)bookingResponseFromServer
{
    [[WebService sharedManager] bookingResponse:bookingId success:^(id bookingDetailDataModel)
     {
         [myDelegate StopIndicator];
         bookingDetails=[bookingDetailDataModel mutableCopy];
         [self displayData];
     }
    failure:^(NSError *error)
     {
         
     }] ;
}
//Method to display booking details
-(void)displayData
{
    spName.translatesAutoresizingMaskIntoConstraints=YES;
    businessName.translatesAutoresizingMaskIntoConstraints=YES;
    BookingDetailDataModel * data = [bookingDetails objectAtIndex:0];
    serviceProviderID=data.serviceProviderId;
    NSString *tempImageString=data.profileImage;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:tempImageString] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    __weak UIImageView *weakRef = profileImage;
    [profileImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"profile_placehoder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakRef.contentMode = UIViewContentModeScaleAspectFill;
         weakRef.clipsToBounds=YES;
         weakRef.image = image;
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];
    CGSize size = CGSizeMake(107,999);
    CGRect textRect = [data.name
                       boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:16]}
                       context:nil];
    textRect.origin.x = spName.frame.origin.x;
    textRect.origin.y = 30;
    spName.frame = textRect;
    spName.text=data.name;
    businessName.frame=CGRectMake(spName.frame.origin.x,spName.frame.size.height+30,businessName.frame.size.width,businessName.frame.size.height);
    businessName.text=data.businessName;
    if ([data.bookingCount intValue]>1)
    {
        bookingLabel.text = [NSString stringWithFormat:@"%@ Bookings",data.bookingCount];
    }
    else
    {
        bookingLabel.text = [NSString stringWithFormat:@"%@ Booking",data.bookingCount];
    }
    serviceName.text=data.serviceName;
    serviceCharges.text=data.serviceCharges;
    bookingDate.text=[myDelegate formatDateToDisplay:data.bookingDate];
    if ([data.endTime isEqualToString:@"23:59"]) {
        data.endTime=@"24:00";
    }
    bookingTime.text=[NSString stringWithFormat:@"%@ - %@",data.startTime,data.endTime];
    
    if ([data.serviceType intValue]==1)
        serviceType.text=@"On-Site Service";
    
    else
        serviceType.text=@"In-Shop Service";
    starRatingView.canEdit=NO;
    starRatingView.leftMargin=0.5;
    starRatingView.midMargin=0.5;
    starRatingView.maxRating = 5;
    starRatingView.rating = [data.rating floatValue];
    starRatingView.minAllowedRating = .5;
    starRatingView.maxAllowedRating = 5;
}
#pragma mark  - end

#pragma mark  - IBAction
- (IBAction)bussinessProfileAction:(id)sender
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BusinessProfileViewController *businessProfile =[storyboard instantiateViewControllerWithIdentifier:@"BusinessProfileViewController"];
    businessProfile.serviceProviderID=serviceProviderID;
    [self.navigationController pushViewController:businessProfile animated:YES];
}
#pragma mark  - end
@end
