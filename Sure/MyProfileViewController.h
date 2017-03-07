//
//  HolidayViewController.h
//  HRM360
//
//  Created by Ranosys on 12/02/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SureViewController.h"
#import "BSKeyboardControls.h"

@interface MyProfileViewController : SureViewController<UITextFieldDelegate,BSKeyboardControlsDelegate,UITextViewDelegate>
@property (strong,nonatomic) NSString *Name;
@end
