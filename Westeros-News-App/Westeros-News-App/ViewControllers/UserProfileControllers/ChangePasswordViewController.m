//
//  ChangePasswordViewController.m
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/21/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "UIAlertController+ShowAlert.h"
#import "WebServiceManager.h"
#import "DataRepository.h"

@interface ChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTxtField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxtField;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

- (IBAction)changeButtonTapped:(UIButton *)sender {
    sender.enabled = NO;
    UIColor *defaultColor = sender.backgroundColor;
    sender.layer.backgroundColor = [UIColor grayColor].CGColor;
    
    User *user = [[DataRepository sharedInstance] loggedUser];
    
    NSString *oldPassword = self.oldPasswordTxtField.text;
    NSString *newPassword = self.passwordTxtField.text;
    
    if([self areFieldsValidated]){
        [WebServiceManager loginUserWithUsername:user.username andPassword:oldPassword completion:^(NSDictionary *resultData, NSURLResponse *response) {
            
            if ( [resultData objectForKey:@"error"] ) {
                self.oldPasswordTxtField.text = @"";
                self.passwordTxtField.text = @"";
                [UIAlertController showAlertWithTitle:@"Error"
                                           andMessage:@"Wrong old passowrd."
                                     inViewController:self
                                          withHandler:nil];
                sender.enabled = YES;
                sender.layer.backgroundColor = defaultColor.CGColor;
            } else if( [resultData objectForKey:@"createdAt"] ){
                
                [WebServiceManager changeUserPassword:newPassword sessionToken:user.sessionToken completion:^(NSDictionary *dataDictionary, NSHTTPURLResponse *response) {
                    self.oldPasswordTxtField.text = @"";
                    self.passwordTxtField.text = @"";
                    if ( [resultData objectForKey:@"error"] ) {
                        
                        [UIAlertController showAlertWithTitle:@"Error"
                                                   andMessage:@"Couldn't change password."
                                             inViewController:self
                                                  withHandler:nil];
                    }else{
                        
                        [UIAlertController showAlertWithTitle:@"Success"
                                                   andMessage:@"Password changed."
                                             inViewController:self
                                                  withHandler:^{
                                                  [self.navigationController popViewControllerAnimated:YES];
                                                  }];
                        
                        
                    }
                }];
                
            } else {
                [UIAlertController showAlertWithTitle:@"Error"
                                           andMessage:@"There was an error while processing your request. Please try again later."
                                     inViewController:self
                                          withHandler:nil];
                sender.enabled = YES;
                sender.layer.backgroundColor = defaultColor.CGColor;
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
    
    self.title = @"Change Password";
}

-(BOOL) areFieldsValidated {
    NSString *errorMessage;
    
    NSString *oldPassword = [self.oldPasswordTxtField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *newPassword = [self.passwordTxtField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([oldPassword length] == 0) {
        errorMessage = @"The old password text field cannot be empty.";
    }
    else if ([newPassword length] == 0){
        errorMessage = @"The new password text field cannot be empty.";
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
