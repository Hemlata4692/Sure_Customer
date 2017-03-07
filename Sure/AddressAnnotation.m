//
//  AddressAnnotation.m
//  Sure_sp
//
//  Created by Sumit on 27/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "AddressAnnotation.h"

@implementation AddressAnnotation
@synthesize coordinate,title,pinImage;

- (NSString *)subtitle
{
    return nil;
}

//- (NSString *)title
//{
//    return nil;
//}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
    coordinate=c;
    return self;
}
- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d
{
    
    title = ttl;
    coordinate = c2d;
    return self;
}
@end
