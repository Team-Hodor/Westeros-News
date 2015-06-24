//
//  CustomTableView.h
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/23/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardBar.h"

@interface CustomTableView : UITableView

@property (weak, nonatomic) id<KeyboardBarDelegate> keyboardBarDelegate;

@end