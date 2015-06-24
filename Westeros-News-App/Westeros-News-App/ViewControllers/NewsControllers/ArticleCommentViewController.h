//
//  ArticleCommentViewController.h
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/21/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardBar.h"

@interface ArticleCommentViewController : UIViewController

@property (weak, nonatomic) id<KeyboardBarDelegate> keyboardBarDelegate;

@end
