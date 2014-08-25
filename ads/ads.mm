#include "ads.h"
#include "iAdHelper.h"
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <StartApp/StartApp.h>

static STAStartAppAd* startAppAd = NULL;

void Ads::setDevId(const std::string &id) {
    STAStartAppSDK* sdk = [STAStartAppSDK sharedInstance];
    sdk.devID = [NSString stringWithUTF8String: id.c_str()];
}

void Ads::setAppId(const std::string &id) {
    STAStartAppSDK* sdk = [STAStartAppSDK sharedInstance];
    sdk.appID = [NSString stringWithUTF8String: id.c_str()];
}

void Ads::open(void) {
    startAppAd = [[STAStartAppAd alloc] init];
}

void Ads::close(void) {
    [startAppAd release];
}

void Ads::loadPanel(void) {
    [startAppAd loadAd: STAAdType_AppWall];
}

void Ads::showPanel(void) {
    if(rand() % 100 < 70) {
        printf("StartApp AD ready status: %s\n", [startAppAd isReady] ? "YES" : "NO");
    
        [startAppAd showAd];
    }
}

void Ads::showBanner(void) {
    if(rand() % 100 < 70)
        [[iAdHelper sharedHelper] show];
}

void Ads::hideBanner(void) {
    [[iAdHelper sharedHelper] hide];
}
