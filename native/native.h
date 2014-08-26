#ifndef __RICH_NATIVE_H__
#define __RICH_NATIVE_H__

typedef void (* AnsweredFunc)(void);

struct Native {
    static void open(void);
    static void close(void);

    static const char* getLanguage(void);

    static bool networkConnected(void);

    static void openUrl(const char* url);

    static void msgBox(const char* title, const char* message);

    static void askBox(const char* title, const char* message, const char* btnYes, const char* btnNo, AnsweredFunc onAnsweredYes, AnsweredFunc onAnsweredNo);
};

#endif // __RICH_NATIVE_H__
