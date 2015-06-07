//
//  AppDelegate.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/1/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "WebServiceManager.h"
#import "DataRepository.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //[self generateRandomNewsToTheServer];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[DatabaseManager sharedInstance] saveContext];
}

- (void)generateRandomNewsToTheServer {
    for (int index = 0; index < 10; index++) {
        NSURL *url = [NSURL URLWithString:[BASE_URL stringByAppendingString:@"/news"]];
        NSString *userData = [NSString stringWithFormat:@"title=%@&subtitle=\"TEST\"&author=\"BOT\"&content=TEST&createdAt=\"2014-05-22 13:4%d\"&updatedAt=\"22-05-2014 13:40\"&image=\"asd\"&category=\"TEST\"", [NSString stringWithFormat:@"TEST NEWS %d", index], index];
        
        [[WebServiceManager sharedInstance] performRequestWithUrl:url andMethod:@"POST" andHttpBody:userData andHandler:^(NSDictionary *dict, NSURLResponse *response, NSError *error) {
            
        }];
    }
}

@end
