#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareChannel : NSObject<MFMailComposeViewControllerDelegate>

- (void) mailComposeController: (MFMailComposeViewController*) controller
           didFinishWithResult: (MFMailComposeResult) result
                         error: (NSError*) error;
- (void) email: (NSString*) title
          text: (NSString*) text
           url: (NSString*) url
           img: (NSString*) img;
- (void) share: (NSString*) name
             c: (NSString*) c
         title: (NSString*) title
          text: (NSString*) text
           url: (NSString*) url
           img: (NSString*) img;

@end
