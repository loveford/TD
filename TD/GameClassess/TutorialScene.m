//
//  TutorialLayer.m
//  Cocos2D Build a Tower Defense Game
//
//  Created by iPhoneGameTutorials on 4/4/11.
//  Copyright 2011 iPhoneGameTutorial.com All rights reserved.
//

// Import the interfaces
#import "TutorialScene.h"

#import "DataModel.h"
#import "Tower.h"

// Tutorial implementation
@implementation Tutorial

@synthesize tileMap = _tileMap;
@synthesize background = _background;

@synthesize currentLevel = _currentLevel;
@synthesize path = _path;
+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Tutorial *layer = [Tutorial node];
	
	// add layer as a child to scene
	[scene addChild: layer z:1];
	
	DataModel *m = [DataModel getModel];
	m._gameLayer = layer;
    
    GameHUD * myGameHUD = [GameHUD sharedHUD];
	[scene addChild:myGameHUD z:2];
	
	m._gameHUDLayer = myGameHUD;
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init {
    if((self = [super init])) {
		self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"AStarMap.tmx"];
        self.background = [_tileMap layerNamed:@"Background"];
		self.background.anchorPoint = ccp(0, 0);
		[self addChild:_tileMap z:0];
		
		[self addWaypoint];
		[self addWaves];
		
        //    初始化path
        DataModel *m = [DataModel getModel];
        self.path = [[AStarPath alloc] initWithTileCount:60];
        WayPoint *startWay = [m._waypoints objectAtIndex:0];
        WayPoint *endWay = [m._waypoints lastObject];
        CGPoint startPoint = [self tileCoordForPosition:startWay.position];
        CGPoint endPoint = [self tileCoordForPosition:endWay.position];
        TilePoint *startTile = [[TilePoint alloc] createTilePoint:startPoint.x Y:startPoint.y];
        TilePoint *endTile = [[TilePoint alloc] createTilePoint:endPoint.x Y:endPoint.y];
        [self.path start:startTile EndPoint:endTile];
        [startTile release];
        [endTile release];
        
		// Call game logic about every second
        [self schedule:@selector(update:)];
		[self schedule:@selector(gameLogic:) interval:1.0];

		
		self.currentLevel = 0;
		
		self.position = ccp(-228, -122);
		gameHUD = [GameHUD sharedHUD];
    }
    return self;
}

-(void)addWaves {
	DataModel *m = [DataModel getModel];
	
	Wave *wave = nil;
	wave = [[Wave alloc] initWithCreep:[FastRedCreep creep] SpawnRate:1.0 TotalCreeps:20];
	[m._waves addObject:wave];
	wave = nil;
}

- (Wave *)getCurrentWave{
	
	DataModel *m = [DataModel getModel];	
	Wave * wave = (Wave *) [m._waves objectAtIndex:self.currentLevel];
	
	return wave;
}

- (Wave *)getNextWave{
	
	DataModel *m = [DataModel getModel];
	
	self.currentLevel++;
	
	if (self.currentLevel >= 1)
		self.currentLevel = 0;
	
	 Wave * wave = (Wave *) [m._waves objectAtIndex:self.currentLevel];
	 
	 return wave;
}

-(void)addWaypoint {
	DataModel *m = [DataModel getModel];
	
	CCTMXObjectGroup *objects = [self.tileMap objectGroupNamed:@"Objects"];
	WayPoint *wp = nil;
	
	int spawnPointCounter = 0;
	NSMutableDictionary *spawnPoint;
	while ((spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"Waypoint%d", spawnPointCounter]])) {
		int x = [[spawnPoint valueForKey:@"x"] intValue];
		int y = [[spawnPoint valueForKey:@"y"] intValue];
		
		wp = [WayPoint node];
		wp.position = ccp(x, y);
		[m._waypoints addObject:wp];
		spawnPointCounter++;
	}
	
	NSAssert([m._waypoints count] > 0, @"Waypoint objects missing");
	wp = nil;
}

