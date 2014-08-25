#import <iAd/iAd.h>

@interface iAdHelper : NSObject

+ (id) sharedHelper;

- (void) show;
- (void) hide;

@property (atomic, retain) ADBannerView* bannerView;

@end
