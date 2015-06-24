//
//  NewsTableViewCell.h
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/12/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface NewsTableViewCell : UITableViewCell

@property (nonatomic, strong) Article *article;

- (void)setArticleImage;

@end