-(void)addTarget {
    
	DataModel *m = [DataModel getModel];
	Wave * wave = [self getCurrentWave];
	if (wave.totalCreeps < 0) {
		[self getNextWave];
	}
	
	wave.totalCreeps--;
	
    Creep *target = nil;
    if ((arc4random() % 2) == 0) {
        target = [FastRedCreep creep];
    } else {
        target = [StrongGreenCreep creep];
    }	
	target.tileMap = _tileMap;
	WayPoint *waypoint = [target getCurrentWaypoint ];
	target.position = waypoint.position;	
	waypoint = [target getNextWaypoint ];

	
	[self addChild:target z:1];
	
	int moveDuration = target.moveDuration;	
	id actionMove = [CCMoveTo actionWithDuration:moveDuration position:waypoint.position];
//    移动 再回调 继续移动
	id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(FollowPath:)];
	[target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
	
	// Add to targets array
	target.tag = 1;
	[m._targets addObject:target];
	
}

-(void)FollowPath:(id)sender {
    
	Creep *creep = (Creep *)sender;
    
	WayPoint * waypoint = [creep getNextWaypoint];
    if (waypoint.isLastWayPoint) {
        [self removeChild:creep cleanup:YES];
        return;
    }

	int moveDuration = creep.moveDuration;
	id actionMove = [CCMoveTo actionWithDuration:moveDuration position:waypoint.position];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(FollowPath:)];
	[creep stopAllActions];
	[creep runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

-(void)gameLogic:(ccTime)dt {
	
	DataModel *m = [DataModel getModel];
	Wave * wave = [self getCurrentWave];
	static double lastTimeTargetAdded = 0;
    double now = [[NSDate date] timeIntervalSince1970];
   if(lastTimeTargetAdded == 0 || now - lastTimeTargetAdded >= wave.spawnRate) {
        [self addTarget];
        lastTimeTargetAdded = now;
    }
	
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -_tileMap.contentSize.width+winSize.width); 
    retval.y = MIN(0, retval.y);
    retval.y = MAX(-_tileMap.contentSize.height+winSize.height, retval.y); 
    return retval;
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {    
        
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        touchLocation = [self convertToNodeSpace:touchLocation];                
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {    
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = ccp(translation.x, -translation.y);
        CGPoint newPos = ccpAdd(self.position, translation);
        self.position = [self boundLayerPos:newPos];  
        [recognizer setTranslation:CGPointZero inView:recognizer.view];    
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
               
		float scrollDuration = 0.2;
		CGPoint velocity = [recognizer velocityInView:recognizer.view];
		CGPoint newPos = ccpAdd(self.position, ccpMult(ccp(velocity.x, velocity.y * -1), scrollDuration));
		newPos = [self boundLayerPos:newPos];

		[self stopAllActions];
		CCMoveTo *moveTo = [CCMoveTo actionWithDuration:scrollDuration position:newPos];            
		[self runAction:[CCEaseOut actionWithAction:moveTo rate:1]];            
        
    }        
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [_path release];
    [_tileMap release];
    [_background release];
	[super dealloc];
}

#pragma mark - add tower

- (CGPoint) tileCoordForPosition:(CGPoint) position
{
    int x = position.x / self.tileMap.tileSize.width;
    int y = ((self.tileMap.mapSize.height * self.tileMap.tileSize.height) - position.y) / self.tileMap.tileSize.height;
    return ccp(x,y);
}

-(void)addTower: (CGPoint)pos {
    DataModel *m = [DataModel getModel];
    Tower *target = nil;
    CGPoint towerLoc = [self tileCoordForPosition: pos];
    
    int tileGid = [self.background tileGIDAt:towerLoc];
    NSDictionary *props = [self.tileMap propertiesForGID:tileGid];
    NSString *type = [props valueForKey:@"buildable"];
    
    NSLog(@"Buildable: %@", type);
    if([type isEqualToString: @"1"]) {
        for (Tower *tower in m._towers) {
            CGPoint point = ccp((towerLoc.x *32) +16, self.tileMap.contentSize.height - (towerLoc.y *32) -16);
            if (CGPointEqualToPoint(point,tower.position)) {
                NSLog(@"Aready have a tower!");
                return ;
            }
        }
        target = [MachineGunTower tower];
        target.position = ccp((towerLoc.x *32) +16, self.tileMap.contentSize.height - (towerLoc.y *32) -16);
        [self addChild:target z:1];
        
        target.tag =1;
        [m._towers addObject:target];
    } else {
        NSLog(@"Tile Not Buildable");
    }
}

#pragma mark - 判断是否可以添加炮塔
- (BOOL) canBuildOnTilePosition:(CGPoint) pos
{
    CGPoint towerLoc = [self tileCoordForPosition: pos];
    int tileGid = [self.background tileGIDAt:towerLoc];
    NSDictionary *props = [self.tileMap propertiesForGID:tileGid];
    NSString *type = [props valueForKey:@"buildable"];
    
    DataModel *m = [DataModel getModel];
    WayPoint *endWay = [m._waypoints lastObject];
    CGPoint endPointTile = [self tileCoordForPosition:endWay.position];
    
    TilePoint *endPoint = [[TilePoint alloc] createTilePoint:endPointTile.x Y:endPointTile.y];
    
    
    
    if([type isEqualToString: @"1"]) {
//        判断同一位置是否已经有炮塔存在
        for (Tower *tower in m._towers) {
           CGPoint point = ccp((towerLoc.x *32) +16, self.tileMap.contentSize.height - (towerLoc.y *32) -16);
            if (CGPointEqualToPoint(point,tower.position)) {
                return NO;
            }
        }
//        判断是否有一条路径能到达终点
        [self reloadPathToEndPoint:endPoint];
        NSLog(@"step count is %d",self.path.closeTable.count);
        if (!self.path.closeTable.count) {
            return NO;
        }

//        for (Creep *target in m._targets) {
//            [target reloadPathToEndPoint:endPoint];
//            NSLog(@"step count is %d",target.path.closeTable.count);
//            if (!target.path.closeTable.count) {
//                return NO;
//            }
//        }
        return YES;
    }
    [endPoint release];
    return NO;
}

//重新计算路径
- (void)reloadPathToEndPoint:(TilePoint *)endPoint
{
    CGPoint tileLocation = [self tileCoordForPosition:self.position];
    TilePoint *startPoint = [[TilePoint alloc] createTilePoint:tileLocation.x Y:tileLocation.y];
    [self.path start:startPoint EndPoint:endPoint];
    [startPoint release];
}

- (void)update:(ccTime)dt {
    
	DataModel *m = [DataModel getModel];
	NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    
	for (Projectile *projectile in m._projectiles) {
		
		CGRect projectileRect = CGRectMake(projectile.position.x - (projectile.contentSize.width/2),
										   projectile.position.y - (projectile.contentSize.height/2),
										   projectile.contentSize.width,
										   projectile.contentSize.height);
        
		NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
		
		for (CCSprite *target in m._targets) {
			CGRect targetRect = CGRectMake(target.position.x - (target.contentSize.width/2),
										   target.position.y - (target.contentSize.height/2),
										   target.contentSize.width,
										   target.contentSize.height);
            
			if (CGRectIntersectsRect(projectileRect, targetRect)) {
                
				[projectilesToDelete addObject:projectile];
				
                Creep *creep = (Creep *)target;
                creep.hp--;
				
                if (creep.hp <= 0) {
                    [targetsToDelete addObject:target];
                }
                break;
                
			}
		}
		
		for (CCSprite *target in targetsToDelete) {
			[m._targets removeObject:target];
			[self removeChild:target cleanup:YES];
		}
		
		[targetsToDelete release];
	}
	
	for (CCSprite *projectile in projectilesToDelete) {
		[m._projectiles removeObject:projectile];
		[self removeChild:projectile cleanup:YES];
	}
	[projectilesToDelete release];
}
@end
