//
//  LoginViewController.h
//  SidebarDemoApp
//
//  Created by Ranosys on 11/02/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "BSKeyboardControls.h"

@interface LoginViewController : UIViewController<FBLoginViewDelegate,UITextFieldDelegate,BSKeyboardControlsDelegate>




@end
