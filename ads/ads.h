#ifndef __RICH_ADS_H__
#define __RICH_ADS_H__

#include <string>

typedef void (* AnsweredFunc)(void);

struct Ads {
    static void setDevId(const std::string &id);
    static void setAppId(const std::string &id);

    static void open(void);
    static void close(void);

    static void loadPanel(void);
    static void showPanel(void);

    static void showBanner(void);
    static void hideBanner(void);
};

#endif // __RICH_ADS_H__
