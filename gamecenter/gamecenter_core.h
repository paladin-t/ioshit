#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

typedef void (* GameCenterAuthenticatedFunc)(void);
typedef void (* GameCenterNotAuthenticatedFunc)(void);

@interface GameCenter : NSObject<GKGameCenterControllerDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GKMatchmakerViewControllerDelegate, GKMatchDelegate> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;

    GameCenterAuthenticatedFunc authenticated;
    GameCenterNotAuthenticatedFunc notAuthenticated;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (nonatomic, copy) NSString* leaderboardName;
@property (nonatomic, retain) NSMutableDictionary* achievementDictionary;

+ (GameCenter*) sharedGameCenter: (GameCenterAuthenticatedFunc) a na: (GameCenterNotAuthenticatedFunc) na;
- (void) authenticateLocalUser;
- (void) registerForAuthenticationNotification;

- (void) showGameCenter;
- (void) gameCenterViewControllerDidFinish: (GKGameCenterViewController*) viewController;

- (void) showLeaderboard;
- (void) leaderboardViewControllerDidFinish: (GKLeaderboardViewController*) viewController;
- (BOOL) reportScore: (int64_t) score forCategory: (NSString*) category;
- (void) retrieveTopXScores: (int) number;

- (void) showAchievementboard;
- (void) achievementViewControllerDidFinish: (GKAchievementViewController*) achievementController;
- (void) loadAchievement;
- (void) resetAchievement;
- (BOOL) reportAchievement: (NSString*) id percent: (float) percent;
- (BOOL) unlockAchievement: (GKAchievement*) achievement percent: (float) percent;
- (BOOL) getAchievement: (NSString*) id percent: (float*) percent;
- (GKAchievement*) getAchievementForID: (NSString*) id;

@end
