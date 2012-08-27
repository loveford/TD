//
//  TilePoint.m
//  TD
//
//  Created by mouwenbin on 8/24/12.
//
//

#import "TilePoint.h"

@implementation TilePoint
@synthesize x = _x,y = _y,g = _g,h = _h,f = _f;
@synthesize parent = _parent;



- (TilePoint *)createTilePoint:(int)x Y:(int)y
{
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
    }
    return self;
}

- (void)dealloc
{
    [_parent release];
    [super dealloc];
}

@end
