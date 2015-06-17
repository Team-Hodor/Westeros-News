//
//  RegisterViewController.m
//  13.RentApartments
//
//  Created by P. Mihaylov on 5/16/15.
//  Copyright (c) 2015 Mihaylov. All rights reserved.
//

#import "RegisterViewController.h"
#import "DatabaseManager.h"
#import "UIAlertController+ShowAlert.h"
#import "DataRepository.h"
#import "WebServiceManager.h"

@interface RegisterViewController () <UITextFieldDelegate, NSURLSessionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *innerView;

@property (strong, nonatomic) UIView *activeField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitButtonTouchUpInside:(id)sender {
    UIButton *registerButton = ((UIButton *)sender);
    UIColor *defaultColor = registerButton.backgroundColor;
    registerButton.enabled = NO;
    registerButton.layer.backgroundColor = [UIColor grayColor].CGColor;
    
    if ([self areFieldsValidated]) {
        NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *password = self.passwordTextField.text;
        
        [WebServiceManager registerUserWithUsername:username
                                        andPassword:password
                                            andName:name
                                         completion:^(NSDictionary *resultData, NSURLResponse *response, NSError *error) {
                                             if ([[resultData objectForKey:@"error"] isEqualToString:@"Invalid JSON"]) {
                                                 // INTERNAL ERROR
                                                 NSLog(@"Internal error");
                    
                                                    [UIAlertController showAlertWithTitle:@"Error"
                                                                            andMessage:@"There was an error saving the data on the server. Please try again later."
                                                                      inViewController:self
                                                                              withHandler:nil];
                                                 registerButton.enabled = YES;
                                                 registerButton.layer.backgroundColor = defaultColor.CGColor;
                                             } else if ( [resultData objectForKey:@"error"] ) {
                                                 [UIAlertController showAlertWithTitle:@"Error"
                                                                            andMessage:@"Username already taken."
                                                                      inViewController:self
                                                                           withHandler:nil];
                                                 registerButton.enabled = YES;
                                                 registerButton.layer.backgroundColor = defaultColor.CGColor;
                                             } else {
                                                 [UIAlertController showAlertWithTitle:@"Success"
                                                                            andMessage:@"Username registered successfully."
                                                                      inViewController:self
                                                                           withHandler:^() {
                                                                               [self.view endEditing:YES];
                                                                               [self dismissViewControllerAnimated:YES completion:nil];
                                                                           }];
                                             }
                                         }];
    } else {
        registerButton.enabled = YES;
        registerButton.layer.backgroundColor = defaultColor.CGColor;
    }
}

- (IBAction)cancelButtonTouchUpInside:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) areFieldsValidated {
    NSString *errorMessage;
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *password = self.passwordTextField.text;
    
    if ([username length] == 0) {
        errorMessage = @"The username text field cannot be empty.";
    } else if ([password length] == 0) {
        errorMessage = @"The password text field cannot be empty.";
    } else if ([name length] == 0) {
        errorMessage = @"The name text field cannot be empty";
    }
    
    if (!errorMessage) {
        return YES;
    } else {
        [UIAlertController showAlertWithTitle:@"Error"
                                   andMessage:errorMessage
                             inViewController:self
                                  withHandler:nil];
        return NO;
    }
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
