#include "rater.h"
#include "Appirater.h"

static bool _run = false;

static std::string _devId;
static std::string _appId;

void Rater::setDevId(const std::string &id) {
    _devId = id;
}

void Rater::setAppId(const std::string &id) {
    _appId = id;
}

void Rater::run(void) {
    if(_run)
        return;

    _run = true;

    [Appirater setAppId: [NSString stringWithUTF8String: _appId.c_str()]];

    [Appirater setDaysUntilPrompt: 5];
    [Appirater setUsesUntilPrompt: 3];
    [Appirater setSignificantEventsUntilPrompt: -1];
    [Appirater setTimeBeforeReminding: 2];
    [Appirater setDebug: NO];
    [Appirater appLaunched: YES];
}

void Rater::touch(void) {
    if(_run)
        return;

    _run = true;
    
    [Appirater appEnteredForeground: YES];
}

void Rater::rateMe(void) {
    NSString* appId = [NSString stringWithUTF8String: _appId.c_str()];

    NSString* theUrl = [NSString stringWithFormat:
                        @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software",
                        appId
                        ];
    if ([[UIDevice currentDevice].systemVersion integerValue] == 7) {
        //theUrl = [NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@", appId];
    }

    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: theUrl]];

    printf("rated...\n");
}

void Rater::showMoreByMe(void) {
    std::string url = "http://itunes.apple.com/developer/id" + _devId;
    NSString* theUrl = [NSString stringWithUTF8String: url.c_str()];

    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: theUrl]];

    printf("opened...\n");
}
