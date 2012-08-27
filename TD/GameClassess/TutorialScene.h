//
//  TutorialLayer.h
//  Cocos2D Build a Tower Defense Game
//
//  Created by iPhoneGameTutorials on 4/4/11.
//  Copyright 2011 iPhoneGameTutorial.com All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

#import "Creep.h"
#import "WayPoint.h"
#import "Wave.h"
#import "GameHUD.h"
#import "Projectile.h"
#import "AStarPath.h"
#import "TilePoint.h"

// Tutorial Layer
@interface Tutorial : CCLayer
{
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_background;	
	GameHUD * gameHUD;
	int _currentLevel;
}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) AStarPath *path;


@property (nonatomic, assign) int currentLevel;

+ (id) scene;
- (void)addWaypoint;
- (BOOL) canBuildOnTilePosition:(CGPoint) pos;
-(void)addTower: (CGPoint)pos;
@end
