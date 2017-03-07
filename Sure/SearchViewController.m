//
//  MapViewController.m
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "SearchViewController.h"
#import "SWRevealViewController.h"
#import "UITextField+Padding.h"
#import "SubCategoryViewController.h"
#import "UIView+RoundedCorner.h"
#import "UITextField+Validations.h"
#import "SearchDataModel.h"
#import <UIImageView+AFNetworking.h>
#import "ServiceProviderViewController.h"
#import "MJGeocodingServices.h"
#import <CoreLocation/CoreLocation.h>
#import "ProfileDataModel.h"
#define kCellsPerRow 2

@interface SearchViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate,MJGeocoderDelegate>
{
    NSArray *textFields;
    NSMutableArray *swipeBannerImages;
    NSArray *bannerImages;
    int imageIndex;
    int currentIndex;
    int  totalNoOfRecords;
    MJGeocoder *forwardGeocoder;
    NSString *latitude;
    NSString *longitude;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;
@property (weak, nonatomic) IBOutlet UITextField *searchService;
@property (weak, nonatomic) IBOutlet UITextField *locationSearch;
@property (weak, nonatomic) IBOutlet UIPageControl *imagePageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *categoryCollectionView;
@property (weak, nonatomic) IBOutlet UIView *paginationView;
@property (weak, nonatomic) IBOutlet UIButton *clearSearchBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearLocationBtn;
@property(nonatomic,retain)NSMutableArray * getCategoryArray;
@property(nonatomic, retain) MJGeocoder *forwardGeocoder;
@property(nonatomic, strong) NSString *Offset;
@end

@implementation SearchViewController
@synthesize searchService,locationSearch,bannerImage,imagePageControl,scrollView,categoryCollectionView,paginationView,clearSearchBtn,clearLocationBtn,getCategoryArray,Offset,forwardGeocoder;


#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    paginationView.hidden=YES;
    currentIndex=0;
    imageIndex=0;
    Offset=@"0";
    // Do any additional setup after loading the view.
    searchService.delegate=self;
    locationSearch.delegate=self;
    
    [searchService addTextFieldPadding:searchService];
    [locationSearch addTextFieldPadding:locationSearch];
    
    //settinng collection view cell size according to iPhone screens
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.categoryCollectionView.collectionViewLayout;
    CGFloat availableWidthForCells = CGRectGetWidth(self.view.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow -1)-20;
    CGFloat cellWidth = (availableWidthForCells / kCellsPerRow)-5;
    flowLayout.itemSize = CGSizeMake(cellWidth, flowLayout.itemSize.height);
    getCategoryArray=[[NSMutableArray alloc]init];
    swipeBannerImages=[[NSMutableArray alloc]init];
    bannerImages=[[NSArray alloc]init];
    //Adding swipe gesture
    [bannerImage setUserInteractionEnabled:YES];
    
    UISwipeGestureRecognizer *swipeImageLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBannerImageLeft:)];
    swipeImageLeft.delegate=self;
    UISwipeGestureRecognizer *swipeImageRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBannerImageRight:)];
    swipeImageRight.delegate=self;
    
    // Setting the swipe direction.
    [swipeImageLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeImageRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [bannerImage addGestureRecognizer:swipeImageLeft];
    [bannerImage addGestureRecognizer:swipeImageRight];
    imagePageControl.currentPage = 0;
    clearSearchBtn.hidden=YES;
    clearLocationBtn.hidden=YES;
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    if([[UIScreen mainScreen] bounds].size.height>480)
    {
        scrollView.scrollEnabled=NO;
    }
    [getCategoryArray removeAllObjects];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getBannerImages) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    getCategoryArray=nil;
    swipeBannerImages=nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Search";
    searchService.text=@"";
    locationSearch.text=@"";
    
    currentIndex=0;
    imageIndex=0;
    Offset=@"0";
    [myDelegate getLatLong];
}
#pragma mark - end

