#ifndef __SHARE_H__
#define __SHARE_H__

#include <string>

enum ShareChannels {
	SC_FACEBOOK,
	SC_TWITTER,
	SC_SINA,
	SC_TENCENT,
    SC_EMAIL,
	SC_COUNT
};

struct Share {
    static void open(void);
    static void close(void);

    static void setAppId(const std::string &id);

    static void openSharePanel(const std::string &msg);

	static void share(
		ShareChannels channel,
		const std::string &title, const std::string &text,
        const std::string &url, const std::string &img
	);
};

#endif // __SHARE_H__
