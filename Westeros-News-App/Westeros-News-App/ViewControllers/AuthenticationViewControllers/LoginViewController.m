//
//  LoginViewController.m
//  13.RentApartments
//
//  Created by P. Mihaylov on 5/16/15.
//  Copyright (c) 2015 Mihaylov. All rights reserved.
//

#import "LoginViewController.h"
#import "DatabaseManager.h"
#import "User.h"
#import "UIAlertController+ShowAlert.h"
#import "DataRepository.h"
#import "WebServiceManager.h"

@interface LoginViewController () <UITextFieldDelegate, NSURLSessionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIView *activeField;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

#define NEWS_CONTROLLER_ID @"newsNavigationController";

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.messageLabel.text = @"";
    
    //register for gesture and hide keyboard when view touched
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:recognizer];
    
    [self registerForKeyboardNotifications];
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonTouchUpInside:(id)sender {
    UIButton *loginButton = ((UIButton *)sender);
    loginButton.enabled = NO;
    UIColor *defaultColor = loginButton.backgroundColor;
    loginButton.layer.backgroundColor = [UIColor grayColor].CGColor;
    
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = self.passwordTextField.text;
    
    [WebServiceManager loginUserWithUsername:username andPassword:password completion:^(NSDictionary *resultData, NSURLResponse *response) {
            if ( [resultData objectForKey:@"error"] ) {
                
                [self showErrorMessage:@"Invalid username or password!"];
                loginButton.enabled = YES;
                loginButton.layer.backgroundColor = defaultColor.CGColor;
            } else if( [resultData objectForKey:@"createdAt"] ){
                NSString *sessionId = [resultData objectForKey:@"sessionToken"];
                NSString *uniqueId = [resultData objectForKey:@"objectId"];
                NSString *name = [resultData objectForKey:@"name"];
                NSMutableArray *favouriteNews = [[NSMutableArray alloc] init];
                
                for (id favourite in [resultData objectForKey:@"favourites"]) {
                    [favouriteNews addObject:[favourite objectForKey:@"objectId"]];
                }
                
                User *loggedUser = [[User alloc] initWithUsername:username
                                                             name:name
                                                     andSessionId:sessionId
                                                      andUniqueId:uniqueId];
                
                loggedUser.favouriteNews = favouriteNews;
                loggedUser.isAdmin = (BOOL)[resultData objectForKey:@"isAdmin"];
                
                [DataRepository sharedInstance].loggedUser = loggedUser;
                
                [self showSuccessMessage:@"Logg in successfull."];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    self.usernameTextField.text = @"";
                    self.passwordTextField.text = @"";
                    loginButton.enabled = YES;
                    loginButton.layer.backgroundColor = defaultColor.CGColor;
                    [self showNewsViewController];
                });
                
            } else {
                
                [self showErrorMessage:@"Error. Please again try later."];
                loginButton.enabled = YES;
                loginButton.layer.backgroundColor = defaultColor.CGColor;
            }
    }];
}

- (IBAction)cancelButtonTouchUpInside:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showNewsViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    UINavigationController *newsNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"newsNavigationController"];
    
    newsNavigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:newsNavigationController animated:YES completion:nil];
}

#pragma mark - Managing the keyboard

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

# pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)showErrorMessage:(NSString *)message{
    self.messageLabel.textColor = [UIColor redColor];
    self.messageLabel.text = message;
}

-(void)showSuccessMessage:(NSString *)message{
    self.messageLabel.textColor = [UIColor greenColor];
    self.messageLabel.text = message;
}

@end
