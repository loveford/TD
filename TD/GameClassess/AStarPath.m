//
//  AStarPath.m
//  TD
//
//  Created by mouwenbin on 8/24/12.
//
//



#import "AStarPath.h"
#import "TilePoint.h"
#import "DataModel.h"
#import "Tower.h"

@implementation AStarPath
@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize openTable;
@synthesize closeTable;

- (void)dealloc
{
    [_startPoint release];
    [_endPoint release];
    [openTable release];
    [closeTable release];
    [super dealloc];
}

- (id)initWithTileCount:(NSInteger)tileCount{
    
	if ((self = [super init])) {
		
		openTable = [[NSMutableArray alloc] initWithCapacity:tileCount];
		closeTable = [[NSMutableArray alloc] initWithCapacity:tileCount];
	}
	return self;
}

- (void)start:(TilePoint *)startPoint_ EndPoint:(TilePoint *)endPoint_{
    
    [openTable addObject:startPoint_];//一开始就把起始位置放进openTable
    TilePoint *curr=nil;
    while ([openTable count] > 0){//该循环用来找到最短路径,openTable要是没东西了 就表示无法到达目的地！
        curr = [self bestTilePoint:curr];//从openTable找取出最合适的格子，下一步应该向哪里走
        if (curr != nil) {
            
            [closeTable addObject:curr];//检测过了 就放到closeTable
            
            if ([self nextTile:curr X:curr.x Y:curr.y-1] == YES) {//该函数用来判断是否到达终点
                return;
            }
            if ([self nextTile:curr X:curr.x+1 Y:curr.y-1] == YES) {
				return;
			}
            
			if ([self nextTile:curr X:curr.x+1 Y:curr.y] == YES) {
				return;
			}
            
			if ([self nextTile:curr X:curr.x+1 Y:curr.y+1] == YES) {
				return;
			}
			
			if ([self nextTile:curr X:curr.x Y:curr.y+1] == YES) {
				return;
			}
			
			if ([self nextTile:curr X:curr.x-1 Y:curr.y+1] == YES) {
				return;
			}
			
			if ([self nextTile:curr X:curr.x-1 Y:curr.y] == YES) {
				return;
			}
			
			if ([self nextTile:curr X:curr.x-1 Y:curr.y-1] == YES) {
				return;
			}
        }
    }
}

- (TilePoint *)bestTilePoint:(TilePoint *)p{
    
    TilePoint *best = nil;
    
    if ([openTable count] == 0) {
        return nil;
    }else {
        for (NSInteger i = 0; i < [openTable count]; i++) {//遍历openTable
            if (best == nil) {
                best = [openTable objectAtIndex:i];//取出格子
                if (best != nil && [self isComparePoint:best.parent And:p] == NO) {
                    best = nil;
                }
            }else {
                TilePoint *best2 = [openTable objectAtIndex:i];
                if ([self isComparePoint:best2.parent And:p] == YES) {
                    best = best.f >= best2.f ? best2 : best;//得到f值小的格子,f值越小路线则越可靠
                }
            }
        }
        [best retain];
        [openTable removeObject:best];//从openTable中删除 一会还要加入到closeTable
        return best;
    }
}

- (BOOL)nextTile:(TilePoint *)curr X:(NSInteger)x Y:(NSInteger)y{
    
    TilePoint *next = [[TilePoint alloc] createTilePoint:x Y:y];
    next.parent = curr;//父亲当然是当前的格子
    
    if ([self isComparePoint:next And:_endPoint]) {//先判断是否已到目的地
        [closeTable addObject:next];
        NSLog(@"find end point !!!!!!!\n");
        return YES; //到了目的地 就不需要在检测其它格子了。。
    }
    
    //这里检测的是格子是否为有效，包括：障碍物 出屏幕 已经检测过。。
    if ([self isInCloseTable:next] == NO && [self isEnableTile:next] == YES) {
        if ([self isInOpenTable:next] == NO) {
            //计算f、g值
            next.g = 14 + next.parent.g;
            next.f = next.g + [self calculateHPower:next];
            
            [openTable addObject:next];//然后就可以加入到openTable了
        }else {
            TilePoint *next2 = [self getFromOpenPath:next];
            if (next2.f > next.f) {
                next2.parent = curr;
                next2.g = 14 + next2.parent.g;
                next2.f = next2.g + [self calculateHPower:next2];
            }
        }
    }
    return NO;
}

//计算H值
- (int)calculateHPower:(TilePoint *)tilePoint
{
    int h = abs(_endPoint.x - tilePoint.x) + abs(_endPoint.y - tilePoint.y);
    return h;
}

//计算G值
- (NSInteger)calculateGPower:(TilePoint *)p{
	return abs(_startPoint.x - p.x) + abs(_startPoint.y - p.y);
}

//获取路径的节点
- (TilePoint *)getFromOpenPath:(TilePoint *)p{
    
	for (TilePoint *pp in openTable){
		if ([self isComparePoint:pp And:p] == YES) {
			return pp;
		}
	}
	return nil;
}

- (BOOL)isComparePoint:(TilePoint *)p1 And:(TilePoint *)p2{
    
	if (p1.x == p2.x && p1.y == p2.y) {
		return YES;
	}else {
		return NO;
	}
    
}

- (BOOL)isInOpenTable:(TilePoint *)p{
    
	for (TilePoint *pTemp in openTable){
        
		if ([self isComparePoint:pTemp And:p] == YES) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)isInCloseTable:(TilePoint *)p{
	
	for (TilePoint *pTemp in closeTable){
		
		if ([self isComparePoint:pTemp And:p] == YES) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)isEnableTile:(TilePoint *)tilePoint
{
	CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"AStarMap.tmx"];
	CCTMXLayer *layer = [map layerNamed:@"Background"];
	
	if (tilePoint.x < 0 || tilePoint.y < 0 || tilePoint.x > 30 || tilePoint.y > 20) {
		
		return NO;
	}else {
        
		int gid = [layer tileGIDAt:ccp(tilePoint.x,tilePoint.y)];
        
        NSDictionary *props = [map propertiesForGID:gid];
        NSString *type = [props valueForKey:@"buildable"];
        if ([type isEqualToString:@"0"]) {
        			return NO;
        }else {
//            判断是否有炮塔在此
            DataModel *model = [DataModel getModel];
            for (Tower *tower in model._towers) {
                CGPoint point = ccp((tilePoint.x *32) +16, map.contentSize.height - (tilePoint.y *32) -16);
                NSLog(@"point is %@",NSStringFromCGPoint(point));
                NSLog(@"towerPosition is %@",NSStringFromCGPoint(tower.position));
                if (CGPointEqualToPoint(point,tower.position)) {
                    return NO;
                }
            }
            return YES;
		}
		
	}
    
    
}
@end

