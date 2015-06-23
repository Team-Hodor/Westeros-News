//
//  ArticleCommentViewController.m
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/21/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "ArticleCommentViewController.h"
#import "WebServiceManager.h"
#import "DataRepository.h"
#import "CommentTableViewCell.h"
#import "Comment.h"
#import "UIAlertController+ShowAlert.h"
#import "CustomTableView.h"

@interface ArticleCommentViewController ()<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UITextField *commentTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstrain;

@property (nonatomic, strong) NSMutableArray *comments;

@property (nonatomic, strong) CommentTableViewCell *prototypeCell;

@property (nonatomic, readwrite) UIView *inputAccessoryView;

@property (nonatomic, strong) IBOutlet CustomTableView *tableView;

@end

@implementation ArticleCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performInitialConfiguration];
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
}

- (void)performInitialConfiguration {
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeViewController)];
    
    self.navigationItem.leftBarButtonItem = closeButton;
    
    self.comments = [[NSMutableArray alloc]init];
    
    [self loadComments];

    [self.tableView becomeFirstResponder];
    
    // Pass the current controller as the keyboardBarDelegate
    ((CustomTableView *)self.tableView).keyboardBarDelegate = self;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTouchView)];
    [self.view addGestureRecognizer:recognizer];

    
    //rotate table view so that comments can start from bottom
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    
    self.tableView.allowsSelection = NO;
}

-(void)closeViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self basicCellAtIndexPath:indexPath];
}

- (CommentTableViewCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    
    cell.transform = CGAffineTransformMakeRotation(-M_PI);
    
    [self configureBasicCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureBasicCell:(CommentTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    [self setTitleForCell:cell comment:comment];
    [self setContentForCell:cell comment:comment];
}

- (void)setTitleForCell:(CommentTableViewCell *)cell comment:(Comment *)comment {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    cell.dateLabel.text = [NSString stringWithFormat:@"Commented on %@ ",[formatter stringFromDate:comment.createdAt]];
    
    if(comment.authorName == nil){
        cell.authorLabel.text =[NSString stringWithFormat:@"by %@", @""];
        
        [WebServiceManager getUserWithUserId:comment.authorId completion:^(NSDictionary *dataDictionary, NSHTTPURLResponse *response) {
            if ( [dataDictionary objectForKey:@"error"] ) {
                
                cell.authorLabel.text =[NSString stringWithFormat:@"by %@", @"Unknown"];
            }
            else{
                comment.authorName = [dataDictionary objectForKey:@"name"];
                cell.authorLabel.text =[NSString stringWithFormat:@"by %@", comment.authorName];
            }
            
        }];
    }else{
        cell.authorLabel.text =[NSString stringWithFormat:@"by %@", comment.authorName];
    }
    
    
    
}

- (void)setContentForCell:(CommentTableViewCell *)cell comment:(Comment *)comment {
    cell.contentTextView.text = comment.content;
    cell.contentTextView.scrollEnabled = NO;
    cell.contentTextView.layer.cornerRadius = 10.0;
    cell.contentTextView.clipsToBounds = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static CommentTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    });
    
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}


#pragma mark - Keyboard

// the view the first responder
- (void)didTouchView {
    [self.tableView becomeFirstResponder];
}

// Handle keyboard bar event by creating an alert that contains
// the text from the keyboard bar. In reality, this would do something more useful
- (void)keyboardBar:(KeyboardBar *)keyboardBar sendText:(NSString *)text {
    [self sendComment:text];
    [keyboardBar.textView setText:@""];
    
    [keyboardBar.textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Validation

-(BOOL) areFieldsValidated:(NSString *)text {
    
    NSString *errorMessage;
    
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if ([text length] == 0) {
        errorMessage = @"The comment text field cannot be empty.";
    }
    
    if (!errorMessage) {
        return YES;
    } else {
        [UIAlertController showAlertWithTitle:@"Error"
                                   andMessage:errorMessage
                             inViewController:self
                                  withHandler:nil];
        return NO;
    }
}

- (void)sendComment:(NSString *)commentText{
    
    User *user = [DataRepository sharedInstance].loggedUser;
    
    if([self areFieldsValidated:commentText]){
        
        [WebServiceManager addComment:commentText forArticleWithId:[DataRepository sharedInstance].selectedArticle.identifier sessionToken:user.sessionToken completion:^(NSDictionary *dataDictionary, NSHTTPURLResponse *response) {
            if ( [dataDictionary objectForKey:@"error"] ) {
                
                [UIAlertController showAlertWithTitle:@"Error"
                                           andMessage:@"Couldn't add comment. Please try again."
                                     inViewController:self
                                          withHandler:nil];
                
            }else{
                
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
                
                NSDate *createdAt = [dateFormat dateFromString:[dataDictionary objectForKey:@"createdAt"]];
                
                Comment *comment = [[Comment alloc] init];
                comment.authorId = user.uniqueId;
                comment.content = commentText;
                comment.createdAt = createdAt;
                comment.uniqueId = [dataDictionary objectForKey:@"objectId"];
                
                [self.comments insertObject:comment atIndex:0];
               // [self.tableView reloadData];
                //[self loadComments];
                [self sortAndReloadData];
            }
            
        }];
    }
    
}

-(void)loadComments{
    
    [self.comments removeAllObjects];
    [WebServiceManager getCommentsForArticleWithId:[DataRepository sharedInstance].selectedArticle.identifier sessionToken:[DataRepository sharedInstance].loggedUser.sessionToken completion:^(NSDictionary *dataDictionary, NSHTTPURLResponse *response) {
        
        if(dataDictionary !=nil){
            
            if ( [dataDictionary objectForKey:@"error"] ) {
                
                [UIAlertController showAlertWithTitle:@"Error"
                                           andMessage:@"Couldn't load comments."
                                     inViewController:self
                                          withHandler:nil];
            }else{
                
                for (NSDictionary *result in [dataDictionary objectForKey:@"results"]) {
                    
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
                    
                    NSDate *createdAt = [dateFormat dateFromString:[result objectForKey:@"createdAt"]];
                    
                    Comment *comment = [[Comment alloc] initWithContent:[result objectForKey:@"content"] authorId:[[result objectForKey:@"authorID"] objectForKey:@"objectId"] createdAt:createdAt andUniqueId:[result objectForKey:@"objectId"]];
                    
                    [self.comments addObject:comment];
                }
                
                [self sortAndReloadData];
            }
            
            
        }
        else{
            [UIAlertController showAlertWithTitle:@"No Comments"
                                       andMessage:@"Be first to comment."
                                 inViewController:self
                                      withHandler:nil];
        }
        
    }];
    
}

-(void)sortAndReloadData{
    //[self.comments sortUsingDescriptors:
    // [NSArray arrayWithObjects:
     // [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES], nil]];
    
    NSArray *sortedArray = [self.comments sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *firstDate = [(Comment *)a createdAt];
        NSDate *secondDate = [(Comment *)b createdAt];
        return [secondDate compare:firstDate];
    }];
    
    self.comments = [NSMutableArray arrayWithArray:sortedArray];
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}



@end
