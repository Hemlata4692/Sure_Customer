//
//  LoginViewController.m
//  SidebarDemoApp
//
//  Created by Ranosys on 11/02/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "LoginViewController.h"

#import "UIView+RoundedCorner.h"
#import "UITextField+Padding.h"
#import "UITextField+Validations.m"


@interface LoginViewController ()
{
    NSArray *textFields;
    
}


-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification;

@property (weak, nonatomic) IBOutlet UIButton *loginFbBtn;
@property (weak, nonatomic) IBOutlet UIView *loginViewFields;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backgroundSignUpView;
@property (weak, nonatomic) IBOutlet UIView *signUpView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIScrollView *signUpScrollView;
@property (weak, nonatomic) IBOutlet UITextField *signUpEmail;
@property (weak, nonatomic) IBOutlet UITextField *signUpPassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (strong, nonatomic) NSString *userEmailFb;


@end

@implementation LoginViewController

@synthesize loginBtn,loginFbBtn,loginViewFields,userEmail,userPassword,scrollView,backgroundImage;
@synthesize signUpEmail,signUpPassword,signUpScrollView,confirmPassword,signUpView,backgroundSignUpView,userEmailFb;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    backgroundSignUpView.hidden=YES;
    //get image according to device
    backgroundImage.translatesAutoresizingMaskIntoConstraints = YES;
    backgroundImage.frame = CGRectMake(self.scrollView.frame.origin.x, 0, self.view.bounds.size.width+8, self.view.bounds.size.height);
    UIImage * tempImg =[UIImage imageNamed:@"bg"];
    backgroundImage.image = [UIImage imageNamed:[tempImg imageForDeviceWithName:@"bg"]];
    userEmail.delegate=self;
    userPassword.delegate=self;
    signUpEmail.delegate=self;
    signUpPassword.delegate=self;
    confirmPassword.delegate=self;
    
    [self addTextFieldPadding];
    [self roundedCorner];
    [self addingTextFieldBorder];
    
    //Adding textfield to array
    textFields = @[userEmail,userPassword];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFields]];
    [self.keyboardControls setDelegate:self];
    
    //facebook
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Observe for the custom notification regarding the session state change.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFBSessionStateChangeWithNotification:)
                                                 name:@"SessionStateChangeNotification"
                                               object:nil];
    
    
}

-(void)addingTextFieldBorder
{
    signUpEmail.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:196.0/255.0 blue:197.0/255.0 alpha:1.0]CGColor];
    signUpEmail.layer.borderWidth= 1.0f;
    
    signUpPassword.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:196.0/255.0 blue:197.0/255.0 alpha:1.0]CGColor];
    signUpPassword.layer.borderWidth= 1.0f;
    
    confirmPassword.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:196.0/255.0 blue:197.0/255.0 alpha:1.0]CGColor];
    confirmPassword.layer.borderWidth= 1.0f;
}

-(void)addTextFieldPadding
{
    [userEmail addTextFieldPadding:userEmail];
    [userPassword addTextFieldPadding:userPassword];
    [signUpEmail addTextFieldPadding:signUpEmail];
    [signUpPassword addTextFieldPadding:signUpPassword];
    [confirmPassword addTextFieldPadding:confirmPassword];
}

-(void) roundedCorner
{
    [loginViewFields setCornerRadius:2.0f];
    [loginFbBtn setCornerRadius:2.0f];
    [loginBtn setCornerRadius:2.0f];
    [signUpEmail setCornerRadius:2.0f];
    [signUpPassword setCornerRadius:2.0f];
    [confirmPassword setCornerRadius:2.0f];
    [signUpView setCornerRadius:2.0f];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:192.0/255.0 green:37.0/255.0 blue:43.0/255.0 alpha:1.0];
    [self.view addSubview:statusBarView];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    if([[UIScreen mainScreen] bounds].size.height>480)
    {
        signUpScrollView.scrollEnabled=NO;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - end

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
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [signUpScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - end

#pragma mark - Textfield Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [self.keyboardControls setActiveField:textField];
    
    [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y+( textField.frame.size.height)) animated:YES];
    
    
    if (backgroundSignUpView.hidden==NO)
    {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
    
    if (textField==signUpEmail)
    {
        signUpEmail.layer.borderColor=[[UIColor colorWithRed:255.0/255.0 green:130.0/255.0 blue:128.0/255.0 alpha:1.0]CGColor];
        signUpEmail.layer.borderWidth= 1.0f;
        [signUpScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (textField==signUpPassword)
    {
        signUpPassword.layer.borderColor=[[UIColor colorWithRed:255.0/255.0 green:130.0/255.0 blue:128.0/255.0 alpha:1.0]CGColor];
        signUpPassword.layer.borderWidth= 1.0f;
        [signUpScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-90) animated:YES];
    }
    else if (textField==confirmPassword)
    {
        
        confirmPassword.layer.borderColor=[[UIColor colorWithRed:255.0/255.0 green:130.0/255.0 blue:128.0/255.0 alpha:1.0]CGColor];
        confirmPassword.layer.borderWidth= 1.0f;
        [signUpScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-100) animated:YES];
        
    }
    
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [signUpScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    if (textField==signUpEmail)
    {
        signUpEmail.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:196.0/255.0 blue:197.0/255.0 alpha:1.0]CGColor];
        signUpEmail.layer.borderWidth= 1.0f;
    }
    else if (textField==signUpPassword)
    {
        signUpPassword.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:196.0/255.0 blue:197.0/255.0 alpha:1.0]CGColor];
        signUpPassword.layer.borderWidth= 1.0f;
        
    }
    else if (textField==confirmPassword)
    {
        
        confirmPassword.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:196.0/255.0 blue:197.0/255.0 alpha:1.0]CGColor];
        confirmPassword.layer.borderWidth= 1.0f;
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - end


