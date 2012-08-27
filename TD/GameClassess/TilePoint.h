//
//  TilePoint.h
//  TD
//
//  Created by mouwenbin on 8/24/12.
//
//

#import <Foundation/Foundation.h>

@interface TilePoint : NSObject

@property (nonatomic ,assign) int x;
@property (nonatomic ,assign) int y;
@property (nonatomic ,assign) int g;
@property (nonatomic ,assign) int h;
@property (nonatomic, assign) int f;
@property (nonatomic, retain) TilePoint *parent;


- (TilePoint *)createTilePoint:(int)x Y:(int)y;
@end
