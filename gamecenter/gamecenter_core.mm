#import "gamecenter_core.h"

@implementation GameCenter
@synthesize gameCenterAvailable;

static GameCenter* sharedHelper = nil;
static UIViewController* currentModalViewController = nil;

+ (GameCenter*) sharedGameCenter: (GameCenterAuthenticatedFunc) a na: (GameCenterNotAuthenticatedFunc) na {
    if(!sharedHelper) {
        sharedHelper = [[GameCenter alloc] init];
        sharedHelper->authenticated = a;
        sharedHelper->notAuthenticated = na;
    }

    return sharedHelper;
}

- (BOOL) isGameCenterAvailable {
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));

    // Check if the device is running iOS 4.1 or later.
    NSString* reqSysVer = @"4.1";
    NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare: reqSysVer
                                           options: NSNumericSearch
                                ] != NSOrderedAscending
                               );

    return (gcClass && osVersionSupported);
}

- (id) init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
            [nc addObserver: self
                   selector: @selector(authenticationChanged)
                       name: GKPlayerAuthenticationDidChangeNotificationName
                     object: nil
             ];
        }
    }

    return self;
}

- (void) authenticationChanged {
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;

        if (authenticated)
            authenticated();
    } else if(![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated.");
        userAuthenticated = FALSE;

        if (notAuthenticated)
            notAuthenticated();
    } else {
        NSLog(@"Authentication not changed: player keep not authenticated.");

        if (notAuthenticated)
            notAuthenticated();
    }
}

- (void) authenticateLocalUser {
    if (!gameCenterAvailable) return;

    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler: nil];
    } else {
        //NSLog(@"Already authenticated!");
    }

    [self loadAchievement];
}

- (void) registerForAuthenticationNotification {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self
           selector: @selector(authenticationChanged)
               name: GKPlayerAuthenticationDidChangeNotificationName
             object: nil
     ];
}

- (void) showGameCenter {
    if (!gameCenterAvailable) return;

    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 5) {
        [self showAchievementboard];
    } else {
        GKGameCenterViewController* gamecenterController = [[GKGameCenterViewController alloc] init];
        if (gamecenterController != nil) {
            gamecenterController.gameCenterDelegate = self;

            gamecenterController.viewState = GKGameCenterViewControllerStateAchievements;

            UIWindow* window = [[UIApplication sharedApplication] keyWindow];
            currentModalViewController = [[UIViewController alloc] init];
            [window addSubview: currentModalViewController.view];
            [currentModalViewController presentModalViewController: gamecenterController animated: YES];
        }
    }
}

- (void) gameCenterViewControllerDidFinish: (GKGameCenterViewController*) viewController {
    if (currentModalViewController != nil){
        [currentModalViewController dismissModalViewControllerAnimated: NO];
        [currentModalViewController release];
        [currentModalViewController.view removeFromSuperview];
        currentModalViewController = nil;
    }
}

- (void) showLeaderboard {
    if (!gameCenterAvailable) return;

    GKLeaderboardViewController* leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil) {
        leaderboardController.leaderboardDelegate = self;

        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        currentModalViewController = [[UIViewController alloc] init];
        [window addSubview: currentModalViewController.view];
        [currentModalViewController presentModalViewController: leaderboardController animated: YES];
    }

}

- (void) leaderboardViewControllerDidFinish: (GKLeaderboardViewController*) viewController {
    if (currentModalViewController != nil){
        [currentModalViewController dismissModalViewControllerAnimated: NO];
        [currentModalViewController release];
        [currentModalViewController.view removeFromSuperview];
        currentModalViewController = nil;
    }
}

- (BOOL) reportScore: (int64_t) score forCategory: (NSString*) category {
    GKScore* scoreReporter = [[[GKScore alloc] initWithCategory: category] autorelease];
    scoreReporter.value = score;

    __block BOOL result = YES;
    [scoreReporter reportScoreWithCompletionHandler: ^(NSError* error) {
        if(error != nil) {
            NSLog(@"Reporting score error.");
            
            result = NO;
        } else {
            NSLog(@"Reporting score success.");
        }
    }];

    return result;
}

