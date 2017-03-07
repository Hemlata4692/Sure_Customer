//
//  RatingViewController.m
//  Sure
//
//  Created by Hema on 12/05/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "RatingViewController.h"
#import "EDStarRating.h"
#import "UIPlaceHolderTextView.h"
#import "BookingDetailDataModel.h"
#import <UIImageView+AFNetworking.h>
#import "ASStarRatingView.h"
#import "SearchViewController.h"

@interface RatingViewController ()<EDStarRatingProtocol>
{
    NSString *starRating;
    __weak IBOutlet UIScrollView *scrollView;
}

@property (weak, nonatomic) IBOutlet UITableView *spInfoTableView;
@property (weak, nonatomic) IBOutlet EDStarRating *starRatingView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *commentsTextView;
@property(nonatomic,retain)NSMutableArray * bookingDetailData;
@end

@implementation RatingViewController
@synthesize spInfoTableView,starRatingView,commentsTextView;
@synthesize bookingId,serviceProviderId;
@synthesize  bookingDetailData;

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Rating";
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    bookingDetailData=[[NSMutableArray alloc]init];
    [commentsTextView setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
    [commentsTextView setPlaceholder:@"Comments"];
   [self addstarRating];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(bookingResponseFromServer) withObject:nil afterDelay:0.1];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Add rating methods
-(void) addstarRating
{
    starRatingView.starImage = [UIImage imageNamed:@"light_star.png"];
    starRatingView.starHighlightedImage = [UIImage imageNamed:@"dark_star.png"];
    starRatingView.maxRating = 5.0;
    starRatingView.delegate = self;
    starRatingView.horizontalMargin = 5;
    starRatingView.editable=YES;
    starRatingView.rating= 0;
    starRatingView.displayMode=EDStarRatingDisplayHalf;
    [self starsSelectionChanged:starRatingView rating:0];
}

-(void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating
{
    NSString *ratingString = [NSString stringWithFormat:@"%.1f", rating];
    starRating = ratingString;
}
#pragma mark - end

#pragma mark - Get sp for rating method

-(void)bookingResponseFromServer
{
    bookingId=myDelegate.bookingId;
    
    [[WebService sharedManager] bookingResponse:bookingId success:^(id bookingDetailDataModel)
     {
         [myDelegate StopIndicator];
        bookingDetailData=[bookingDetailDataModel mutableCopy];
         [spInfoTableView reloadData];
     }
    failure:^(NSError *error)
    {
         
     }] ;

}
#pragma mark - end

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return bookingDetailData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"customerFeedback";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    UIImageView *spProfileImage=(UIImageView *)[cell viewWithTag:1];
    UILabel *spName=(UILabel *)[cell viewWithTag:2];
    UILabel *businessName=(UILabel *)[cell viewWithTag:3];
    ASStarRatingView *starView=(ASStarRatingView *)[cell viewWithTag:4];
    UILabel *booking=(UILabel *)[cell viewWithTag:5];
    UILabel *serviceName=(UILabel *)[cell viewWithTag:6];
    UILabel *serviceCharge=(UILabel *)[cell viewWithTag:7];
    booking.layer.cornerRadius=6.0;
    booking.clipsToBounds=YES;
    spProfileImage.layer.cornerRadius=spProfileImage.frame.size.width/2;
    spProfileImage.clipsToBounds=YES;
    spName.translatesAutoresizingMaskIntoConstraints=YES;
    businessName.translatesAutoresizingMaskIntoConstraints=YES;
    BookingDetailDataModel * data = [bookingDetailData objectAtIndex:indexPath.row];
    serviceProviderId=data.serviceProviderId;
    NSString *tempImageString=data.profileImage;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:tempImageString] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    __weak UIImageView *weakRef = spProfileImage;
    [spProfileImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"profile_placehoder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakRef.contentMode = UIViewContentModeScaleAspectFill;
         weakRef.clipsToBounds=YES;
         weakRef.image = image;
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];
    CGSize size = CGSizeMake(135,999);
    CGRect textRect = [data.name
                       boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:16]}
                       context:nil];
    
    textRect.origin.x = spName.frame.origin.x;
    textRect.origin.y = spName.frame.origin.y+10;
    spName.frame = textRect;
    spName.text=data.name;
    businessName.frame=CGRectMake(spName.frame.origin.x,spName.frame.size.height+30,businessName.frame.size.width,businessName.frame.size.height);
    businessName.text=data.businessName;
    if ([data.bookingCount intValue]>1)
    {
        booking.text = [NSString stringWithFormat:@"%@ Bookings",data.bookingCount];
    }
    else
    {
        booking.text = [NSString stringWithFormat:@"%@ Booking",data.bookingCount];
    }
    serviceName.text=data.serviceName;
    serviceCharge.text=data.serviceCharges;
    starView.canEdit=NO;
    starView.leftMargin=0.5;
    starView.midMargin=0.5;
    starView.maxRating = 5;
    starView.rating = [data.rating floatValue];
    starView.minAllowedRating = .5;
    starView.maxAllowedRating = 5;
    return cell;
}
#pragma mark - end

#pragma mark - Give feedback button action

- (IBAction)submitAction:(id)sender
{
    [commentsTextView resignFirstResponder];
    if ([starRating isEqualToString:@"0.0"] || [commentsTextView.text isEqualToString:@""])
    {
        UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please provide rating and feedback for service provider." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
    [myDelegate ShowIndicator];
    [self performSelector:@selector(callCustomerFeedbackWebservice) withObject:nil afterDelay:0.1];
    }

}
#pragma mark - end

#pragma mark - Send feedback to server method
-(void)callCustomerFeedbackWebservice
{
    [[WebService sharedManager] getCustomerFeedback:serviceProviderId rating:starRating comment:commentsTextView.text bookingId:bookingId success:^(id responseObject)
     {
         UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         alert.tag=1;
         [alert show];
         
         
     } failure:^(NSError *error) {
         
     }] ;

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==1 && buttonIndex==0)
    {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SearchViewController *search =[storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
        [self.navigationController pushViewController:search animated:YES];
    }
    
    
}

#pragma mark - end

#pragma mark - Textview delegates

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [scrollView setContentOffset:CGPointMake(0, 220) animated:YES];
    
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(BOOL)textViewShouldBeginEditing: (UITextView *)textView
{
    UIToolbar * keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    
    keyboardToolBar.barStyle = UIBarStyleDefault;
    [keyboardToolBar setItems: [NSArray arrayWithObjects:
                                [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(ressignResponder)],
                                nil]];
    textView.inputAccessoryView = keyboardToolBar;
    
    return YES;
}
-(void)ressignResponder
{
    [commentsTextView resignFirstResponder];
}
#pragma mark - end

@end
