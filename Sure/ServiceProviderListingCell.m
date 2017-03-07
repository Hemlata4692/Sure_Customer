//
//  ServiceProviderListingCell.m
//  Sure
//
//  Created by Hema on 16/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "ServiceProviderListingCell.h"
#import <UIImageView+AFNetworking.h>

@implementation ServiceProviderListingCell

@synthesize businessName;
@synthesize serviceProviderImage;
@synthesize serviceProviderName;
@synthesize bookingLabel;
@synthesize firstServiceName;
@synthesize secondServiceName;
@synthesize thirdServiceName;
@synthesize firstServiceCharge;
@synthesize secondServiceCharge;
@synthesize thirdServiceCharge;
@synthesize staticStarRatingView;
@synthesize serviceBackView;
@synthesize secondTick;
@synthesize thirdTick;
@synthesize separator;
@synthesize firstTick;
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //[myradio addTarget:self action:@selector(radioTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Setframes of objects

-(void)removeAutolaouts:(CGRect)viewSize
{
    serviceBackView.translatesAutoresizingMaskIntoConstraints=YES;
    firstTick.translatesAutoresizingMaskIntoConstraints =YES;
    secondTick.translatesAutoresizingMaskIntoConstraints =YES;
    thirdTick.translatesAutoresizingMaskIntoConstraints =YES;
    firstServiceName.translatesAutoresizingMaskIntoConstraints =YES;
    firstServiceCharge.translatesAutoresizingMaskIntoConstraints =YES;
    secondServiceName.translatesAutoresizingMaskIntoConstraints =YES;
    secondServiceCharge.translatesAutoresizingMaskIntoConstraints =YES;
    thirdServiceName.translatesAutoresizingMaskIntoConstraints =YES;
    thirdServiceCharge.translatesAutoresizingMaskIntoConstraints =YES;
    separator.translatesAutoresizingMaskIntoConstraints=YES;
    businessName.translatesAutoresizingMaskIntoConstraints=YES;
    serviceProviderName.translatesAutoresizingMaskIntoConstraints=YES;
    [self setFrameToObjects:viewSize];
    
}

-(void)setFrameToObjects:(CGRect)viewSize
{
    self.serviceProviderImage.layer.cornerRadius=30.0f;
    self.serviceProviderImage.clipsToBounds=YES;
    self.bookingLabel.layer.cornerRadius=6.0f;
    self.bookingLabel.clipsToBounds=YES;
  
    serviceBackView.frame=CGRectMake(serviceBackView.frame.origin.x, 101, serviceBackView.frame.size.width+10, serviceBackView.frame.size.height);
    
    firstServiceName.frame = CGRectMake(firstServiceName.frame.origin.x, 2, firstServiceName.frame.size.width, firstServiceName.frame.size.height);
    secondServiceName.frame = CGRectMake(secondServiceName.frame.origin.x, 29, secondServiceName.frame.size.width, secondServiceName.frame.size.height);
    thirdServiceName.frame = CGRectMake(thirdServiceName.frame.origin.x, 57, thirdServiceName.frame.size.width, thirdServiceName.frame.size.height);
    firstServiceCharge.frame =CGRectMake(serviceBackView.frame.size.width-105, 3, firstServiceCharge.frame.size.width, firstServiceCharge.frame.size.height);
    secondServiceCharge.frame =CGRectMake(serviceBackView.frame.size.width-105, 30, secondServiceCharge.frame.size.width, secondServiceCharge.frame.size.height);
    thirdServiceCharge.frame =CGRectMake(serviceBackView.frame.size.width-105, 59, thirdServiceCharge.frame.size.width, thirdServiceCharge.frame.size.height);
    firstTick.frame = CGRectMake(firstTick.frame.origin.x, 10, firstTick.frame.size.width, firstTick.frame.size.height);
    secondTick.frame = CGRectMake(secondTick.frame.origin.x, 37, secondTick.frame.size.width, secondTick.frame.size.height);
    thirdTick.frame = CGRectMake(thirdTick.frame.origin.x, 65, thirdTick.frame.size.width, thirdTick.frame.size.height);
    separator.frame = CGRectMake(self.separator.frame.origin.x, self.serviceBackView.frame.origin.y+self.serviceBackView.frame.size.height+5, viewSize.size.width, self.separator.frame.size.height);
    
}

