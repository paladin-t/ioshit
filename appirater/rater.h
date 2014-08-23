#ifndef __RATER_H__
#define __RATER_H__

#include <string>

struct Rater {
    static void setDevId(const std::string &id);
    static void setAppId(const std::string &id);

    static void run(void);
    static void touch(void);

    static void rateMe(void);
    static void showMoreByMe(void);
};

#endif // __RATER_H__
