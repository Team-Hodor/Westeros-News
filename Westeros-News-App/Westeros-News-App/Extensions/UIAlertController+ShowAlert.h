//
//  UIAlertController+ShowAlert.h
//  13.RentApartments
//
//  Created by P. Mihaylov on 5/18/15.
//  Copyright (c) 2015 Mihaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (ShowAlert)

+ (void)showAlertWithTitle:(NSString *)title
                andMessage:(NSString *)message
          inViewController:(UIViewController *)controller
               withHandler:(void (^)())action;

@end
