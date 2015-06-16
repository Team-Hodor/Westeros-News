//
//  NewArticleViewController.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/15/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "NewArticleViewController.h"
#import "DataRepository.h"
#import "WebServiceManager.h"
#import "UIAlertController+ShowAlert.h"

@interface NewArticleViewController () <UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (strong, nonatomic) UIView *activeField;
@property (nonatomic) NSInteger chooseImageSenderTag;
@property (strong, nonatomic) NSMutableArray *categoryTitles;
@property (strong, nonatomic) NSMutableDictionary *categoriesByID;

@end

@implementation NewArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerForKeyboardNotifications];
    [self performInitialConfiguration];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonActionTriggered)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    if ([DataRepository sharedInstance].selectedArticle) {
        // TODO: Set initial values for selected article
        self.title = @"Edit Article";
    } else {
        self.title = @"New Article";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Article Submissions

- (void)postNewArticleWithTitle:(NSString *)title
                       subtitle:(NSString *)subtitle
                   previewImage:(UIImage *)previewImage
                      mainImage:(UIImage *)mainImage
                        content:(NSString *)content  {
    
}

- (void)editSelectedArticleWithTitle:(NSString *)title
                            subtitle:(NSString *)subtitle
                        previewImage:(UIImage *)previewImage
                           mainImage:(UIImage *)mainImage
                             content:(NSString *)content {
    
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    if (self.chooseImageSenderTag == 1) {
        self.previewImageView.image = chosenImage;
    } else {
        self.mainImageView.image = chosenImage;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.categoryTitles count];
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    
    return self.categoryTitles[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.categoryTextField.text = self.categoryTitles[row];
}

#pragma mark - Event Handlers

- (void)cancelButtonActionTriggered {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)chooseImageButtonTouchUpInside:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    self.chooseImageSenderTag = [sender tag];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)submitButtonTouchUpInside:(id)sender {
    if (![self areFieldsValidated]) {
        return;
    } else {
        ((UIButton *)sender).enabled = NO;
    }
    
    NSString *title = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *subtitle = [self.subtitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    UIImage *previewImage = self.previewImageView.image;
    UIImage *mainImage = self.mainImageView.image;
    
    NSString *content = self.contentTextView.text;
    NSString *categoryID = self.categoriesByID[self.categoryTextField.text];
    
    if ([DataRepository sharedInstance].selectedArticle) {
        [self editSelectedArticleWithTitle:title
                                  subtitle:subtitle
                              previewImage:previewImage
                                 mainImage:mainImage
                                   content:content];
    } else {
        [WebServiceManager postNewArticleWithTitle:title
                                          subtitle:subtitle
                                        categoryID:categoryID
                                          authorID:[DataRepository sharedInstance].loggedUser.uniqueId
                                      previewImage:previewImage
                                          mainImage:mainImage
                                            content:content
                                       sessionToken:[DataRepository sharedInstance].loggedUser.sessionToken
                                         completion:^(NSDictionary *resultData, NSURLResponse *response, NSError *error) {
                                             if (!error) {
                                                 [UIAlertController showAlertWithTitle:@"Success"
                                                                            andMessage:@"The article has been posted successfully."
                                                                      inViewController:self
                                                                           withHandler:^() {
                                                                               [self dismissViewControllerAnimated:YES completion:nil];
                                                                           }];
                                             } else {
                                                 [UIAlertController showAlertWithTitle:@"Error"
                                                                            andMessage:@"An error occured while trying to post the article. Please try again later."
                                                                      inViewController:self
                                                                           withHandler:nil];
                                                 ((UIButton *)sender).enabled = YES;
                                             }
        }];
    }
}

#pragma mark - Private methods

-(BOOL) areFieldsValidated {
    NSString *errorMessage;
    
    NSString *title = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *subtitle = [self.subtitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *category = [self.categoryTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *content = [self.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([title length] == 0) {
        errorMessage = @"The title cannot be left empty.";
    } else if ([subtitle length] == 0) {
        errorMessage = @"The subtitle cannot be left empty.";
    } else if ([category length] == 0) {
        errorMessage = @"The category cannot be left empty";
    } else if ([content length] == 0) {
        errorMessage = @"The content cannot be left empty";
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

- (void)performInitialConfiguration {
    [WebServiceManager loadAvailableCategoriesWithCompletion:^(NSDictionary *resultData, NSURLResponse *response, NSError *error) {
        if (!error) {
            self.categoryTitles = [[NSMutableArray alloc] init];
            self.categoriesByID = [[NSMutableDictionary alloc] init];
            
            for (id category in [resultData valueForKey:@"results"]) {
                [self.categoryTitles addObject:[category valueForKey:@"name"]];
                [self.categoriesByID setObject:[category valueForKey:@"objectId"]
                                        forKey:[category valueForKey:@"name"]];
            }
            
            [self initialiseTypePicker];
        } else {
            [UIAlertController showAlertWithTitle:@"Error"
                                       andMessage:@"An error occured while trying to get the available categories."
                                 inViewController:self
                                      withHandler:nil];
        }
    }];
}

- (void)initialiseTypePicker {
    UIPickerView *typePicker = [[UIPickerView alloc] init];
    typePicker.dataSource = self;
    typePicker.delegate = self;
    self.categoryTextField.inputView = typePicker;
}

#pragma mark - Managing the keyboard

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

# pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
