//
//  NewArticleViewController.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/15/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "NewArticleViewController.h"
#import "DataRepository.h"

@interface NewArticleViewController () <UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (nonatomic) NSInteger chooseImageSenderTag;


@end

@implementation NewArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

#pragma mark - Event Handlers

- (void)cancelButtonActionTriggered {
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
    NSString *title = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *subtitle = [self.subtitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    UIImage *previewImage = self.previewImageView.image;
    UIImage *mainImage = self.mainImageView.image;
    
    NSString *content = self.contentTextView.text;
    
    if ([DataRepository sharedInstance].selectedArticle) {
        [self editSelectedArticleWithTitle:title
                                  subtitle:subtitle
                              previewImage:previewImage
                                 mainImage:mainImage
                                   content:content];
    } else {
        [self postNewArticleWithTitle:title
                             subtitle:subtitle
                         previewImage:previewImage
                            mainImage:mainImage
                              content:content];
    }
}

@end
