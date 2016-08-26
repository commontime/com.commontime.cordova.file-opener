#import <Cordova/CDV.h>

@interface FileOpener : CDVPlugin <UIDocumentInteractionControllerDelegate>

- (void) openFile:(CDVInvokedUrlCommand*)command;

@end