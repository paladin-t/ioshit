#include "rich.h"
#include "iAdHelper.h"

#if TARGET_TYPE == TARGET_NORMAL

@interface iAdHelper() <ADBannerViewDelegate>

@end

@implementation iAdHelper

@synthesize bannerView = _bannerView;

+ (id) sharedHelper {
    static iAdHelper* sharedHelper = [[iAdHelper alloc] init];

    return sharedHelper;
}

- (id) init {
    self = [super init];

    return self;
}

- (void) layoutAnimated: (BOOL) animated {
    // As of iOS 6.0, the banner will automatically resize itself based on its width.
    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
    rich::Size contentFrame = rich::Director::instance()->getWinSize();//getOpenGLView()->getFrameSize();

    if (contentFrame.x < contentFrame.y)
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    else
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;

    CGRect bannerFrame = _bannerView.frame;
    if (_bannerView.bannerLoaded) {
        contentFrame.y -= _bannerView.frame.size.height;
        bannerFrame.origin.y = 0;//contentFrame.height;
    } else {
        bannerFrame.origin.y = 0;//contentFrame.height;
    }

    [UIView animateWithDuration: animated ? 0.25 : 0.0 animations:
        ^ {
            _bannerView.frame = bannerFrame;
        }
    ];
}

- (void) bannerViewDidLoadAd: (ADBannerView*) banner {
    [self layoutAnimated: YES];

    //Size contentFrame = Director::instance()->getWinSize();
    CGRect r = CGRectMake(
        0,
        0,//contentFrame.height - banner.frame.size.height,
        banner.frame.size.width,
        banner.frame.size.height
    );
    banner.frame = r;
}

- (void) bannerView: (ADBannerView*) banner didFailToReceiveAdWithError: (NSError*) error {
    NSLog(@"ERROR (iAds): %@\n%@", [error localizedDescription], [error localizedFailureReason]);

    [self layoutAnimated: YES];
}

- (void) show {
    // On iOS 6 ADBannerView introduces a new initializer, use it when available.
    if([ADBannerView instancesRespondToSelector: @selector(initWithAdType: )])
        _bannerView = [[ADBannerView alloc] initWithAdType: ADAdTypeBanner];
    else
        _bannerView = [[ADBannerView alloc] init];

    _bannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    
    rich::Size contentFrame = rich::Director::instance()->getWinSize();//getOpenGLView()->getFrameSize();
    if (contentFrame.x < contentFrame.y) {
        _bannerView.requiredContentSizeIdentifiers = [NSSet setWithObject: ADBannerContentSizeIdentifierPortrait];
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    } else {
        _bannerView.requiredContentSizeIdentifiers = [NSSet setWithObject: ADBannerContentSizeIdentifierLandscape];
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }

    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    UIView* topView = window.rootViewController.view;

    [topView addSubview: _bannerView];
    [_bannerView setBackgroundColor: [UIColor clearColor]];
    [topView addSubview: _bannerView];
    _bannerView.delegate = self;

    //[[[Director instance]view]bringSubviewToFront:_bannerView];

    [self layoutAnimated: YES];
}

- (void) hide {
    [_bannerView removeFromSuperview];
    [_bannerView release];
    _bannerView = nil;
}

@end

#endif
