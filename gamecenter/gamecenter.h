#ifndef __GAMECEHTER_H__
#define __GAMECEHTER_H__

#include <string>

typedef void (* GameCenterAuthenticatedHandler)(void);
typedef void (* GameCenterNotAuthenticatedHandler)(void);

struct IGC {
    static void open(void);
    static void close(void);
    static void showGameCenter(void);
	static bool commitScore(const std::string &id, int p);
    static bool commitAchievement(const std::string &id, int p);
    static bool getAchievement(const std::string &id, int* p);
    static void resetAchievement(void);

    static GameCenterAuthenticatedHandler authenticated;
    static GameCenterNotAuthenticatedHandler notAuthenticated;
};

#endif // __GAMECEHTER_H__
