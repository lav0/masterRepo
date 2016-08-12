//
//  metalModel.m
//  masterOfPuppets
//
//  Created by Andrey on 12.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "metalModel.h"

@implementation metalModel
{
    metalCustomGeometry* _geometry;
    
    NSMutableArray* _arrTextures;
    NSUInteger      _iterTextures;
}

- (instancetype)initWithGeometry:(metalCustomGeometry*)g
{
    if (self = [super init])
    {
        _geometry = g;
        
        _arrTextures = [[NSMutableArray alloc] init];
        _iterTextures = 0;
    }
    return self;
}

- (bool)addTexture:(metalCustomTexture*)t
{
    if ([_arrTextures count] >= MAX_TEXTURES_PER_GEOMETRY)
        return NO;
    
    [_arrTextures addObject:t];
 
    return YES;
}

- (id<metalGeometryProviderProtocol>)getGeometry
{
    return _geometry;
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