#pragma mark - Webservice Methods
//Method to get banner images from server
-(void)getBannerImages
{
    [[WebService sharedManager]getBannerImages:^(id responseObject)
     {
         [swipeBannerImages removeAllObjects];
         
         bannerImages=[responseObject objectForKey:@"BannerList"];
         if (bannerImages.count==0)
         {
             [swipeBannerImages addObject:[UIImage imageNamed:@"search_banner"]];
             imagePageControl.numberOfPages = [swipeBannerImages count];
         }
         else
         {
             NSDictionary *tempDict=[bannerImages objectAtIndex:0];
             NSString *tempUrl=[tempDict objectForKey:@"BannerImage"];
             [self URL:tempUrl];
         }
         
         [myDelegate ShowIndicator];
         [self performSelector:@selector(getServiceCategoryListFromWebservice) withObject:nil afterDelay:.1];
         
     } failure:^(NSError *error) {
         
     }] ;
    
}
//Method download images using AFNetworking
- (void) URL:(NSString *)url
{
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [bannerImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"search_banner"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         bannerImage.contentMode = UIViewContentModeScaleAspectFill;
         [swipeBannerImages addObject:image];
         imagePageControl.numberOfPages = [swipeBannerImages count];
         currentIndex++;
         if (currentIndex != bannerImages.count)
         {
             NSDictionary *tempDict=[bannerImages objectAtIndex:currentIndex];
             
             NSString *tempUrl=[tempDict objectForKey:@"BannerImage"];
             [self URL:tempUrl];
         }
         bannerImage.clipsToBounds = YES;
         if (swipeBannerImages.count==0) {
             bannerImage.image=[UIImage imageNamed:@"search_banner"];
         }
         else
         {
             bannerImage.image = [swipeBannerImages objectAtIndex:0];
         }
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];
}
//Method to get service category list from server
-(void)getServiceCategoryListFromWebservice
{
    [[WebService sharedManager] getCategoryList:[NSString stringWithFormat:@"%@",Offset] success:^(id CategoryListingArray)
     {
         [myDelegate StopIndicator];
         if (getCategoryArray<0) {
             getCategoryArray =[CategoryListingArray mutableCopy];
         }
         else
         {
             [getCategoryArray addObjectsFromArray:CategoryListingArray];
         }
         totalNoOfRecords= [[getCategoryArray objectAtIndex:getCategoryArray.count-1]intValue];
         [getCategoryArray removeLastObject];
         [categoryCollectionView reloadData];
         
         [self hideactivityIndicator];
     } failure:^(NSError *error) {
         
     }] ;
}

#pragma mark - end

#pragma mark - Collectionview datasource and delegate methods

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return [getCategoryArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *myCell = [collectionView1
                                    dequeueReusableCellWithReuseIdentifier:@"CategoryViewCell"
                                    forIndexPath:indexPath];
    
    [myCell setCornerRadius:2.5f];
    myCell.layer.borderWidth=1.0f;
    myCell.layer.borderColor=[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    
    UILabel *categoryNameLabel=(UILabel *)[myCell viewWithTag:2];
    UIImageView *categoryImageView=(UIImageView *)[myCell viewWithTag:1];
    
    SearchDataModel * data = [getCategoryArray objectAtIndex:indexPath.row];
    __weak UIImageView *weakRef = categoryImageView;
    
    NSString *tempImageString=data.categoryImage;
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:tempImageString]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [categoryImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"picture"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFit;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    categoryNameLabel.text=data.categoryName;
    
    
    return myCell;
    
}

- (void)collectionView:(UICollectionView *)collectionView1
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SubCategoryViewController *subCategoryList =[storyboard instantiateViewControllerWithIdentifier:@"SubCategoryViewController"];
    SearchDataModel * data = [getCategoryArray objectAtIndex:indexPath.row];
    subCategoryList.mainCategoryId=data.categoryId;
    subCategoryList.mainCategoryName=data.categoryName;
    [self.navigationController pushViewController:subCategoryList animated:YES];
    
}

#pragma mark - end

