//
//  HolidayViewController.m
//  HRM360
//
//  Created by Ranosys on 12/02/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "MyProfileViewController.h"
#import "SWRevealViewController.h"
#import "UITextField+Padding.h"
#import "UIView+RoundedCorner.h"
#import "UITextField+Validations.m"
#import "ProfileDataModel.h"
#import "UIPlaceHolderTextView.h"

@interface MyProfileViewController ()<UIGestureRecognizerDelegate,SWRevealViewControllerDelegate>
{
    NSArray *textFields;
}
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (weak, nonatomic) IBOutlet UIView *loginTextFieldView;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userContact;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextView *privacyPolicy;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *addressField;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic,retain)NSMutableArray * getMyProfileData;
@end

@implementation MyProfileViewController
@synthesize userEmail,addressField,userContact,userName,privacyPolicy,loginTextFieldView,getMyProfileData,Name;

- (void)viewDidLoad
{
    [super viewDidLoad];
    userName.delegate=self;
    userEmail.delegate=self;
    userContact.delegate=self;
    addressField.delegate=self;
    userName.autocapitalizationType=UITextAutocapitalizationTypeSentences;
    [self addTextFieldPadding];
    [self roundCorner];
    getMyProfileData=[[NSMutableArray alloc]init];
    textFields = @[userName,userContact,addressField];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFields]];
    [self.keyboardControls setDelegate:self];
    [[NSUserDefaults standardUserDefaults]setObject:@"false" forKey:@"state"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [addressField setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
    [addressField setPlaceholder:@"Your address here"];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getProfileDataFromServer) withObject:nil afterDelay:.1];
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
}

-(void) dealloc
{
    getMyProfileData=nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) roundCorner
{
    [addressField setCornerRadius:1.0f];
    [loginTextFieldView setCornerRadius:1.0f];
    [privacyPolicy setCornerRadius:1.0f];
}

-(void) addTextFieldPadding
{
    [userEmail addTextFieldPaddingWithoutImages:userEmail];
    [userName addTextFieldPaddingWithoutImages:userName];
    [userContact addTextFieldPaddingWithoutImages:userContact];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"My Profile";
}

#pragma mark - Keyboard Controls Delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *view;
    
    if ([[UIDevice currentDevice].systemVersion floatValue]< 7.0) {
        view = field.superview.superview;
    } else {
        view = field.superview.superview.superview;
    }
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    
    [keyboardControls.activeField resignFirstResponder];
    
}

#pragma mark - end

#pragma mark - Textfield Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
    if([[UIScreen mainScreen] bounds].size.height<=568)
    {
        if (textField==userContact)
        {
            self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        }
    }
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.keyboardControls setActiveField:textView];
    if([[UIScreen mainScreen] bounds].size.height<=568)
    {
        if (textView==addressField)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-130, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - end

#pragma mark - Save Profile Actions
//Action to save profile data
- (IBAction)saveProfileButtonAction:(id)sender
{
    [_keyboardControls.activeField resignFirstResponder];
    
    if ([self performValidationsForProfile])
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(saveProfileDataToServer) withObject:nil afterDelay:.1];
    }
}
//Method to perform validations before saving profile data
- (BOOL)performValidationsForProfile
{
    UIAlertView *alert;
    if (![userEmail isEmpty])
    {
        if (![userEmail isValidEmail])
        {
            alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter valid Email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    return YES;
}
#pragma mark - end

#pragma mark - Webservice Methods
//Method to save profile data to server
-(void)saveProfileDataToServer
{
    [[WebService sharedManager] myProfile:userName.text contactNo:userContact.text address:addressField.text success:^(id responseObject)
     {
         NSDictionary *dict = (NSDictionary *)responseObject;
         [[NSUserDefaults standardUserDefaults] setValue:userName.text  forKey:@"Name"];
         
         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [alert show];
         
     } failure:^(NSError *error) {
         
     }] ;
}
//Method to get profile data from server
-(void)getProfileDataFromServer
{
    [[WebService sharedManager] getProfileData:^(id getProfileData)
     {
         
         getMyProfileData=[getProfileData mutableCopy];
         [self displayMyProfileData];
         
     } failure:^(NSError *error) {
         
     }] ;
    
}
//Method to display profile data
-(void) displayMyProfileData
{
    ProfileDataModel *data =[getMyProfileData objectAtIndex:0];
    userName.text=data.Name;
    Name=data.Name;
    addressField.text=data.Address;
    userEmail.text=data.Email;
    userContact.text=data.PhoneNo;
}
#pragma mark - end
@end
