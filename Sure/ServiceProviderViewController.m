//
//  ServiceProviderViewController.m
//  Sure
//
//  Created by Hema on 16/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "ServiceProviderViewController.h"
#import "ServiceProviderListingCell.h"
#import "UIView+RoundedCorner.h"
#import "SearchDataModel.h"
#import "BusinessProfileViewController.h"
#import "RequestSentModel.h"
#import "ServiceListModel.h"
#import "AddressAnnotation.h"

#define SLIDER_VIEW_TAG     1234

@interface ServiceProviderViewController ()<UITabBarControllerDelegate,UITableViewDataSource,MKMapViewDelegate>
{
    BOOL toggleIsOn;
    UIView * footerView;
    NSMutableArray *getProviderList;
    int  totalNoOfRecords;
    UILabel *leftLabel;
    UILabel *rightLabel;
    NSString *city;
    NSString *highestRating;
    NSString *mostBooking;
    NSString *dateString;
    int buttonTag;
    bool timerPicker;
    ServiceListModel *serviceListData;
    NSMutableArray *spListArray;
    NSString * fromTime;
    NSString * toTime;
    UIRefreshControl *refreshControl;
    AddressAnnotation *addAnnotation;
    NSString *defaultLat;
    NSString *defaultLong;
    NSDictionary * selectedCityDict;
}
@property (strong,nonatomic) NSMutableArray *hourArray;
@property (strong,nonatomic) NSMutableArray *durationArray;
@property (weak, nonatomic) IBOutlet UIButton *inShopServiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *onSiteServiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *toggleMapListBtn;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property(nonatomic, strong) NSString *Offset;
@property(nonatomic,retain) NSMutableArray * sortedData;

//Filter Listing
@property (weak, nonatomic) IBOutlet UIView *filterListingPopup;
@property (weak, nonatomic) IBOutlet UILabel *sortByDateLbl;
@property (weak, nonatomic) IBOutlet UIButton *nearByBtn;
@property (weak, nonatomic) IBOutlet UIButton *highestRatingBtn;
@property (weak, nonatomic) IBOutlet UIButton *mostBookingBtn;
@property (weak, nonatomic) IBOutlet UIView *sortByPopup;
@property (weak, nonatomic) IBOutlet UIButton *sortByDoneBtn;
@property (weak, nonatomic) IBOutlet UIDatePicker *dateTimePicker;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@property (weak, nonatomic) IBOutlet UIScrollView *sliderScrollView;
@property (weak, nonatomic) IBOutlet UIView *sliderContainer;
@property (weak, nonatomic) IBOutlet UIButton *clearFilterBtn;
@property (weak, nonatomic) IBOutlet UIButton *sortByTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *durationBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *timePicker;
@property (weak, nonatomic) IBOutlet UILabel *fromTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *durationTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *noSPLbl;
@property (weak, nonatomic) IBOutlet UIDatePicker *hourPicker;

@end

@implementation ServiceProviderViewController
@synthesize inShopServiceBtn,onSiteServiceBtn,Offset;
@synthesize toggleMapListBtn,mapView,listTableView;
@synthesize filterListingPopup,sortByDateLbl,sortByPopup;
@synthesize highestRatingBtn,nearByBtn,mostBookingBtn,sortByDoneBtn,clearFilterBtn,durationBtn,sortByTimeBtn;
@synthesize pickerToolbar,dateTimePicker,timePicker;
@synthesize subCatServiceID,searchKey,latitude,longitude,customLocation;
@synthesize hourArray,durationArray,durationTimeLbl,fromTimeLbl,sortedData,noSPLbl,hourPicker;

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    noSPLbl.hidden=YES;
    spListArray = [[NSMutableArray alloc]init];
    sortedData = [[NSMutableArray alloc]init];
    [nearByBtn setSelected:YES];
    nearByBtn.backgroundColor=[UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    [inShopServiceBtn setSelected:YES];
    [inShopServiceBtn setTitleColor:[UIColor colorWithRed:254.0/255.0 green:66.0/255.0 blue:65.0/255.0 alpha:1.0] forState:UIControlStateSelected];
    sortByDateLbl.layer.borderWidth = 2.0f;
    sortByDateLbl.layer.borderColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0].CGColor;
    hourArray=[[NSMutableArray alloc] init];
    durationArray=[[NSMutableArray alloc] initWithObjects:@"30 Mins",@"60 Mins", nil];
    toggleIsOn=YES;
    filterListingPopup.hidden=YES;
    dateTimePicker.translatesAutoresizingMaskIntoConstraints=YES;
    pickerToolbar.translatesAutoresizingMaskIntoConstraints=YES;
    timePicker.translatesAutoresizingMaskIntoConstraints=YES;
    hourPicker.translatesAutoresizingMaskIntoConstraints=YES;
    getProviderList=[[NSMutableArray alloc]init];
    selectedCityDict = [[NSUserDefaults standardUserDefaults]objectForKey:@"City"];
    city=[selectedCityDict objectForKey:@"Id"];
    highestRating=@"";
    mostBooking=@"";
    dateString=@"";
    sortByDateLbl.text=@"";
    fromTime = @"";
    toTime=@"";
    defaultLat=latitude;
    defaultLong=longitude;
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getServiceProviderListFromWebservice) withObject:nil afterDelay:.2];
    // Pull To Refresh
    refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(160, 0, 10, 10)];
    [self.listTableView addSubview:refreshControl];
    NSMutableAttributedString *refreshString = [[NSMutableAttributedString alloc] initWithString:@""];
    [refreshString addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]} range:NSMakeRange(0, refreshString.length)];
    refreshControl.attributedTitle = refreshString;
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    self.listTableView.alwaysBounceVertical = YES;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.title=@"Service Providers";
    mapView.hidden=YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(void) dealloc
{
    getProviderList=nil;
    spListArray=nil;
    sortedData=nil;
    hourArray=nil;
    durationArray=nil;
}

