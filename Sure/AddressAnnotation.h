//
//  AddressAnnotation.h
//  Sure_sp
//
//  Created by Sumit on 27/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface AddressAnnotation : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    UIImage *pinImage;
    
}
@property (nonatomic, assign) MKPinAnnotationColor myPinColor;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *pinImage;
-(id)initWithCoordinate:(CLLocationCoordinate2D) c;
- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d;
@end
