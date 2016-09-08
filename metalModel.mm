//
//  metalModel.m
//  masterOfPuppets
//
//  Created by Andrey on 12.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "metalModel.h"
#include <memory>

@implementation metalModel
{
    metalCustomGeometry* _geometry;
    std::unique_ptr<CustomGeometry> _geometryCpp;
    
    NSMutableArray* _arrTextures;
    NSUInteger      _iterTextures;
}

- (instancetype)initWithGeometry:(CustomGeometry*)g
{
    if (self = [super init])
    {
        //_geometry = g;
        _geometryCpp = std::unique_ptr<CustomGeometry>(new CustomGeometry(*g));
        
        _arrTextures = [[NSMutableArray alloc] init];
        _iterTextures = 0;
    }
    return self;
}

- (BOOL)addTexture:(metalCustomTexture*)t
{
    if ([_arrTextures count] >= MAX_TEXTURES_PER_GEOMETRY)
        return NO;
    
    [_arrTextures addObject:t];
 
    return YES;
}

- (BOOL)contains:(metalCustomTexture*)t
{
    return [_arrTextures containsObject:t];
}

- (CustomGeometry*)getGeometry
{
    return _geometryCpp.get();
}

- (id<metalTextureProviderProtocol>)getNextTexture
{
    if ([self isNextTextureAvailable])
    {
        return [_arrTextures objectAtIndex:_iterTextures++];
    }
    
    _iterTextures = 0;
    
    return nil;
}

- (bool)isNextTextureAvailable
{
    return _iterTextures < [_arrTextures count];
}

@end
