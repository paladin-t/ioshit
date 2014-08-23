#include "util/RichMisc.h"
#if TARGET_TYPE == TARGET_NORMAL
#import <iAd/iAd.h>

@interface iAdHelper : NSObject

+ (id) sharedHelper;

- (void) show;
- (void) hide;

@property (atomic, retain) ADBannerView* bannerView;

@end

#endif
