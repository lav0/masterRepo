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
    metalCustomGeometry* _grid;
    metalCustomGeometry* _plane;
    
    metalCustomTexture* _textureGrid;
    metalCustomTexture* _texturePlane;
    
    Camera          _camera;
    
    matrix_float4x4 _projectionMatrix;
    
    float _rotation;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    if (self = [super init])
    {
        // do geometry
        metal3DPosition* position1 = [[metal3DPosition alloc] initAtPoint:(vector_float3){2.f, 0.f, 0.f}];
        metal3DPosition* position2 = [[metal3DPosition alloc] initAtPoint:(vector_float3){-2.f, 0.f, 0.f}];
        
        NSURL *gridURL = [[NSBundle mainBundle] URLForResource:@"quadro_grid" withExtension:@"obj"];
        NSURL *planeURL = [[NSBundle mainBundle] URLForResource:@"sgrid" withExtension:@"obj"];
        if (gridURL == nil || planeURL == nil)
            NSLog(@"Sorry. File not found");
        
        _grid = [[metalCustomGeometry alloc] initWithDevice:device andLoadFrom:gridURL];
        _plane =[[metalCustomGeometry alloc] initWithDevice:device andLoadFrom:planeURL];
        
        [_grid setSpacePosition:position1];
        [_plane setSpacePosition:position2];
        
        _camera.move( {0.f, 0.f, -5.f} );
        
        // do texture
        auto purePositions = [Manager collectPositionsFrom:_grid];
        _textureGrid = [[metalCustomTexture alloc] initWithDevice:device
                                                            Vertices:purePositions
                                                          andPicture:@"Image008"];
        
        purePositions = [Manager collectPositionsFrom:_plane];
        _texturePlane = [[metalCustomTexture alloc] initWithDevice:device
                                                          Vertices:purePositions
                                                        andPicture:@"Image008"];
        
        _rotation = 0.5f;
    }
    
    return self;
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
    
    [_plane setViewProjection:&viewProj];
    [_grid setViewProjection:&viewProj];
    
    [_plane update];
    [_grid update];
}

- (void)update
{
    [_plane.spacePosition rotateWithAxis:(vector_float3){0.f, 0.0f, 1.f} andAngle:0.02];
    [_grid.spacePosition rotateWithAxis:(vector_float3){0.f, 1.0f, 0.f} andAngle: (int(_rotation) & 1) ? 0.012 : -0.012];
    
    [_plane update];
    [_grid update];
    
    simd::float4 tenacity0 = {2.f, 0.f, 0.f, 1.f};
    simd::float4 tenacity1 = {-1.f, 0, 0.f, 1.f};
    
    [_textureGrid transformTextureAccordingWith:tenacity0 And:tenacity1];
    
    _rotation += 0.01f;
    
    Vertex* pVer = [_grid getClosestTo:tenacity0];
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

- (id<metalGeometryProviderProtocol>)getGeometry0
{
    return _plane;
}
- (id<metalGeometryProviderProtocol>)getGeometry1
{
    return _grid;
}
- (id<metalTextureProviderProtocol>)getTexture0;
{
    return _textureGrid;
}
- (id<metalTextureProviderProtocol>)getTexture1;
{
    return _texturePlane;
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
