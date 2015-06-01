//
//  User.h
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/1/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;

@end
