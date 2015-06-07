//
//  NewsTableViewController.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/7/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "NewsTableViewController.h"
#import "WebServiceManager.h"
#import "DataRepository.h"
#import "DatabaseManager.h"
#import "Article.h"
#import "NSString+DateValue.h"

typedef enum {
    FeaturedNewsSection,
    AllNewsSection,
    FavouriteNewsSection
} NewsSection;

@interface NewsTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NewsSection selectedSection;
@property (nonatomic) NSInteger currentWebRequestSkipCount;
@property (nonatomic) NSInteger currentNumberOfInsertions;

#define CELL_ID @"ArticleCell"
#define WEB_REQUEST_LIMIT 5

@end

@implementation NewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentWebRequestSkipCount = 0;
    self.selectedSection = FeaturedNewsSection;
    
    [self loadNewsWithLimit:WEB_REQUEST_LIMIT skip:self.currentWebRequestSkipCount];
    
    self.currentWebRequestSkipCount += 5;
    
    NSError *error;
    [[self fetchedResultsController] performFetch:&error];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetch Results Controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [DatabaseManager sharedInstance].mainContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article"
                                              inManagedObjectContext:context];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];

    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:5];
    [fetchRequest setFetchOffset:0];
    
    
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:context
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger numRows = [self.fetchedResultsController.fetchedObjects count];
    
    if (self.selectedSection == AllNewsSection) {
        return numRows + 1;
    }
    
    return [[self.fetchedResultsController fetchedObjects] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    
    
    if ([sectionInfo numberOfObjects] > indexPath.row) {
        Article *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = article.title;
    } else {
        cell.textLabel.text = @"Show more";
    }
    
    return cell;
}

#pragma mark - Controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
//            if (newIndexPath.row >= self.fetchedResultsController.fetchRequest.fetchLimit) {
//                break;
//            }
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            
//            if (self.currentNumberOfInsertions > self.fetchedResultsController.fetchRequest.fetchLimit) {
//                //Determining which row to delete depends on your sort descriptors
//                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.fetchedResultsController.fetchRequest.fetchLimit - 1 inSection:[newIndexPath section]]] withRowAnimation:UITableViewRowAnimationFade];
//                self.currentNumberOfInsertions--;
//            }
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    
    if (self.selectedSection == FeaturedNewsSection) {
        NSFetchRequest *request = [self.fetchedResultsController fetchRequest];
        [request setFetchLimit:5];
        [self.fetchedResultsController performFetch:nil];
        [self.tableView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    
    
    if ( !( [sectionInfo numberOfObjects] > indexPath.row ) ) {
        [self loadNewsWithLimit:WEB_REQUEST_LIMIT skip:self.currentWebRequestSkipCount];
        self.currentWebRequestSkipCount += 5;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Web service managers

- (void)loadNewsWithLimit:(NSInteger)limit skip:(NSInteger)skip {
    // ?{"$limit":1,"$skip":1}
    
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:
                            [NSString stringWithFormat:@"/news?{\"$limit\":%ld,\"$skip\":%ld,\"$sort\":{\"createdAt\":1}}", limit, skip]];
    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [[WebServiceManager sharedInstance] performRequestWithUrl:url andMethod:@"GET" andHttpBody:@"" andHandler:^(NSDictionary *resultData, NSURLResponse *response, NSError *error) {
        NSManagedObjectContext *workerContext = [[DatabaseManager sharedInstance] workerContext];
        
        [workerContext performBlock:^() {
            for (id news in resultData) {
                NSString *author = [news valueForKey:@"author"];
                NSString *category = [news valueForKey:@"category"];
                NSString *content = [news valueForKey:@"content"];
                NSString *identifier = [news valueForKey:@"id"];
                NSData *imageData = [[news valueForKey:@"image"] dataUsingEncoding:NSUTF8StringEncoding];
                NSString *title = [news valueForKey:@"title"];
                NSString *subtitle = [news valueForKey:@"subtitle"];
                NSDate *createdAt = ((NSString *)[news valueForKey:@"createdAt"]).dateValue;
                NSDate *updatedAt = ((NSString *)[news valueForKey:@"updatedAt"]).dateValue;
                
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Article"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
                [request setPredicate:predicate];
                
                NSArray *result = [workerContext executeFetchRequest:request error:nil];
                if (![result count]) {
                    Article *article = [NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:workerContext];
                    
                    article.author = author;
                    article.category = category;
                    article.content = content;
                    article.identifier = identifier;
                    article.image = imageData;
                    article.title = title;
                    article.subtitle = subtitle;
                    article.createdAt = createdAt;
                    article.updatedAt = updatedAt;
                } else {
                    NSLog(@"Duplicate!");
                }
            }
            
            NSError *error;
            [workerContext save:&error];
        }];
    }];
}

#pragma mark - Event Handlers

- (IBAction)featuredBarButtonItemActionTriggered:(id)sender {
    if (self.selectedSection != FeaturedNewsSection) {
        self.selectedSection = FeaturedNewsSection;
        
        NSFetchRequest *request = [self.fetchedResultsController fetchRequest];
        [request setFetchLimit:5];
        
        
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        [self.tableView reloadData];
    }
}

- (IBAction)allNewsBarButtonItemActionTriggered:(id)sender {
    if (self.selectedSection != AllNewsSection) {
        self.selectedSection = AllNewsSection;
        
        NSFetchRequest *request = [self.fetchedResultsController fetchRequest];
        [request setFetchLimit:2000];
        
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        [self.tableView reloadData];
    }
}

- (IBAction)favouritesBarButtonItemActionTriggered:(id)sender {
    if (self.selectedSection != FavouriteNewsSection) {
        self.selectedSection = FavouriteNewsSection;
        
    }
}


@end
