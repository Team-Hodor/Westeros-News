//
//  DataRepository.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/6/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "DataRepository.h"
#import "WebServiceManager.h"
#import <UIKit/UIKit.h>
#import "UIAlertController+ShowAlert.h"

@implementation DataRepository

static DataRepository *sharedInst = nil;

+ (DataRepository *)sharedInstance {
    @synchronized( self ) {
        if ( sharedInst == nil ) {
            /* sharedInst set up in init */
            [[self alloc] init];
        }
    }
    
    return sharedInst;
}

- (id)init {
    if ( sharedInst != nil ) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"[%@ %@] cannot be called; use +[%@ %@] instead",
         NSStringFromClass([self class]),
         NSStringFromSelector(_cmd),
         NSStringFromClass([self class]),
         NSStringFromSelector(@selector(sharedInstance))];
    } else if ( self = [super init] ) {
        sharedInst = self;
    }
    
    return sharedInst;
}

- (void)logoutLoggedUserInViewController:(UIViewController *)viewController {
    if (self.loggedUser) {
        [WebServiceManager logoutUserWithSessionId:self.loggedUser.sessionToken completion:^(NSDictionary *resultData, NSHTTPURLResponse *response) {
            if (true) {
                NSLog(@"Logged out");
                
                self.loggedUser = nil;
                [UIAlertController showAlertWithTitle:@"Success"
                                           andMessage:@"You have logged out successfully."
                                     inViewController:viewController
                                          withHandler:^() {
                                              [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
                                          }];
                
            } else {
                [UIAlertController showAlertWithTitle:@"Error"
                                           andMessage:@"There was an error logging out. Please try again later."
                                     inViewController:viewController
                                          withHandler:nil];
            }
        }];
    }
}

@end