#pragma mark - Login view methods
- (BOOL)performValidationsForLogin
{
    UIAlertView *alert;
    if ([userEmail isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter the Email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
        if ([userEmail isValidEmail])
        {
            if ([userPassword isEmpty])
            {
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter the Password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }
            else if (userPassword.text.length<6)
            {
                
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Password should be at least six digits." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }
            else
            {
                return YES;
            }
        }
        else
        {
            alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter valid Email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
}

- (IBAction)loginButtonClicked:(id)sender
{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [userEmail resignFirstResponder];
    [userPassword resignFirstResponder];
    
    if([self performValidationsForLogin])
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(loginUser) withObject:nil afterDelay:.1];
    }
    
}

-(void)loginUser
{
    [[WebService sharedManager] userLogin:userEmail.text andPassword:userPassword.text success:^(id responseObject) {
        // 1. can not login as email or password are incorrect
        [myDelegate StopIndicator];
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"UserId"] forKey:@"UserId"];
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"Name"] forKey:@"Name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [myDelegate registerDeviceForNotification];
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *view1=[sb instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [myDelegate getCityFromServer];
        [self.navigationController pushViewController:view1 animated:YES];
        
    } failure:^(NSError *error) {
        
    }] ;
    
    
    
}

- (IBAction)createAccountButtonClicked:(id)sender
{
    textFields = @[signUpEmail,signUpPassword, confirmPassword];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFields]];
    [self.keyboardControls setDelegate:self];
    
    backgroundSignUpView.hidden=NO;
    
    
}
#pragma mark - end

#pragma mark - Sign up methods
- (IBAction)hideRegistrationPopup:(id)sender
{
    backgroundSignUpView.hidden=YES;
    textFields = @[userEmail,userPassword];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFields]];
    [self.keyboardControls setDelegate:self];
}
- (IBAction)signUpButtonClicked:(id)sender
{
    if([self performValidationsForSignUp])
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(signUpUser) withObject:nil afterDelay:.1];
    }
    
}

- (BOOL)performValidationsForSignUp
{
    UIAlertView *alert;
    if ([signUpEmail isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter a valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
        if ([signUpEmail isValidEmail])
        {
            if ([signUpPassword isEmpty])
            {
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter the Password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }
            else if (signUpPassword.text.length<6)
            {
                
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Your password must be atleast 6 characters long." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
                
            }
            else if (!([signUpPassword.text isEqualToString:confirmPassword.text]))
            {
                
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Password and confirm password must be same." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }
            else
            {
                return YES;
            }
        }
        else
        {
            alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter valid Email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
}


-(void)signUpUser
{
    NSLog(@"signup user");
    [[WebService sharedManager] registerUser:signUpEmail.text password:signUpPassword.text success:^(id responseObject) {
        // 1. can not login as email or password are incorrect
        [myDelegate StopIndicator];
        NSDictionary *dict = (NSDictionary *)responseObject;
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"UserId"] forKey:@"UserId"];
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"Name"] forKey:@"Name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [myDelegate registerDeviceForNotification];
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *view1=[sb instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [myDelegate getCityFromServer];
        [self.navigationController pushViewController:view1 animated:YES];
        
    } failure:^(NSError *error) {
        
    }] ;
 
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 10 && buttonIndex==0)
    {
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *view1=[sb instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController pushViewController:view1 animated:YES];
    }
}


#pragma mark - end

#pragma mark - Login with facebook

- (IBAction)loginWithFacebookButtonClicked:(id)sender
{
    
    if ([FBSession activeSession].state != FBSessionStateOpen && [FBSession activeSession].state != FBSessionStateOpenTokenExtended)
    {
       
        [myDelegate openActiveSessionWithPermissions:@[@"email"] allowLoginUI:YES];
        
    }
    else
    {
        // Close an existing session.
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
}

-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    NSDictionary *userInfo = [notification userInfo];
    
    FBSessionState sessionState = (int)[[userInfo objectForKey:@"state"] integerValue];
   //  NSString *fbAccessToken = [FBSession activeSession].accessTokenData.accessToken;
    NSError *error = [userInfo objectForKey:@"error"];
    
    if (!error) {
        if (sessionState == FBSessionStateOpen)
        {
            [myDelegate ShowIndicator];
            [FBRequestConnection startWithGraphPath:@"me"
                                         parameters:@{@"fields": @"email"}
                                         HTTPMethod:@"GET"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if (!error)
                                      {
                                        userEmailFb=[result objectForKey:@"email"];
                                          [myDelegate ShowIndicator];
                                          [self performSelector:@selector(userLoginFb) withObject:nil afterDelay:.1];
                                      }
                                     
                                  }];
        }
        else if (sessionState == FBSessionStateClosed || sessionState == FBSessionStateClosedLoginFailed)
        {
            [myDelegate StopIndicator];
        }
    }
    else
    {
        [myDelegate StopIndicator];
    }
}


-(void)userLoginFb
{
    NSLog(@"Fb login");
    [[WebService sharedManager]userLoginFb:userEmailFb success:^(id responseObject) {
        // 1. can not login as email or password are incorrect
        [myDelegate StopIndicator];
        NSDictionary *dict = (NSDictionary *)responseObject;
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"UserId"] forKey:@"UserId"];
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"Name"] forKey:@"Name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [myDelegate registerDeviceForNotification];
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *view1=[sb instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [myDelegate getCityFromServer];
        [self.navigationController pushViewController:view1 animated:YES];
        
    } failure:^(NSError *error) {
        
    }] ;
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    
}
#pragma mark - end

@end
