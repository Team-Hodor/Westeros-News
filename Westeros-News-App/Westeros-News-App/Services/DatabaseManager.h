//
//  ServerManager.h
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/1/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "User.h"

@interface DatabaseManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *masterContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DatabaseManager *)sharedInstance;
- (NSManagedObjectContext *)workerContext;
- (void)saveContext;

+ (void)saveNewsInDatabase:(NSDictionary *)newsData;

@end
