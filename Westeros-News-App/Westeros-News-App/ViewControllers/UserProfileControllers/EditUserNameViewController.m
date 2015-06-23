//
//  EditUserNameViewController.m
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/20/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "EditUserNameViewController.h"
#import "DataRepository.h"
#import "WebServiceManager.h"
#import "UIAlertController+ShowAlert.h"

@interface EditUserNameViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTxtField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation EditUserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self performInitialConfiguration];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

- (IBAction)editTapped:(id)sender {
    
    User *user = [[DataRepository sharedInstance] loggedUser];
    
    if([self areFieldsValidated]){
        
        [WebServiceManager editUserName:self.nameTxtField.text sessionToken:user.sessionToken completion:^(NSDictionary *resultData, NSHTTPURLResponse *response) {
            if ( [resultData objectForKey:@"error"] ) {
                
                [UIAlertController showAlertWithTitle:@"Error"
                                           andMessage:@"Couldn't edit name."
                                     inViewController:self
                                          withHandler:nil];
            }else{
                user.name = self.nameTxtField.text;
                
                [UIAlertController showAlertWithTitle:@"Success"
                                           andMessage:@"Name edited."
                                     inViewController:self
                                          withHandler:^{
                                          [self.navigationController popViewControllerAnimated:YES];
                                          }];
            }
        }];
        
    }

}

- (void)performInitialConfiguration {
    //set title color
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    //set text field value to user name
    self.nameTxtField.text = [DataRepository sharedInstance].loggedUser.name;
    
    //rounded corners
    self.saveButton.layer.cornerRadius = 4.0;
    self.saveButton.clipsToBounds = YES;
    
    [self registerForKeyboardNotifications];
    
    //register for gesture and hide keyboard when view touched
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:recognizer];
}

#pragma mark - Managing the keyboard

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillBeShown:(NSNotification*)aNotification{
    
         self.topConstraint.constant -= 100;
   
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification{

        self.topConstraint.constant += 100;
    
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

-(BOOL) areFieldsValidated {
    NSString *errorMessage;
    
    NSString *name = [self.nameTxtField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if ([name length] == 0) {
        errorMessage = @"The username text field cannot be empty.";
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
