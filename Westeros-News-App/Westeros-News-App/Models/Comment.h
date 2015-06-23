//
//  Comment.h
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/22/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (nonatomic, strong) NSString *authorId;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *uniqueId;

- (instancetype)initWithContent:(NSString *)content
                       authorId:(NSString *)authorId
                      createdAt:(NSDate *)createdAt
                    andUniqueId:(NSString *)uniqueId;

@end
