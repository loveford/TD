//
//  Creep.m
//  Cocos2D Build a Tower Defense Game
//
//  Created by iPhoneGameTutorials on 4/4/11.
//  Copyright 2011 iPhoneGameTutorial.com All rights reserved.
//

#import "Creep.h"

@implementation Creep

@synthesize hp = _curHp;
@synthesize moveDuration = _moveDuration;
@synthesize path = _path;

@synthesize curWaypoint = _curWaypoint;
@synthesize tileMap = _tileMap;

- (id) copyWithZone:(NSZone *)zone {
	Creep *copy = [[[self class] allocWithZone:zone] initWithCreep:self];
	return copy;
}

- (Creep *) initWithCreep:(Creep *) copyFrom {
    if ((self = [[[super alloc] initWithFile:@"Enemy1.png"] autorelease])) {
	self.hp = copyFrom.hp;
	self.moveDuration = copyFrom.moveDuration;
	self.curWaypoint = copyFrom.curWaypoint;
	}
	[self retain];
	return self;
}

- (WayPoint *)getCurrentWaypoint{
	
	DataModel *m = [DataModel getModel];
	
	WayPoint *waypoint = (WayPoint *) [m._waypoints objectAtIndex:self.curWaypoint];
	
	return waypoint;
}

- (WayPoint *)getNextWaypoint{
	
	DataModel *m = [DataModel getModel];
	int lastWaypoint = m._waypoints.count;

	self.curWaypoint++;
	
    BOOL isLastWayPoint = NO;
	if (self.curWaypoint >= lastWaypoint)
    {
		self.curWaypoint = lastWaypoint - 1;
        isLastWayPoint = YES;
	}
	WayPoint *waypoint = (WayPoint *) [m._waypoints objectAtIndex:self.curWaypoint];
	waypoint.isLastWayPoint = isLastWayPoint;
    
	return waypoint;
}

//重新计算路径
- (void)reloadPathToEndPoint:(TilePoint *)endPoint
{
    CGPoint tileLocation = [self tileCoordForPosition:self.position];
    TilePoint *startPoint = [[TilePoint alloc] createTilePoint:tileLocation.x Y:tileLocation.y];
    [self.path start:startPoint EndPoint:endPoint];
    [startPoint release];
}

- (CGPoint) tileCoordForPosition:(CGPoint) position
{
    int x = position.x / self.tileMap.tileSize.width;
    int y = ((self.tileMap.mapSize.height * self.tileMap.tileSize.height) - position.y) / self.tileMap.tileSize.height;
    return ccp(x,y);
}

- (void)dealloc
{
    [_path release];
    [_tileMap release];
    [super dealloc];
}
@end

@implementation FastRedCreep

+ (id)creep {
 
    FastRedCreep *creep = nil;
    if ((creep = [[[super alloc] initWithFile:@"Enemy1.png"] autorelease])) {
        creep.hp = 10;
        creep.moveDuration = 4;
		creep.curWaypoint = 0;
    }
    return creep;
}

@end

@implementation StrongGreenCreep

+ (id)creep {
    
    StrongGreenCreep *creep = nil;
    if ((creep = [[[super alloc] initWithFile:@"Enemy2.png"] autorelease])) {
        creep.hp = 20;
        creep.moveDuration = 29;
		creep.curWaypoint = 0;
    }
    return creep;
}

@end