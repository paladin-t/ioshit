#import "share_core.h"

@implementation ShareChannel

+ (BOOL) stringEquals: (NSString*) str1 to: (NSString*) str2 {
    if (str1 == nil || str2 == nil)
        return NO;

    return [str1 compare: str2 options: NSCaseInsensitiveSearch] == NSOrderedSame;
}

+ (BOOL) startWith: (NSString*) prefix forString: (NSString*) text {
    if (text != nil && prefix != nil) {
        if ([prefix length] > [text length])
            return NO;

        NSString* prestr = [text substringToIndex: [prefix length]];
        if ([self stringEquals: prestr to: prefix])
            return YES;

    }

    return NO;
}

+ (BOOL) isUrlString: (NSString*) text {
    if ([text length] > 6) {
        NSString* prefix = [text substringToIndex: 6];
        if ([self stringEquals: prefix to: @"http:/"] || [self stringEquals: prefix to: @"https:"])
            return YES;
        else if ([self stringEquals: prefix to: @"local:"])
            return YES;
    }
    if ([self startWith: @"/" forString: text])
        return YES;

    return NO;
}

- (void) mailComposeController: (MFMailComposeViewController*) controller didFinishWithResult: (MFMailComposeResult) result error: (NSError*) error {
    [controller dismissViewControllerAnimated: YES completion: nil];
}

- (void) email: (NSString*) title text: (NSString*) text url: (NSString*) url img: (NSString*) img {
    if ([MFMailComposeViewController canSendMail] == YES) {
        MFMailComposeViewController* emailShareController = [[MFMailComposeViewController alloc] init];
        emailShareController.mailComposeDelegate = self;
        NSString* content = [NSString stringWithFormat: @"%@  %@", text, url];
        [emailShareController setSubject: title];
        [emailShareController setMessageBody: content isHTML: YES];

        UIImage* image = nil;
        if ([ShareChannel isUrlString: img])
            image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: img]]];
        else
            image = [UIImage imageNamed: img];
        if (image != nil)
            [emailShareController addAttachmentData: UIImageJPEGRepresentation(image, 1) mimeType: @"image/png" fileName: @"preview.png"];

        if (emailShareController) {
            UIWindow* window = [[UIApplication sharedApplication] keyWindow];
            [[window rootViewController] presentViewController: emailShareController animated: YES completion: nil];

            [emailShareController release];
        }
    } else {
        NSString* msg = @"You can't send it right now, make sure your device has an internet connection and you have an Email account setup.";
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"Oops"
                                                            message: msg
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil
                                  ];
        [alertView show];
        [alertView release];
    }
}

- (void) share: (NSString*) name c: (NSString*) c title: (NSString*) title text: (NSString*) text url: (NSString*) url img: (NSString*) img {
    if([SLComposeViewController isAvailableForServiceType: c]) {
        SLComposeViewController* tweetSheet = [SLComposeViewController composeViewControllerForServiceType: c];
        [tweetSheet setInitialText: text];
        [tweetSheet addURL: [NSURL URLWithString: url]];

        UIImage* image = nil;
        if ([ShareChannel isUrlString: img])
            image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: img]]];
        else
            image = [UIImage imageNamed: img];
        if (image != nil)
            [tweetSheet addImage: image];
        else
            [tweetSheet removeAllImages];

        SLComposeViewControllerCompletionHandler blk = ^ (SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Sharing canceled.");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Sharing done.");
                    break;
            }
            [tweetSheet dismissViewControllerAnimated: YES completion: Nil];
        };
        tweetSheet.completionHandler = blk;
        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        [[window rootViewController] presentViewController: tweetSheet animated: YES completion: nil];
    } else {
        NSString* msg = [NSString stringWithFormat: @"You can't send it right now, make sure your device has an internet connection and you have a %@ account setup.",
                         name
                         ];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"Oops"
                                                            message: msg
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil
                                  ];
        [alertView show];
        [alertView release];
    }
}

@end
