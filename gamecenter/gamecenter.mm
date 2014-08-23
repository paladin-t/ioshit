#include "gamecenter.h"
#include "gamecenter_core.h"

struct _GameCenter {
    _GameCenter() {
        self = this;

        gamecenter = [GameCenter sharedGameCenter: _GameCenter::authenticated
                                               na: _GameCenter::notAuthenticated
                      ];
    }
    ~_GameCenter() {
        self = NULL;
    }

    static void authenticated(void) {
        if(IGC::authenticated)
            IGC::authenticated();
    }

    static void notAuthenticated(void) {
        if(IGC::notAuthenticated)
            IGC::notAuthenticated();
    }

    static _GameCenter* self;
    GameCenter* gamecenter;
};

_GameCenter* _GameCenter::self = NULL;

static _GameCenter* gamecenter = NULL;

GameCenterAuthenticatedHandler IGC::authenticated;
GameCenterNotAuthenticatedHandler IGC::notAuthenticated;

void IGC::open(void) {
    assert(!gamecenter);
    gamecenter = new _GameCenter;

    [gamecenter->gamecenter registerForAuthenticationNotification];

    [gamecenter->gamecenter authenticateLocalUser];
}

void IGC::close(void) {
    assert(gamecenter);
    delete gamecenter;
    gamecenter = NULL;
}

void IGC::showGameCenter(void) {
    [gamecenter->gamecenter authenticateLocalUser];

    [gamecenter->gamecenter showGameCenter];
}

bool IGC::commitScore(const std::string &id, int p) {
    [gamecenter->gamecenter authenticateLocalUser];

	return [gamecenter->gamecenter reportScore: p
                                   forCategory: [NSString stringWithUTF8String: id.c_str()]
	       ];
}

bool IGC::commitAchievement(const std::string &id, int p) {
    [gamecenter->gamecenter authenticateLocalUser];

    return [gamecenter->gamecenter reportAchievement: [NSString stringWithUTF8String: id.c_str()]
                                             percent: (float)p
	       ];
}

bool IGC::getAchievement(const std::string &id, int* p) {
    float per = 0.0f;

    bool result = [gamecenter->gamecenter getAchievement: [NSString stringWithUTF8String: id.c_str()]
                                                 percent: &per
                   ];
    if(p)
        *p = (int)(per);

    return result;
}

void IGC::resetAchievement(void) {
    [gamecenter->gamecenter authenticateLocalUser];
    
    [gamecenter->gamecenter resetAchievement];
}
