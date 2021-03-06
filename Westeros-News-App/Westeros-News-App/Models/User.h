//
//  User.h
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/1/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSObject

@property (nonatomic, strong, readonly) NSString *sessionToken;
@property (nonatomic, strong, readonly) NSString *uniqueId;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *favouriteNews;
@property (nonatomic) BOOL isAdmin;

- (instancetype)initWithUsername:(NSString *)username name:(NSString *)name andSessionId:(NSString *)sessionId andUniqueId:(NSString *)uniqueId;

@end
