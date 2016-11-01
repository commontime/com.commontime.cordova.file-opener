#import "FileOpener.h"

@implementation FileOpener
{
    UIDocumentInteractionController *controller;
}

- (void)openFile:(CDVInvokedUrlCommand*)command
{
    NSString* filePath = [[command arguments] objectAtIndex:0];
    
    if([filePath containsString:@"http://"])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL  *url = [NSURL URLWithString:[filePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if ( urlData )
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *destFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[filePath lastPathComponent]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [urlData writeToFile:destFilePath atomically:YES];
                    NSString *destFilePathAdjusted = [NSString stringWithFormat:@"%@%@", @"file://", destFilePath];
                    NSURL *destFilePathUrl = [NSURL URLWithString:[destFilePathAdjusted stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
                    [self displayDocument:destFilePathUrl];
                });
            }
        });
    }
    else if (![filePath containsString:@"user-assets/"])
    {
        filePath = [NSString stringWithFormat:@"%@%@", @"file:///", filePath];
        filePath = [filePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSURL *filePathUrl = [NSURL URLWithString:filePath];
        [self displayDocument:filePathUrl];

    }
    else if ([filePath containsString:@"user-assets/"])
    {
        NSString *appFolderPath = [[NSBundle mainBundle] resourcePath];
        filePath = [NSString stringWithFormat :@"file://%@/www/%@", appFolderPath, filePath];
        filePath = [filePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSURL *filePathUrl = [NSURL URLWithString:filePath];
        [self displayDocument:filePathUrl];
    }
}

- (void)displayDocument:(NSURL*)filePathUrl
{
    UIDocumentInteractionController *documentInteractionController = [self setupControllerWithURL:filePathUrl usingDelegate:self];
    [documentInteractionController presentPreviewAnimated:YES];
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