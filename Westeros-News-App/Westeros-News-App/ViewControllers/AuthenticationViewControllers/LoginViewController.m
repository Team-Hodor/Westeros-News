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

#define NEWS_CONTROLLER_ID @"newsNavigationController";

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonTouchUpInside:(id)sender {
    
    [WebServiceManager loginUserWithUsername:self.usernameTextField.text andPassword:self.passwordTextField.text completion:^(NSDictionary *resultData, NSURLResponse *response, NSError *error) {
            if ( ![resultData objectForKey:@"id"] ) {
                NSDictionary *errors =[resultData objectForKey:@"errors"];
                [UIAlertController showAlertWithTitle:@"Error"
                                           andMessage:@"Invalid username or password."
                                     inViewController:self
                                          withHandler:nil];
                
            } else if( [resultData objectForKey:@"id"] ){
                NSString *sessionId = [resultData objectForKey:@"id"];
                NSString *username = self.usernameTextField.text;
                NSString *uniqueId = [resultData objectForKey:@"uid"];
                
                User *loggedUser = [[User alloc] initWithUsername:username andSessionId:sessionId andUniqueId:uniqueId];
                
                [DataRepository sharedInstance].loggedUser = loggedUser;
                
                [UIAlertController showAlertWithTitle:@"Success"
                                           andMessage:@"You have logged in successfully."
                                     inViewController:self
                                          withHandler:^(void) {
                                              [self showNewsViewController];
                                          }];
            } else {
                [UIAlertController showAlertWithTitle:@"Error"
                                           andMessage:@"There was an error while processing your request. Please try again later."
                                     inViewController:self
                                          withHandler:nil];
            }
    }];
}

- (IBAction)cancelButtonTouchUpInside:(id)sender {
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

@end
