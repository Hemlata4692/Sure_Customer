//
//  SearchDataModel.h
//  Sure
//
//  Created by Hema on 09/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchDataModel : NSObject

@property(nonatomic,retain)NSString * categoryId;
@property(nonatomic,retain)NSString * categoryImage;
@property(nonatomic,retain)NSString * categoryName;
@property(nonatomic,retain)NSString * bannerImage;
@property(nonatomic,assign)int  totalRecords;

@end
