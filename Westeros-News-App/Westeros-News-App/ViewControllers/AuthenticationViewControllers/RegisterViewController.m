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
    [self registerUser];
/*
    if ([self areFieldsValidated]) {
        NSManagedObjectContext *workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        [workerContext setParentContext:[ServerManager sharedInstance].mainContext];
        NSManagedObjectContext *masterContext = [ServerManager sharedInstance].masterContext;
        
        
        if ([self isValidUserWithUsername:self.usernameTextField.text inContext:masterContext]) {
            NSEntityDescription *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                                         inManagedObjectContext:workerContext];
            
            [newUser setValue:self.usernameTextField.text forKey:@"username"];
            [newUser setValue:self.passwordTextField.text forKey:@"password"];
            [newUser setValue:self.nameTextField.text forKey:@"name"];
        
            // Send request to server for registration
            
            
            NSError *error;
            [workerContext save:&error];
            if (!error) {
                [[ServerManager sharedInstance].mainContext save:&error];
                if (!error) {
                    [[ServerManager sharedInstance].masterContext save:&error];
                }
            }
            
            if (error) {
                [UIAlertController showAlertWithTitle:@"Error"
                                           andMessage:@"There was an error saving the data on the server."
                                     inViewController:self
                                          withHandler:nil];
            } else {
                [UIAlertController showAlertWithTitle:@"Success"
                                           andMessage:@"You have registered successfully."
                                     inViewController:self
                                          withHandler:^(void) {
                                              [self.view endEditing:YES];
                                              [self dismissViewControllerAnimated:YES completion:nil];
                                          }];
            }
        } else {
            [UIAlertController showAlertWithTitle:@"Error"
                                       andMessage:@"Invalid username. The specified username is already taken."
                                 inViewController:self
                                      withHandler:nil];
        }
        
    }
 */
}

- (IBAction)cancelButtonTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) areFieldsValidated {
    NSString *errorMessage;
    
    if ([self.usernameTextField.text length] == 0) {
        errorMessage = @"The username text field cannot be empty.";
    } else if ([self.passwordTextField.text length] == 0) {
        errorMessage = @"The password text field cannot be empty.";
    } else if ([self.nameTextField.text length] == 0) {
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

-(BOOL) isValidUserWithUsername:(NSString *)username inContext:(NSManagedObjectContext *)context{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"User" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(username = %@)", username];
    
    [request setPredicate:predicate];
    
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if ([array count] == 0)
    {
        return YES;
    } else {
        NSLog(@"%@", array);
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

#pragma mark - Register User with webservice

-(void)registerUser{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:@"/users"];
    NSURL *url = [NSURL URLWithString:serviceURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *userData = [NSString stringWithFormat:@"username=%@&password=%@&name=%@",self.usernameTextField.text, self.passwordTextField.text, self.nameTextField.text];
    [request setHTTPBody:[userData dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    if ([self areFieldsValidated]) {
        NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@", responseString);
                
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                if ([dictionary objectForKey:@"errors"]) {
                    NSDictionary *errors =[dictionary objectForKey:@"errors"];
                    [UIAlertController showAlertWithTitle:@"Error"
                                               andMessage:@"Invalid username. The specified username is already taken."
                                         inViewController:self
                                              withHandler:nil];

                }
                else if(([dictionary objectForKey:@"id"])){
                    [UIAlertController showAlertWithTitle:@"Success"
                                               andMessage:@"You have registered successfully."
                                         inViewController:self
                                              withHandler:^(void) {
                                                  [self.view endEditing:YES];
                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                              }];
                }else{
                    [UIAlertController showAlertWithTitle:@"Error"
                                               andMessage:@"There was an error saving the data on the server."
                                         inViewController:self
                                              withHandler:nil];
                }
                    });
            }
        }];
    [postDataTask resume];
    }
    

}


@end
