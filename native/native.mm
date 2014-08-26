#include "native.h"
#include "reachability.h"
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@interface AlertViewController : NSObject<UIAlertViewDelegate> {
    AnsweredFunc answeredYes;
    AnsweredFunc answeredNo;
}

- (id) init: (AnsweredFunc) y
          n: (AnsweredFunc) n;

- (void) alertView: (UIAlertView*) alertView clickedButtonAtIndex: (NSInteger) buttonIndex;

@end

static AlertViewController* answer = NULL;

@implementation AlertViewController

- (id) init: (AnsweredFunc) y
          n: (AnsweredFunc) n {
    if((self = [super init])) {
        answeredYes = y;
        answeredNo = n;
    }

    return self;
}

- (void) alertView: (UIAlertView*) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        NSLog(@"The cancel button was clicked from alertView.");

        if (answeredNo)
            answeredNo();
    } else {
        NSLog(@"The ok button was clicked from alertView.");

        if (answeredYes)
            answeredYes();
    }

    [answer release];
    answer = NULL;
}

@end

void Native::open(void) {
}

void Native::close(void) {
}

const char* Native::getLanguage(void) {
    // System language.
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defaults objectForKey: @"AppleLanguages"];
    NSString* currentLanguage = [languages objectAtIndex: 0];

    [[NSUserDefaults standardUserDefaults] setObject: currentLanguage forKey: @"language"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    const char* result = [currentLanguage UTF8String];
    if (!strcmp(result, "zh-Hant"))
        result = "zh-Hans";

    return result;
}

bool Native::networkConnected(void) {
    Reachability* reachability = [Reachability reachabilityWithHostName: @"www.apple.com"]; //[Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    return internetStatus != NotReachable;
}

void Native::openUrl(const char* url) {
    if (!url)
        return;

    NSString* theUrl = [NSString stringWithUTF8String: url];

    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: theUrl]];
}

void Native::msgBox(const char* title, const char* message) {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: [NSString stringWithUTF8String: title]
                                                    message: [NSString stringWithUTF8String: message]
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil
                          ];
    [alert show];
    [alert release];
}

void Native::askBox(const char* title, const char* message, const char* btnYes, const char* btnNo, AnsweredFunc onAnsweredYes, AnsweredFunc onAnsweredNo) {
    // Alert view handler.
    answer = [[AlertViewController alloc] init: onAnsweredYes
                                             n: onAnsweredNo
              ];

    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: [NSString stringWithUTF8String: title]
                                                    message: [NSString stringWithUTF8String: message]
                                                   delegate: answer
                                          cancelButtonTitle: [NSString stringWithUTF8String: btnNo]
                                          otherButtonTitles: [NSString stringWithUTF8String: btnYes], nil
                          ];
    [alert show];
    [alert release];
}
