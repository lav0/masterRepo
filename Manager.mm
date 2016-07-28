//
//  Manager.m
//  masterOfPuppets
//
//  Created by Andrey on 20.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "Manager.h"
#import "metalGPBlueBox.h"
#import "metalCustomGeometry.h"
#import "metalCustomTexture.h"

#include "Camera.hpp"
#include <vector>

@implementation Manager
{
    NSMutableArray* _geometriesArray;
    NSMutableArray* _texturesArray;
    
    Camera          _camera;
    
    matrix_float4x4 _projectionMatrix;
    
    float _rotation;
    unsigned int _nextGeometryIndex;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    if (self = [super init])
    {
        _geometriesArray = [[NSMutableArray alloc] init];
        _texturesArray   = [[NSMutableArray alloc] init];
        
        _camera.move( {0.f, 0.f, -5.f} );
        
        _rotation = 0.5f;
        _nextGeometryIndex = 0;
        
        [self createGeometry:device];
        [self createTexture:device];
    }
    
    return self;
}

- (void)createGeometry:(id<MTLDevice>)device
{
    metal3DPosition* position1 = [[metal3DPosition alloc] initAtPoint:(vector_float3){2.f, 0.f, 0.f}];
    metal3DPosition* position2 = [[metal3DPosition alloc] initAtPoint:(vector_float3){-2.f, 0.f, 0.f}];
    
    NSURL *quadroURL = [[NSBundle mainBundle] URLForResource:@"quadro_grid" withExtension:@"obj"];
    NSURL *gridURL = [[NSBundle mainBundle] URLForResource:@"sgrid" withExtension:@"obj"];
    if (quadroURL == nil || gridURL == nil)
        NSLog(@"Sorry. File not found");
    
    metalCustomGeometry* g1 = [[metalCustomGeometry alloc] initWithDevice:device andLoadFrom:quadroURL];
    metalCustomGeometry* g2 =[[metalCustomGeometry alloc] initWithDevice:device andLoadFrom:gridURL];
    
    [g1 setSpacePosition:position1];
    [g2 setSpacePosition:position2];
    
    [_geometriesArray addObject:g1];
    [_geometriesArray addObject:g2];
}

- (void)createTexture:(id<MTLDevice>)device
{
    for (metalCustomGeometry* g in _geometriesArray)
    {
        auto purePositions = [Manager collectPositionsFrom:g];
        metalCustomTexture* t = [[metalCustomTexture alloc] initWithDevice:device
                                                                  Vertices:purePositions
                                                                andPicture:@"Image008"];
        
        [_texturesArray addObject:t];
    }
}

- (void)recalculateProjectionWithWidth:(CGFloat)width AndHeight:(CGFloat)height
{
    float aspect = fabs(width / height);
    _projectionMatrix = matrix_from_perspective_fov_aspectLH(65.0f * (M_PI / 180.0f), aspect, 0.1f, 100.0f);
    
    [self _updateViewProjection];
}

- (void)_updateViewProjection
{
    matrix_float4x4 viewProj = matrix_multiply(_projectionMatrix, _camera.get_view_transformation());
    
    for (metalCustomGeometry* g in _geometriesArray)
    {
        [g setViewProjection:&viewProj];
        [g update];
    }
}

- (void)update
{
    metalCustomGeometry* plane = [_geometriesArray objectAtIndex:1];
    metalCustomGeometry* grid = [_geometriesArray objectAtIndex:0];
    
    [plane.spacePosition rotateWithAxis:(vector_float3){0.f, 0.0f, 1.f} andAngle:0.02];
    [grid.spacePosition rotateWithAxis:(vector_float3){0.f, 1.0f, 0.f} andAngle: (int(_rotation) & 1) ? 0.012 : -0.012];
    
    
    [plane update];
    [grid update];
    
    simd::float4 tenacity0 = {2.f, 0.f, 0.f, 1.f};
    simd::float4 tenacity1 = {-1.f, 0, 0.f, 1.f};
    
    [[_texturesArray objectAtIndex:0] transformTextureAccordingWith:tenacity0 And:tenacity1];
    
    _rotation += 0.01f;
    
    Vertex* pVer = [grid getClosestTo:tenacity0];
    if (nil != pVer)
    {
        pVer->position[2] += 0.01 * sinf(_rotation);
        simd::float4 p = pVer->position;
        NSLog(@"%f, %f, %f, %f", p[0], p[1], p[2], p[3]);
    }
    else
    {
        NSLog(@"OOpsy");
    }
}

- (bool)getNextGeometry:(id<metalGeometryProviderProtocol>*)geometry
             andTexture:(id<metalTextureProviderProtocol>*)texture
{
    assert([_geometriesArray count] == [_texturesArray count]);
    
    if (_nextGeometryIndex >= [_geometriesArray count])
    {
        _nextGeometryIndex = 0;
        
        return NO;
    }
    
    *geometry = [_geometriesArray objectAtIndex:_nextGeometryIndex];
    *texture  = [_texturesArray objectAtIndex:_nextGeometryIndex];
    
    ++_nextGeometryIndex;
    
    return YES;
}

+ (std::vector<simd::float4>)collectPositionsFrom:(id<metalGeometryProviderProtocol>)provider
{
    std::vector<simd::float4> purePositions;
    purePositions.reserve(provider.vertexCount);
    
    simd::float4* v = (simd::float4*) [provider.vertexBuffer contents];
    
    for (auto i=0; i < 2 * provider.vertexCount; i += 2)
    {
        purePositions.push_back(v[i]);
    }
    
    return purePositions;
}

@end
