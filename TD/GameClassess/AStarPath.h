//
//  AStarPath.h
//  TD
//
//  Created by mouwenbin on 8/24/12.
//
//

#import <Foundation/Foundation.h>
#import "cocos2D.h"
@class  TilePoint;
@interface AStarPath : NSObject
{
    NSMutableArray *openTable;//尚未走过的格子
    NSMutableArray *closeTable;//已经走过的格子
}

@property (nonatomic ,retain) TilePoint *startPoint;
@property (nonatomic, retain) TilePoint *endPoint;
@property (retain) NSMutableArray *openTable;
@property (retain) NSMutableArray *closeTable;

- (BOOL)isComparePoint:(TilePoint *)p1 And:(TilePoint *)p2;
- (void)start:(TilePoint *)startPoint_ EndPoint:(TilePoint *)endPoint_;
@end
