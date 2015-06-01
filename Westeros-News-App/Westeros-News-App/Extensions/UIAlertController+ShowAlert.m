//
//  UIAlertController+ShowAlert.m
//  13.RentApartments
//
//  Created by P. Mihaylov on 5/18/15.
//  Copyright (c) 2015 Mihaylov. All rights reserved.
//

#import "UIAlertController+ShowAlert.h"

@implementation UIAlertController (ShowAlert)

+ (void)showAlertWithTitle:(NSString *)title
                andMessage:(NSString *)message
          inViewController:(UIViewController *)controller
                withHandler:(void (^)())action {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:action];
    
    [alertController addAction:okAction];
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

@end
