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

@interface EditUserNameViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTxtField;

@end

@implementation EditUserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)editTapped:(id)sender {
    
    User *user = [[DataRepository sharedInstance] loggedUser];
    [WebServiceManager EditUserName:self.nameTxtField.text sessionToken:user.sessionToken completion:^(NSDictionary *resultData, NSHTTPURLResponse *response, NSError *error) {
        if ( [resultData objectForKey:@"error"] ) {
            
            [UIAlertController showAlertWithTitle:@"Error"
                                       andMessage:@"Couldn't edit name."
                                 inViewController:self
                                      withHandler:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];

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
