//
//  LoginViewController.m
//  13.RentApartments
//
//  Created by P. Mihaylov on 5/16/15.
//  Copyright (c) 2015 Mihaylov. All rights reserved.
//

#import "LoginViewController.h"
#import "ServerManager.h"
#import "User.h"
#import "UIAlertController+ShowAlert.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIView *activeField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonTouchUpInside:(id)sender {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    NSManagedObjectContext *context = [[ServerManager sharedInstance] masterContext];
    
    User *user = [self userWithUsername:username andPassword:password inContext:context];
    
    if (user) {
        // [UserManager sharedInstance].loggedUser = user;
        // TODO: Set logged user
        
        [UIAlertController showAlertWithTitle:@"Success"
                      andMessage:@"You have logged in successfully"
                             inViewController:self
                                  withHandler:^() {
                          // TODO: Show all news page
                      }];
    } else {
        [UIAlertController showAlertWithTitle:@"Error"
                                   andMessage:@"Invalid username or password"
                                 inViewController:self
                                      withHandler:nil];
    }
}

- (IBAction)cancelButtonTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(User *) userWithUsername:(NSString *)username
                    andPassword:(NSString *)password
                      inContext:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"User" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(username = %@) AND (password = %@)", username, password];
    
    [request setPredicate:predicate];
    
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if ([array count] == 0)
    {
        return nil;
    } else {
        return (User *)array[0];
    }
}

- (void) showApartmentsViewController {
    UINavigationController *navController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"navController"];
    
    [self presentViewController:navController animated:YES completion:nil];
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
