#import "FileOpener.h"

@implementation FileOpener
{
    UIDocumentInteractionController *controller;
}

- (void)openFile:(CDVInvokedUrlCommand*)command
{
    NSString* filePath = [[command arguments] objectAtIndex:0];
    
    if (![filePath containsString:@"user-assets/"])
    {
        filePath = [NSString stringWithFormat:@"%@%@", @"file:///", filePath];
    }
    else if ([filePath containsString:@"user-assets/"])
    {
        NSString *appFolderPath = [[NSBundle mainBundle] resourcePath];
        filePath = [NSString stringWithFormat :@"file://%@/www/%@", appFolderPath, filePath];
    }
    
    filePath = [filePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

    NSURL *filePathUrl = [NSURL URLWithString:filePath];
    UIDocumentInteractionController *documentInteractionViewController = [self setupControllerWithURL:filePathUrl usingDelegate:self];
    [documentInteractionViewController presentPreviewAnimated:YES];
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    
    return interactionController;
}

-(UIViewController*) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return super.viewController;
}

@end