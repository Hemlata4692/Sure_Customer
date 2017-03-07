//
//  PhotoViewController.m
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "PendingConfirmationViewController.h"
#import "SWRevealViewController.h"
#import "RequestSentCell.h"
#import "ASStarRatingView.h"
#import "RequestDetailViewController.h"
#import "BusinessProfileViewController.h"
#import "RequestSentModel.h"
#import "ServiceListModel.h"
#import <UIImageView+AFNetworking.h>

@interface PendingConfirmationViewController ()
{
    NSMutableArray *pendingListArray;
    NSArray *serviceListArray;
    RequestSentModel *sectionData;
    ServiceListModel *tableData;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *noConfirmationLbl;
@property (weak, nonatomic) IBOutlet UIView *pendingConfirmationView;
@property (weak, nonatomic) IBOutlet UITableView *pendingConfirmationTableView;
@property(strong,nonatomic) NSString *spUserId;
@property(strong,nonatomic) NSString *status;
@end

@implementation PendingConfirmationViewController
@synthesize pendingConfirmationTableView,pendingConfirmationView,scrollView;
@synthesize spUserId,noConfirmationLbl,status;

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Pending Confirmation";
    
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    pendingConfirmationView.translatesAutoresizingMaskIntoConstraints=YES;
    scrollView.translatesAutoresizingMaskIntoConstraints=YES;
    pendingConfirmationTableView.translatesAutoresizingMaskIntoConstraints=YES;
    
    scrollView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    pendingConfirmationView.frame=CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    pendingConfirmationTableView.frame=CGRectMake(0, 0, self.pendingConfirmationView.frame.size.width, pendingConfirmationTableView.frame.size.height-21);
    
    pendingListArray = [[NSMutableArray alloc]init];
    
    noConfirmationLbl.hidden=YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [pendingListArray removeAllObjects];
    if (myDelegate.messageType==2)
    {
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RequestDetailViewController *details = [storyboard instantiateViewControllerWithIdentifier:@"RequestDetailViewController"];
        [self.navigationController pushViewController:details animated:YES];
        
    }
    else
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(getPendingConfirmationListFromServer) withObject:nil afterDelay:0.1];
    }
    
    
    
}

-(void) dealloc
{
    pendingListArray=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Webservice Methods
-(void)getPendingConfirmationListFromServer
{
    [[WebService sharedManager]pendingConfirmation:^(id dataArray)
     {
         [myDelegate StopIndicator];
         if ([dataArray isKindOfClass:[NSArray class]])
         {
             pendingListArray = [dataArray mutableCopy];
             status=@"1";
             long count=0;
             sectionData=[RequestSentModel new];
             for (int i=0;i<pendingListArray.count; i++) {
                 sectionData=[pendingListArray objectAtIndex:i];
                 count=count+sectionData.serviceList.count;
             }
             pendingConfirmationTableView.frame=CGRectMake(0, 0, self.view.frame.size.width, (pendingListArray.count*110)+(count*30)+(pendingListArray.count*22));
             pendingConfirmationView.frame=CGRectMake(0, 0, self.view.frame.size.width, (pendingListArray.count*110)+(count*30)+(pendingListArray.count*22));
             self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, pendingConfirmationView.frame.size.height+70, 0);
             
             [pendingConfirmationTableView reloadData];
        }
         else
         {
             [pendingConfirmationTableView reloadData];
             noConfirmationLbl.hidden=NO;
         }
         [[NSUserDefaults standardUserDefaults]setInteger:pendingListArray.count forKey:@"PendingConfirmation"];
         [[NSUserDefaults standardUserDefaults]synchronize];
         
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
     }] ;
    
}
#pragma mark - end

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return pendingListArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    sectionData=[RequestSentModel new];
    sectionData=[pendingListArray objectAtIndex:section];
    
    return sectionData.serviceList.count+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"requestCell";
    RequestSentCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[RequestSentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    [cell layoutView:self.view.frame];
    sectionData=[RequestSentModel new];
    sectionData=[pendingListArray objectAtIndex:indexPath.section];
    if (sectionData.serviceList.count==(indexPath.row))
    {
        cell.ServiceName.text=@"";
        cell.ServiceCharge.text=@"";
        cell.innerView.hidden=YES;
        cell.separator.hidden=NO;
        cell.bottomView.hidden=NO;
        cell.seperatorLabel.hidden=YES;
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
        if (indexPath.row==0) {
            cell.seperatorLabel.hidden=YES;
        }
        else
        {
            cell.seperatorLabel.hidden=NO;
        }
    }
     return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    //    return 110;
    return 110;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    sectionData=[RequestSentModel new];
    sectionData=[pendingListArray objectAtIndex:indexPath.section];
    if (sectionData.serviceList.count==(indexPath.row)) {
        return 14;
    }
    else
        return 30;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    sectionData=[RequestSentModel new];
    sectionData=[pendingListArray objectAtIndex:section];
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
    serviceProviderName.font=[UIFont fontWithName:@"Helvetica Neue" size:15];
    serviceProviderName.numberOfLines = 3;
    
    CGSize size = CGSizeMake(111,999);
    CGRect textRect = [sectionData.name
                       boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:16]}
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
    
    
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [headerButton addTarget:self action:@selector(getRequestDetail:) forControlEvents:UIControlEventTouchUpInside];
    headerButton.backgroundColor=[UIColor clearColor];
    headerButton.frame = headerView.frame;
    headerButton.tag=section;
    
    [headerView addSubview:headerButton];
    
    return headerView;
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    sectionData=[RequestSentModel new];
    myDelegate.superClassView = @"backView";
    sectionData=[pendingListArray objectAtIndex:indexPath.section];
    if (sectionData.serviceList.count!=(indexPath.row))
    {
        int index=(int)indexPath.row;
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RequestDetailViewController *requestDetail =[storyboard instantiateViewControllerWithIdentifier:@"RequestDetailViewController"];
        requestDetail.status=status;
        requestDetail.selectedIndex=index;
        requestDetail.sectionData=[pendingListArray objectAtIndex:indexPath.section];
        requestDetail.tableData=[requestDetail.sectionData.serviceList objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:requestDetail animated:YES];
        
    }
 
}
#pragma mark - end

#pragma mark - Button action

-(IBAction)getRequestDetail:(id)sender
{
    sectionData=[RequestSentModel new];
    
    sectionData=[pendingListArray objectAtIndex:[sender tag]];
    myDelegate.superClassView = @"backView";
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RequestDetailViewController *requestDetail =[storyboard instantiateViewControllerWithIdentifier:@"RequestDetailViewController"];
    requestDetail.status=status;
    requestDetail.selectedIndex=0;
    requestDetail.sectionData=[pendingListArray objectAtIndex:[sender tag]];
    requestDetail.tableData=[requestDetail.sectionData.serviceList objectAtIndex:0];
    [self.navigationController pushViewController:requestDetail animated:YES];
}
#pragma mark - end


@end
