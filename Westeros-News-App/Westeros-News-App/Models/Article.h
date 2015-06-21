//
//  Article.h
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/12/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Article : NSManagedObject

@property (nonatomic, retain) NSString * authorID;
@property (nonatomic, retain) NSString * categoryID;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * mainImageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * previewImageURL;

@end