#pragma mark - end

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return sortedData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    RequestSentModel *spListingData=[sortedData objectAtIndex:indexPath.row];
    switch (spListingData.serviceList.count) {
        case 1:
            return 140;
            break;
        case 2:
            return 175;
            break;
        case 3:
            return 190;
            break;
            
        default:
            return 140;
            break;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"ServiceProviderListingCell";
    
    ServiceProviderListingCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[ServiceProviderListingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    RequestSentModel *spListingData=[sortedData objectAtIndex:indexPath.row];
    [cell displaySpListData:spListingData :(int)indexPath.row viewSize:self.view.bounds];
  
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RequestSentModel *spListingData=[sortedData objectAtIndex:indexPath.row];
    BusinessProfileViewController *objProductDetail =[storyboard instantiateViewControllerWithIdentifier:@"BusinessProfileViewController"];
    objProductDetail.serviceProviderID=spListingData.serviceProviderId;
    [self.navigationController pushViewController:objProductDetail animated:YES];
    
}
#pragma mark - end

#pragma mark - Webservice Methods

-(void)filterData
{
    [sortedData removeAllObjects];
    if (inShopServiceBtn.isSelected)
    {
        
        for (int i =0; i<spListArray.count; i++)
        {
            
            RequestSentModel *spListingData = [spListArray objectAtIndex:i];
            
            if ([spListingData.inShop intValue]==1)
            {
                [sortedData addObject:spListingData];
                noSPLbl.hidden=YES;
                
            }
        }
        
    }
    else
    {
        
        for (int i =0; i<spListArray.count; i++)
        {
            
            RequestSentModel *spListingData = [spListArray objectAtIndex:i];
            if ([spListingData.onSite intValue]==1)
            {
                [sortedData addObject:spListingData];
                noSPLbl.hidden=YES;
                
            }
        }
        
    }
    if (sortedData.count==0)
    {
        noSPLbl.hidden=NO;
    }
    
    [self addAnnotation];
    [listTableView reloadData];
    
}

-(void) getServiceProviderListFromWebservice
{
    if ([toTime isEqualToString:@"00:00"]) {
        toTime=@"23:59";
    }
    [[WebService sharedManager] getSpList:subCatServiceID searchKey:searchKey highestRating:highestRating mostBooking:mostBooking date:dateString startTime:fromTime endTime:toTime latitude:[NSString stringWithFormat:@"%@",latitude] longitude:[NSString stringWithFormat:@"%@",longitude] city:city success:^(id dataArray)
     {
         [myDelegate StopIndicator];
         if ([dataArray isKindOfClass:[NSArray class]])
         {
             spListArray = [dataArray mutableCopy];
             
             [self filterData];
             filterListingPopup.hidden=YES;
         }
         else
         {
             noSPLbl.hidden=NO;
             filterListingPopup.hidden=YES;
         }
         
         
     } failure:^(NSError *error)
     {
         
     }] ;
}

#pragma mark - end

#pragma mark - Refresh Table
//Pull to refresh implementation on my submission data
- (void)refreshTable
{
    [self performSelector:@selector(getServiceProviderListFromWebservice) withObject:nil afterDelay:0.1];
    [refreshControl endRefreshing];
    [self.listTableView reloadData];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==10)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark - end

#pragma mark - View actions

- (IBAction)inShopServiceButtonClicked:(id)sender
{
    [inShopServiceBtn setSelected:YES];
    [onSiteServiceBtn setSelected:NO];
    [inShopServiceBtn setTitleColor:[UIColor colorWithRed:254.0/255.0 green:66.0/255.0 blue:65.0/255.0 alpha:1.0] forState:UIControlStateSelected];
    [self filterData];
    
}

- (IBAction)onSiteServiceButtonClicked:(id)sender
{
    [onSiteServiceBtn setSelected:YES];
    [inShopServiceBtn setSelected:NO];
    [onSiteServiceBtn setTitleColor:[UIColor colorWithRed:254.0/255.0 green:66.0/255.0 blue:65.0/255.0 alpha:1.0] forState:UIControlStateSelected];
    [self filterData];
    
}

#pragma mark - end

#pragma mark - Filter actions

- (IBAction)filterButtonClicked:(id)sender
{
    filterListingPopup.hidden=NO;
    
    [self addShadowOnButtons];
    
}

-(void) addShadowOnButtons
{
    [sortByPopup setCornerRadius:2.0f];
    
    [sortByDoneBtn.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [sortByDoneBtn.layer setShadowOpacity:1.0];
    [sortByDoneBtn.layer setShadowRadius:2.0];
    [sortByDoneBtn.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [sortByDoneBtn.layer setBorderWidth:1.0];
    [sortByDoneBtn.layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0])];
    [sortByDoneBtn.layer setCornerRadius:1.0];
    
    [clearFilterBtn.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [clearFilterBtn.layer setShadowOpacity:1.0];
    [clearFilterBtn.layer setShadowRadius:2.0];
    [clearFilterBtn.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [clearFilterBtn.layer setBorderWidth:1.0];
    [clearFilterBtn.layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0])];
    [clearFilterBtn.layer setCornerRadius:1.0];
}

- (IBAction)closeSortByPopupAction:(id)sender
{
    [nearByBtn setSelected:YES];
    nearByBtn.backgroundColor=[UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    [highestRatingBtn setSelected:NO];
    [mostBookingBtn setSelected:NO];
    mostBookingBtn.backgroundColor=[UIColor clearColor];
    [highestRatingBtn setSelected:NO];
    highestRatingBtn.backgroundColor=[UIColor clearColor];
    
    durationTimeLbl.text=@"00 Mins";
    fromTimeLbl.text=@"00:00";
    sortByDateLbl.text=@"";
    fromTime=@"";
    toTime=@"";
    dateString=@"";
    mostBooking=@"";
    highestRating=@"";
    filterListingPopup.hidden=YES;
    latitude=defaultLat;
    longitude=defaultLong;
}
- (IBAction)searchNearBy:(id)sender
{
    
    [nearByBtn setSelected:YES];
    nearByBtn.backgroundColor=[UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    
    [highestRatingBtn setSelected:NO];
    highestRatingBtn.backgroundColor=[UIColor clearColor];
    
    [mostBookingBtn setSelected:NO];
    mostBookingBtn.backgroundColor=[UIColor clearColor];
    highestRating=@"";
    mostBooking=@"";
    latitude=defaultLat;
    longitude=defaultLong;
    
}
- (IBAction)highestRatingSearch:(id)sender
{
    
    [highestRatingBtn setSelected:YES];
    
    highestRatingBtn.backgroundColor=[UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    
    [nearByBtn setSelected:NO];
    nearByBtn.backgroundColor=[UIColor clearColor];
    
    [mostBookingBtn setSelected:NO];
    mostBookingBtn.backgroundColor=[UIColor clearColor];
    
    highestRating=@"true";
    mostBooking=@"";
    latitude=@"";
    longitude=@"";
    
    
}
- (IBAction)mostBookingSearch:(id)sender
{
    
    [mostBookingBtn setSelected:YES];
    
    mostBookingBtn.backgroundColor=[UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    [nearByBtn setSelected:NO];
    nearByBtn.backgroundColor=[UIColor clearColor];
    
    [highestRatingBtn setSelected:NO];
    highestRatingBtn.backgroundColor=[UIColor clearColor];
    
    highestRating=@"";
    mostBooking=@"true";
    latitude=@"";
    longitude=@"";
    
    
}

- (IBAction)sortByDoneButtonClicked:(id)sender
{
    
    [spListArray removeAllObjects];
    [sortedData removeAllObjects];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    dateFormatter.dateFormat = @"HH:mm";
    NSDate *date = [dateFormatter dateFromString:fromTimeLbl.text];
    if ([durationTimeLbl.text isEqualToString:@"30 Mins"])
    {
        date=[date dateByAddingTimeInterval:60*30];
        toTime=[dateFormatter stringFromDate:date];
    }
    else if ([durationTimeLbl.text isEqualToString:@"60 Mins"])
    {
        date=[date dateByAddingTimeInterval:60*60];
        toTime=[dateFormatter stringFromDate:date];
    }
    else
    {
        toTime=@"";
    }
    if (![sortByDateLbl.text isEqualToString:@""] && [fromTimeLbl.text isEqualToString:@"00:00"] && [durationTimeLbl.text isEqualToString:@"00 Mins"])
    {
        UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please select time duration." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if ([sortByDateLbl.text isEqualToString:@""]  && ![durationTimeLbl.text isEqualToString:@"00 Mins"])
    {
        UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please select date." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(getServiceProviderListFromWebservice) withObject:nil afterDelay:.2];
        [listTableView reloadData];
    }
    
}
- (IBAction)clearFilterButtonAction:(id)sender
{
    [nearByBtn setSelected:YES];
    nearByBtn.backgroundColor=[UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    [highestRatingBtn setSelected:NO];
    [mostBookingBtn setSelected:NO];
    mostBookingBtn.backgroundColor=[UIColor clearColor];
    [highestRatingBtn setSelected:NO];
    highestRatingBtn.backgroundColor=[UIColor clearColor];
    
    durationTimeLbl.text=@"00 Mins";
    fromTimeLbl.text=@"00:00";
    sortByDateLbl.text=@"";
    fromTime=@"";
    toTime=@"";
    dateString=@"";
    mostBooking=@"";
    highestRating=@"";
    latitude=defaultLat;
    longitude=defaultLong;
    
}
#pragma mark - end

#pragma mark - Toogle map and list action

- (IBAction)toggleMapAndListButtonClicked:(id)sender
{
    if(toggleIsOn)
    {
        [toggleMapListBtn setSelected:YES];
        
        listTableView.hidden=YES;
        mapView.hidden=NO;
        [self addAnnotation];
        
    }
    else
    {
        [toggleMapListBtn setSelected:NO];
        listTableView.hidden=NO;
        mapView.hidden=YES;
    }
    toggleIsOn = !toggleIsOn;
}


-(void) addAnnotation
{
    NSMutableArray * annotationsToRemove = [ mapView.annotations mutableCopy ] ;
    [ annotationsToRemove removeObject:mapView.userLocation ] ;
    [ mapView removeAnnotations:annotationsToRemove ];
    [mapView setDelegate:self];
    if (![customLocation  isEqualToString:@""])
    {
        mapView.showsUserLocation=NO;
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.5;     // 0.0 is min value u van provide for zooming
        span.longitudeDelta= 0.5;
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [latitude floatValue];
        coordinate.longitude = [longitude floatValue];
        region.span=span;
        region.center =coordinate;
        addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:coordinate];
        [mapView addAnnotation:addAnnotation];
        addAnnotation.myPinColor=MKPinAnnotationColorGreen;
        
        [mapView setRegion:region animated:TRUE];
        [mapView regionThatFits:region];
    }
    else
    {
        mapView.showsUserLocation=YES;
        self.mapView.userTrackingMode = MKUserTrackingModeFollow;
        [mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    }
    
    for (int i=0; i < [sortedData count]; i++)
    {
        RequestSentModel *spListingData = [sortedData objectAtIndex:i];
        CLLocationCoordinate2D location;
        location.latitude = [spListingData.latitude floatValue];
        location.longitude = [spListingData.longitude floatValue];
        if (location.latitude!=0.0 && location.longitude!=0.0) {
            addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location];
            [self.mapView addAnnotation:addAnnotation];
            addAnnotation.title=spListingData.name;
        }
    }
}

- (MKAnnotationView*) mapView:
(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[AddressAnnotation class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView*)
        [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        else
        {
            annotationView.annotation = annotation;
            
            
            if (![customLocation  isEqualToString:@""] && [latitude floatValue]!=0.0 && [longitude floatValue]!=0.0)
            {
                
                AddressAnnotation *ppm = (AddressAnnotation *)annotation;
                annotationView.pinColor = ppm.myPinColor;
            }
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
        }
         return annotationView;
    }
    return nil;
}

#pragma mark - end

#pragma mark - Picker Action

- (IBAction)sortByDateAction:(id)sender
{
    timerPicker=false;
    buttonTag=(int)[sender tag];
    [self hidePickerWithAnimation];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [_sliderScrollView setContentOffset:CGPointMake(0, _sliderScrollView.frame.origin.y+64) animated:YES];
    
    dateTimePicker.backgroundColor=[UIColor whiteColor];
    dateTimePicker.minimumDate=[NSDate date];
    dateTimePicker.frame = CGRectMake(dateTimePicker.frame.origin.x, (self.view.frame.size.height-dateTimePicker.frame.size.height) , self.view.frame.size.width, dateTimePicker.frame.size.height);
    
    pickerToolbar.backgroundColor=[UIColor whiteColor];
    pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, dateTimePicker.frame.origin.y-44, self.view.frame.size.width, pickerToolbar.frame.size.height);
    [UIView commitAnimations];
}

- (IBAction)sortByTimeAction:(id)sender
{
    [self hidePickerWithAnimation];
    timerPicker=false;
    
    buttonTag=(int)[sender tag];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [_sliderScrollView setContentOffset:CGPointMake(0, _sliderScrollView.frame.origin.y+100) animated:YES];
    
    hourPicker.backgroundColor=[UIColor whiteColor];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"NL"];
    [hourPicker setLocale:locale];
    hourPicker.minuteInterval=30;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    [comps setHour:00];
    [comps setMinute:00];
    NSDate *dateFromComps = [calendar dateFromComponents:comps];
    hourPicker.date = dateFromComps;
    
    hourPicker.frame = CGRectMake(hourPicker.frame.origin.x, (self.view.frame.size.height-hourPicker.frame.size.height) , self.view.frame.size.width, hourPicker.frame.size.height);
    
    pickerToolbar.backgroundColor=[UIColor whiteColor];
    pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, hourPicker.frame.origin.y-44, self.view.frame.size.width, pickerToolbar.frame.size.height);
    [UIView commitAnimations];
    
    
}

- (IBAction)durationAction:(id)sender
{
    [self hidePickerWithAnimation];
    timerPicker=true;
    buttonTag=(int)[sender tag];
    [timePicker reloadAllComponents];
    [timePicker selectRow:0 inComponent:0 animated:YES];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [_sliderScrollView setContentOffset:CGPointMake(0, _sliderScrollView.frame.origin.y+100) animated:YES];
    
    timePicker.backgroundColor=[UIColor whiteColor];
    
    timePicker.frame = CGRectMake(timePicker.frame.origin.x, (self.view.frame.size.height-timePicker.frame.size.height) , self.view.frame.size.width, timePicker.frame.size.height);
    
    pickerToolbar.backgroundColor=[UIColor whiteColor];
    pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, timePicker.frame.origin.y-44, self.view.frame.size.width, pickerToolbar.frame.size.height);
    [UIView commitAnimations];
}


- (IBAction)pickerToolbarDoneClicked:(id)sender
{
    if (timerPicker)
    {
        NSInteger index = [timePicker selectedRowInComponent:0];
        durationTimeLbl.text=[durationArray objectAtIndex:index];
    }
    else if(buttonTag==10)
    {
        if ([durationTimeLbl.text isEqualToString: @"00 Mins"]) {
            durationTimeLbl.text=@"30 Mins";
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateFormat:@"HH:mm"];
        fromTimeLbl.text=[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:hourPicker.date]];
        fromTime = fromTimeLbl.text;
    }
    else if(buttonTag==20)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateFormat:@"dd-MMMM-YYYY"];
        dateString = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateTimePicker.date]];
        NSString *tempDate=[myDelegate formatDateToDisplay:dateTimePicker.date];
        sortByDateLbl.text=tempDate;
    }
    [self hidePickerWithAnimation];
}

-(void)hidePickerWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [_sliderScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    dateTimePicker.frame = CGRectMake(dateTimePicker.frame.origin.x, 1000, self.view.frame.size.width, dateTimePicker.frame.size.height);
    hourPicker.frame = CGRectMake(hourPicker.frame.origin.x, 1000, self.view.frame.size.width, hourPicker.frame.size.height);
    timePicker.frame = CGRectMake(timePicker.frame.origin.x, 1000, self.view.frame.size.width, timePicker.frame.size.height);
    pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, 1000, self.view.frame.size.width, pickerToolbar.frame.size.height);
    [UIView commitAnimations];
}
#pragma mark - end

#pragma mark - Picker Delegates
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    return [durationArray count];

}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    return [durationArray objectAtIndex:row];
        
}
#pragma mark - end

@end