#pragma mark - Textfield Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([[UIScreen mainScreen] bounds].size.height<=568)
    {
        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-75) animated:YES];
        
    }
    if (textField==searchService)
    {
        if (searchService.text.length>0)
        {
            clearSearchBtn.hidden=NO;
            
        }
    }
    else if (textField==locationSearch)
    {
        if (locationSearch.text.length>0)
        {
            clearLocationBtn.hidden=NO;
        }
    }
}
-(BOOL)textFieldShouldBeginEditing: (UITextField *)textField
{
    UIToolbar * keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    
    keyboardToolBar.barStyle = UIBarStyleDefault;
    [keyboardToolBar setItems: [NSArray arrayWithObjects:
                                [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(ressignResponder)],
                                nil]];
    textField.inputAccessoryView = keyboardToolBar;
    return YES;
}
-(void)ressignResponder
{
    [searchService resignFirstResponder];
    [locationSearch resignFirstResponder];
}
- (BOOL) textField: (UITextField *)theTextField shouldChangeCharactersInRange: (NSRange)range replacementString: (NSString *)string
{
    if (theTextField==searchService)
    {
        if(searchService.text.length==1 && [string isEqualToString:@""])
        {
            clearSearchBtn.hidden=YES;
        }
        else
        {
            clearSearchBtn.hidden=NO;
            
        }
    }
    else if(theTextField==locationSearch)
    {
        if(locationSearch.text.length==1 && [string isEqualToString:@""])
        {
            clearLocationBtn.hidden=YES;
        }
        else
        {
            clearLocationBtn.hidden=NO;
        }
        
    }
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == searchService)
    {
        clearSearchBtn.hidden=YES;
        
    }
    else if (textField==locationSearch)
    {
        clearLocationBtn.hidden=YES;
        
    }
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
//method to get search list from server
-(void) searchSpListing
{
    if ([locationSearch.text isEqualToString:@""])
    {
        [myDelegate StopIndicator];
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ServiceProviderViewController *serviceProviderList =[storyboard instantiateViewControllerWithIdentifier:@"ServiceProviderViewController"];
        serviceProviderList.subCatServiceID=@"";
        serviceProviderList.searchKey=searchService.text;
        NSString *trimmedString = [locationSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        serviceProviderList.customLocation=trimmedString;
        serviceProviderList.latitude=myDelegate.latitude;
        serviceProviderList.longitude=myDelegate.longitude;
        [self.navigationController pushViewController:serviceProviderList animated:YES];
    }
    else
    {
        if(!forwardGeocoder)
        {
            forwardGeocoder = [[MJGeocoder alloc] init];
            forwardGeocoder.delegate = self;
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSString *string=[NSString stringWithFormat:@"%@",locationSearch.text];
        [forwardGeocoder findLocationsWithAddress:string title:nil];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [myDelegate ShowIndicator];
    [self performSelector:@selector(searchSpListing) withObject:nil afterDelay:0.2];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - end


#pragma mark - Swipe Images
//Adding left animation to banner images
- (void)addLeftAnimationPresentToView:(UIView *)viewTobeAnimatedLeft
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    [viewTobeAnimatedLeft.layer addAnimation:transition forKey:nil];
}
//Adding right animation to banner images
- (void)addRightAnimationPresentToView:(UIView *)viewTobeAnimatedRight
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    [viewTobeAnimatedRight.layer addAnimation:transition forKey:nil];
    
   

}
//Swipe images in left direction
-(void) swipeBannerImageLeft: (UISwipeGestureRecognizer *)sender
{
    imageIndex++;
    if (imageIndex<swipeBannerImages.count)
    {
        bannerImage.image=[swipeBannerImages objectAtIndex:imageIndex];
        UIImageView *moveIMageView = bannerImage;
        [self addLeftAnimationPresentToView:moveIMageView];
        int page=imageIndex;
        imagePageControl.currentPage=page;
    }
    else
    {
        imageIndex--;
    }
}
//Swipe images in right direction
-(void) swipeBannerImageRight: (UISwipeGestureRecognizer *)sender
{
    imageIndex--;
    if (imageIndex<swipeBannerImages.count)
    {
        bannerImage.image=[swipeBannerImages objectAtIndex:imageIndex];
        UIImageView *moveIMageView = bannerImage;
        [self addRightAnimationPresentToView:moveIMageView];
        int page=imageIndex;
        imagePageControl.currentPage=page;
    }
    else
    {
        imageIndex++;
    }
}

#pragma mark - end

#pragma mark - Clear textfield button action

- (IBAction)clearTextfieldAction:(id)sender
{
    if ([sender tag]==1)
    {
        searchService.text=@"";
        clearSearchBtn.hidden=YES;
    }
    else if ([sender tag]==2)
    {
        locationSearch.text=@"";
        clearLocationBtn.hidden=YES;
    }
}
#pragma mark - end

#pragma mark - Pagination for category
//Handling pagination in collection view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView1
{
    if (paginationView.hidden==YES)
    {
        if (categoryCollectionView.contentOffset.y == categoryCollectionView.contentSize.height - scrollView1.frame.size.height)
        {
            if (getCategoryArray.count<totalNoOfRecords)
            {
                paginationView.hidden=NO;
                
                
                Offset=[NSString stringWithFormat:@"%lu",(unsigned long)getCategoryArray.count];
                
                [self performSelector:@selector(getServiceCategoryListFromWebservice) withObject:nil afterDelay:0.1];
                
            }
        }
    }
}
-(void)hideactivityIndicator
{
    paginationView.hidden=YES;
    [categoryCollectionView reloadData];
}

#pragma mark - end

#pragma mark - MJGeocoderDelegate
//Getting the location of store added
- (void)geocoder:(MJGeocoder *)geocoder didFindLocations:(NSArray *)locations
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSArray * displayedResults = [locations mutableCopy] ;
    Address *address = [displayedResults objectAtIndex:0];
    latitude=address.latitude;
    longitude=address.longitude ;
    [myDelegate StopIndicator];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ServiceProviderViewController *serviceProviderList =[storyboard instantiateViewControllerWithIdentifier:@"ServiceProviderViewController"];
    serviceProviderList.subCatServiceID=@"";
    serviceProviderList.searchKey=searchService.text;
    NSString *trimmedString = [locationSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    serviceProviderList.customLocation=trimmedString;
    serviceProviderList.latitude=latitude;
    serviceProviderList.longitude=longitude;
    [self.navigationController pushViewController:serviceProviderList animated:YES];
}

- (void)geocoder:(MJGeocoder *)geocoder didFailWithError:(NSError *)error
{
    [myDelegate StopIndicator];
    if([error code] == 1)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You have entered an invalid location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
#pragma mark - end
@end
