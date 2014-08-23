#include "share.h"
#include "share_core.h"

struct _ShareChannel {
    _ShareChannel() {
        self = this;

        channel = [[ShareChannel alloc] init];
    }
    ~_ShareChannel() {
        self = NULL;

        [channel release];
    }

    static _ShareChannel* self;
    ShareChannel* channel;
    std::string appId;
};

_ShareChannel* _ShareChannel::self = NULL;

static _ShareChannel* _share = NULL;

void Share::open(void) {
    assert(!_share);
    _share = new _ShareChannel;
}

void Share::close(void) {
    assert(_share);
    delete _share;
    _share = NULL;
}

void Share::setAppId(const std::string &id) {
    _share->appId = id;
}

void Share::openSharePanel(const std::string &msg) {
    const std::string aid = "https://itunes.apple.com/app/id" + _share->appId;

    NSString* someText = [NSString stringWithUTF8String: msg.c_str()];
    NSArray* dataToShare = @[ // Or whatever pieces of data you want to share...
        someText,
        [NSString stringWithUTF8String: aid.c_str()]
    ];

    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems: dataToShare
                                                                                         applicationActivities: nil
                                                        ];
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    [[window rootViewController] presentViewController: activityViewController
                                              animated: YES
                                            completion: ^ { }
     ];
}

void Share::share(
    ShareChannels channel,
    const std::string &title, const std::string &text,
    const std::string &url, const std::string &img
) {
    struct Info {
        NSString* name;
        NSString* channel;
        Info(NSString* n, NSString* c) : name(n), channel(c) {
        }
    };
    const Info infos[] = {
        Info(@"Facebook", SLServiceTypeFacebook),
        Info(@"Twitter", SLServiceTypeTwitter),
        Info(@"Weibo", SLServiceTypeSinaWeibo),
        Info(@"Tencent", SLServiceTypeTencentWeibo),
    };
    switch(channel) {
        case SC_EMAIL:
            [_share->channel email: [NSString stringWithUTF8String: title.c_str()]
                              text: [NSString stringWithUTF8String: text.c_str()]
                               url: [NSString stringWithUTF8String: url.c_str()]
                               img: [NSString stringWithUTF8String: img.c_str()]
             ];
            break;
        default:
            [_share->channel share: infos[channel].name
                                 c: infos[channel].channel
                             title: [NSString stringWithUTF8String: title.c_str()]
                              text: [NSString stringWithUTF8String: text.c_str()]
                               url: [NSString stringWithUTF8String: url.c_str()]
                               img: [NSString stringWithUTF8String: img.c_str()]
             ];
            break;
    }
}