- (void) retrieveTopXScores: (int) number {
    GKLeaderboard* leaderboardRequest = [[GKLeaderboard alloc] init];
    if (leaderboardRequest != nil) {
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.range = NSMakeRange(1,number);
        leaderboardRequest.category = _leaderboardName;
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray* scores, NSError* error) {
            if(error != nil) {
                // Handle the error.
                NSLog(@"Retrieving score error.");
            }
            if(scores != nil) {
                // Process the score information.
                NSLog(@"Retrieving score success.");
                //NSArray* tempScore = [NSArray arrayWithArray: leaderboardRequest.scores];
                //for(GKScore* obj in tempScore) {
                //    NSLog(@"    playerID            : %@",obj.playerID);
                //    NSLog(@"    category            : %@",obj.category);
                //    NSLog(@"    date                : %@",obj.date);
                //    NSLog(@"    formattedValue      : %@",obj.formattedValue);
                //    NSLog(@"    value               : %d",obj.value);
                //    NSLog(@"    rank                : %d",obj.rank);
                //    NSLog(@"**************************************");
                //}
            }
        }];
    }
}

- (void) showAchievementboard {
    if (!gameCenterAvailable) return;

    GKAchievementViewController* achievementController = [[GKAchievementViewController alloc] init];
    if (achievementController != nil) {
        achievementController.achievementDelegate = self;

        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        currentModalViewController = [[UIViewController alloc] init];
        [window addSubview: currentModalViewController.view];
        [currentModalViewController presentModalViewController: achievementController animated: YES];
    }
}

- (void) achievementViewControllerDidFinish: (GKAchievementViewController*) viewController {
    if (currentModalViewController != nil) {
        [currentModalViewController dismissModalViewControllerAnimated: NO];
        [currentModalViewController release];
        [currentModalViewController.view removeFromSuperview];
        currentModalViewController = nil;
    }
}

- (void) displayAchievement: (GKAchievement*) achievement {
    if (achievement == nil)
        return;

    NSLog(@"Achievement: %@; %d(%f) at %@.", achievement.identifier, achievement.completed, achievement.percentComplete, achievement.lastReportedDate);
}

- (void) loadAchievement {
    if (self.achievementDictionary == nil) {
        self.achievementDictionary = [[NSMutableDictionary alloc] init];
    }
    [GKAchievement loadAchievementsWithCompletionHandler: ^(NSArray* achievements, NSError* error) {
        if (error == nil && achievements != nil) {
            NSArray* tempArray = [NSArray arrayWithArray: achievements];
            for (GKAchievement* tempAchievement in tempArray) {
                [self.achievementDictionary setObject: tempAchievement
                                               forKey: tempAchievement.identifier
                 ];
                [self displayAchievement:tempAchievement];
            }
        }
    }];
}

- (void) resetAchievement {
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        if (error == nil)
            self.achievementDictionary = [[NSMutableDictionary alloc] init];
        else
            NSLog(@"Resetting score error.");
    }];

    NSEnumerator* enumerator = [self.achievementDictionary objectEnumerator];
    for (NSObject* obj in enumerator) {
        [self unlockAchievement: (GKAchievement*) obj percent: 0.0];
    }
}

- (BOOL) reportAchievement: (NSString*) id percent: (float) percent {
    if (!gameCenterAvailable) {
        NSLog(@"ERROR: GameCenter is not available currently.");

        return NO;
    }

    GKAchievement* achievement = [[[GKAchievement alloc] initWithIdentifier: id] autorelease];

    return [self unlockAchievement: achievement percent: percent];
}

- (BOOL) unlockAchievement: (GKAchievement*) achievement percent: (float) percent {
    if (achievement == nil)
		return NO;

    achievement.percentComplete = percent;
    achievement.showsCompletionBanner = YES;
    __block BOOL result = YES;
    [achievement reportAchievementWithCompletionHandler: ^(NSError* error) {
        if (error != nil) {
            NSLog(@"Commiting achievement error: %@.", error);

            result = NO;
        } else {
            NSLog(@"Commiting achievement success.");
            [self displayAchievement: achievement];
        }
    }];

    return result;
}

- (BOOL) getAchievement: (NSString*) id percent: (float*) percent {
    if (!gameCenterAvailable) {
        NSLog(@"ERROR: GameCenter is not available currently.");

        return NO;
    }

    GKAchievement* achievement = [self getAchievementForID: id];
    if (achievement == nil)
        return NO;

    *percent = (float)achievement.percentComplete;

    return achievement.completed;
}

- (GKAchievement*) getAchievementForID: (NSString*) id {
    if (self.achievementDictionary == nil) {
        self.achievementDictionary = [[NSMutableDictionary alloc] init];
    }
    GKAchievement* achievement = [self.achievementDictionary objectForKey: id];
    if (achievement == nil) {
        achievement = [[[GKAchievement alloc] initWithIdentifier: id] autorelease];
        [self.achievementDictionary setObject: achievement
                                       forKey: achievement.identifier
         ];
    }
    [self displayAchievement: achievement];

    return [[achievement retain] autorelease];
}

@end
