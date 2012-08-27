//
//  Creep.h
//  Cocos2D Build a Tower Defense Game
//
//  Created by iPhoneGameTutorials on 4/4/11.
//  Copyright 2011 iPhoneGameTutorial.com All rights reserved.
//

#import "cocos2d.h"

#import "DataModel.h"
#import "WayPoint.h"
#import "TilePoint.h"
#import "AStarPath.h"

@interface Creep : CCSprite <NSCopying> {
    int _curHp;
	int _moveDuration;
	
	int _curWaypoint;
}

@property (nonatomic, assign) int hp;
@property (nonatomic, assign) int moveDuration;

@property (nonatomic, assign) int curWaypoint;
@property (nonatomic, retain) AStarPath *path;
@property (nonatomic, retain) CCTMXTiledMap *tileMap;

- (Creep *) initWithCreep:(Creep *) copyFrom; 
- (WayPoint *)getCurrentWaypoint;
- (WayPoint *)getNextWaypoint;
- (void)reloadPathToEndPoint:(TilePoint *)endPoint;

@end

@interface FastRedCreep : Creep {
}
+(id)creep;
@end

@interface StrongGreenCreep : Creep {
}
+(id)creep;
@end