#pragma mark - end

#pragma mark - Display data from webservice

-(void)displaySpListData :(RequestSentModel *)spListData :(int)indexPath viewSize:(CGRect)viewSize
{
    serviceProviderName.font=[UIFont fontWithName:@"Helvetica Neue" size:16];
    CGSize size = CGSizeMake(135,999);
    CGRect textRect = [spListData.name
                       boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:16]}
                       context:nil];
   
    textRect.origin.x = serviceProviderName.frame.origin.x;
    textRect.origin.y = 20;
    serviceProviderName.frame = textRect;
    serviceProviderName.text=spListData.name;
    
    businessName.frame=CGRectMake(serviceProviderName.frame.origin.x,serviceProviderName.frame.size.height+20,businessName.frame.size.width,businessName.frame.size.height);
    businessName.numberOfLines=2;
    businessName.text=spListData.businessName;
     if ([spListData.bookingCount intValue]>1)
    {
        bookingLabel.text=[NSString stringWithFormat:@" %@ Bookings",spListData.bookingCount];
    }
    else
    {
        bookingLabel.text=[NSString stringWithFormat:@" %@ Booking",spListData.bookingCount];
    }
    
    
    NSString *tempImageString=spListData.profileImage;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:tempImageString] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    
    
    [serviceProviderImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"profile_placehoder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         serviceProviderImage.contentMode = UIViewContentModeScaleAspectFill;
         serviceProviderImage.clipsToBounds=YES;
         serviceProviderImage.image = image;
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];
    staticStarRatingView.backgroundColor = [UIColor clearColor];
    staticStarRatingView.canEdit=NO;
    staticStarRatingView.leftMargin=.2;
    staticStarRatingView.midMargin=.5;
    staticStarRatingView.maxRating = 5;
    staticStarRatingView.rating = [spListData.rating floatValue];
    staticStarRatingView.minAllowedRating = .5;
    staticStarRatingView.maxAllowedRating = 5;
    
    serviceBackView.translatesAutoresizingMaskIntoConstraints = YES;
    for (int i =0; i<spListData.serviceList.count; i++)
    {
        ServiceListModel *objModel = [spListData.serviceList objectAtIndex:i];
        
        switch (i)
        {
            case 0:
                firstServiceName.text = objModel.serviceName;
                firstServiceCharge.text =objModel.serviceCharge;
                secondServiceCharge.hidden = YES;
                secondServiceName.hidden =YES;
                secondTick.hidden =YES;
                thirdServiceName.hidden = YES;
                thirdServiceCharge.hidden = YES;
                thirdTick.hidden = YES;
                serviceBackView.frame = CGRectMake(self.serviceBackView.frame.origin.x, self.serviceBackView.frame.origin.y, viewSize.size.width-26, 33);
                break;
            case 1:
                secondServiceCharge.hidden = NO;
                secondServiceName.hidden =NO;
                secondTick.hidden =NO;
                thirdServiceName.hidden = YES;
                thirdServiceCharge.hidden = YES;
                thirdTick.hidden = YES;
                secondServiceName.text = objModel.serviceName;
                secondServiceCharge.text =objModel.serviceCharge;
                serviceBackView.frame = CGRectMake(self.serviceBackView.frame.origin.x, self.serviceBackView.frame.origin.y, viewSize.size.width-26, 60);
                break;
            case 2:
                thirdServiceName.hidden = NO;
                thirdServiceCharge.hidden = NO;
                thirdTick.hidden = NO;
                thirdServiceName.text = objModel.serviceName;
                thirdServiceCharge.text =objModel.serviceCharge;
                serviceBackView.frame = CGRectMake(self.serviceBackView.frame.origin.x, self.serviceBackView.frame.origin.y, viewSize.size.width-26, 90);
                break;
            default:
                firstServiceName.text = @"No services available.";
                firstServiceCharge.text = @"N.A.";
                break;
        }
    }
    [self removeAutolaouts:viewSize];
    
}

#pragma mark - end
@end
